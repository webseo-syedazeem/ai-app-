import { GoogleGenAI, Type, type FunctionDeclaration } from '@google/genai';
import crypto from 'node:crypto';
import { hasGeminiConfig } from '../config/env.js';
import { dataStore } from '../db/dataStore.js';
import type { BrainDumpItemDraft } from '../types/domain.js';
import { buildSystemPrompt, selectModelForInput } from './intentRouter.js';
import {
  buildForgettingReport,
  executeToolCall,
  fallbackParseBrainDump,
  inferShoppingCategory,
  resolveRelativeDateTime,
} from './toolExecutor.js';

const FUNCTION_DECLARATIONS: FunctionDeclaration[] = [
  {
    name: 'create_task',
    description: 'Create a task or to-do item for the user.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        title: { type: Type.STRING, description: 'Short actionable title' },
        due_at: { type: Type.STRING, description: 'ISO date/time or relative phrase like tomorrow 11:00' },
        priority: { type: Type.STRING, description: 'low, normal, or high' },
      },
      required: ['title'],
    },
  },
  {
    name: 'complete_task',
    description: 'Mark a pending task as completed.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        task_id_or_title: { type: Type.STRING, description: 'Task id or matching title text' },
      },
      required: ['task_id_or_title'],
    },
  },
  {
    name: 'delete_task',
    description: 'Delete a task.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        task_id_or_title: { type: Type.STRING },
      },
      required: ['task_id_or_title'],
    },
  },
  {
    name: 'create_reminder',
    description: 'Create a reminder or scheduled notification.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        title: { type: Type.STRING },
        remind_at: { type: Type.STRING, description: 'ISO timestamp or natural phrase like tomorrow 17:00' },
        person: { type: Type.STRING },
        recurring: { type: Type.STRING, description: 'Optional recurring cadence' },
      },
      required: ['title', 'remind_at'],
    },
  },
  {
    name: 'delete_reminder',
    description: 'Delete a reminder.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        reminder_id_or_title: { type: Type.STRING },
      },
      required: ['reminder_id_or_title'],
    },
  },
  {
    name: 'create_shopping_item',
    description: 'Add an item to the user shopping list.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        item: { type: Type.STRING },
        category: { type: Type.STRING },
      },
      required: ['item'],
    },
  },
  {
    name: 'remove_shopping_item',
    description: 'Remove an item from the shopping list.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        item: { type: Type.STRING },
      },
      required: ['item'],
    },
  },
  {
    name: 'create_event',
    description: 'Schedule a meeting or calendar event with a person.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        title: { type: Type.STRING },
        person: { type: Type.STRING },
        event_at: { type: Type.STRING },
      },
      required: ['title', 'event_at'],
    },
  },
  {
    name: 'save_memory',
    description: 'Save long-term structured memory (birthdays, important dates, preferences, people, routines).',
    parameters: {
      type: Type.OBJECT,
      properties: {
        title: { type: Type.STRING },
        content: { type: Type.STRING },
        category: { type: Type.STRING, description: 'people | dates | preferences | projects | routines | other' },
        importance: { type: Type.INTEGER, description: '1 to 5' },
        event_date: { type: Type.STRING, description: 'YYYY-MM-DD if date-based' },
      },
      required: ['title', 'content', 'category'],
    },
  },
  {
    name: 'get_memory',
    description: 'Retrieve saved memories by optional query or category.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        query: { type: Type.STRING },
        category: { type: Type.STRING },
      },
    },
  },
  {
    name: 'delete_memory',
    description: 'Forget / delete a saved memory.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        memory_id_or_title: { type: Type.STRING },
      },
      required: ['memory_id_or_title'],
    },
  },
  {
    name: 'get_today',
    description: 'Get tasks, reminders, and shopping count due today.',
    parameters: { type: Type.OBJECT, properties: {} },
  },
  {
    name: 'get_upcoming',
    description: 'Get upcoming tasks, reminders, and important dates over the next N days.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        days: { type: Type.INTEGER },
      },
    },
  },
  {
    name: 'get_overdue_tasks',
    description: 'Get overdue pending tasks.',
    parameters: { type: Type.OBJECT, properties: {} },
  },
];

export interface AssistantChatResponse {
  reply: string;
  modelUsed: string;
  tier: string;
  executedTools: Array<{ name: string; result: Record<string, unknown> }>;
  pendingAction: Record<string, unknown> | null;
  tokensEstimated: number;
}

export async function runAssistantChat(
  userId: string,
  userMessage: string,
  requireConfirmForReminder = false
): Promise<AssistantChatResponse> {
  const [user, memories] = await Promise.all([
    dataStore.ensureUser(userId),
    dataStore.listMemories(userId),
  ]);
  const route = selectModelForInput(userMessage, false);

  if (!hasGeminiConfig()) {
    return runFallbackChat(userId, userMessage, route.model, route.tier, requireConfirmForReminder);
  }

  const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY! });
  const systemInstruction = buildSystemPrompt(user, memories);
  const executedTools: Array<{ name: string; result: Record<string, unknown> }> = [];

  try {
    const response = await ai.models.generateContent({
      model: route.model,
      contents: userMessage,
      config: {
        systemInstruction,
        tools: [{ functionDeclarations: FUNCTION_DECLARATIONS }],
      },
    });

    const calls = response.functionCalls || [];
    for (const call of calls) {
      if (!call.name) continue;
      const result = await executeToolCall(
        userId,
        call.name,
        (call.args as Record<string, unknown>) || {}
      );
      executedTools.push({ name: call.name, result });
    }

    let reply = response.text?.trim() || '';
    if (!reply && executedTools.length > 0) {
      const followUp = await ai.models.generateContent({
        model: route.model,
        contents: [
          { role: 'user', parts: [{ text: userMessage }] },
          {
            role: 'user',
            parts: [
              {
                text: `Tool results: ${JSON.stringify(executedTools)}. Respond concisely confirming what was completed.`,
              },
            ],
          },
        ],
        config: { systemInstruction },
      });
      reply = followUp.text?.trim() || 'Done.';
    }

    const totalTokens =
      (response.usageMetadata?.promptTokenCount || 300) +
      (response.usageMetadata?.candidatesTokenCount || 80);

    return {
      reply: reply || 'Done.',
      modelUsed: route.model,
      tier: route.tier,
      executedTools,
      pendingAction: null,
      tokensEstimated: totalTokens,
    };
  } catch {
    return runFallbackChat(userId, userMessage, route.model, route.tier, requireConfirmForReminder);
  }
}

async function runFallbackChat(
  userId: string,
  userMessage: string,
  modelUsed: string,
  tier: string,
  requireConfirmForReminder: boolean
): Promise<AssistantChatResponse> {
  const lower = userMessage.toLowerCase();
  const executedTools: Array<{ name: string; result: Record<string, unknown> }> = [];
  let pendingAction: Record<string, unknown> | null = null;
  let reply = 'Done.';

  if (/what am i forgetting|forgetting|kya bhool|miss/i.test(lower)) {
    const [tasks, reminders, shopping, memories] = await Promise.all([
      dataStore.listTasks(userId),
      dataStore.listReminders(userId),
      dataStore.listShopping(userId),
      dataStore.listMemories(userId),
    ]);
    const report = buildForgettingReport({ tasks, reminders, shopping, memories });
    reply = report.summary;
  } else if (/what.*today|due today|aaj kya/i.test(lower)) {
    const res = await executeToolCall(userId, 'get_today', {});
    executedTools.push({ name: 'get_today', result: res });
    const tasks = (res.tasks as Array<{ title: string }>) || [];
    const reminders = (res.reminders as Array<{ title: string }>) || [];
    const shopCount = Number(res.shopping_pending_count || 0);
    reply = `You have ${tasks.length} tasks due today, ${reminders.length} reminders, and ${shopCount} items on your shopping list.`;
  } else if (/what.*remember|yaad rakh|memories/i.test(lower)) {
    const res = await executeToolCall(userId, 'get_memory', {});
    executedTools.push({ name: 'get_memory', result: res });
    const memories = (res.memories as Array<{ title: string }>) || [];
    reply =
      memories.length === 0
        ? 'You have no saved memories yet.'
        : `Here is what I remember: ${memories
            .slice(0, 4)
            .map((m) => m.title)
            .join(', ')}.`;
  } else if (/birthday|remember that|yaad rakhna/i.test(lower)) {
    const title = userMessage.replace(/^(remember that|remember|yaad rakhna)\s*/i, '').trim();
    const res = await executeToolCall(userId, 'save_memory', {
      title: title.slice(0, 60),
      content: title,
      category: /birthday|december|march|feb/i.test(lower) ? 'dates' : 'other',
      importance: 5,
    });
    executedTools.push({ name: 'save_memory', result: res });
    reply = 'Got it. I’ll remember that.';
  } else if (/shopping|market|eggs|bread|milk|detergent|toothpaste|rice|banana|coffee/i.test(lower)) {
    const cleaned = userMessage
      .replace(/.*(add|need|buy|get|lena hai)\s+/i, '')
      .replace(/\s+(to|on|in)\s+(my\s+)?shopping\s+list.*$/i, '');
    const items = cleaned
      .split(/,|and|aur/i)
      .map((s) => s.trim())
      .filter((s) => s.length > 1);
    const added: string[] = [];
    for (const item of items) {
      const cap = item.charAt(0).toUpperCase() + item.slice(1);
      const res = await executeToolCall(userId, 'create_shopping_item', {
        item: cap,
        category: inferShoppingCategory(cap),
      });
      executedTools.push({ name: 'create_shopping_item', result: res });
      added.push(cap);
    }
    reply =
      added.length > 0
        ? `Done. I've added ${added.join(', ')} to your shopping list.`
        : 'Added to your shopping list.';
  } else if (/remind|call|meeting|appointment|yaad dila/i.test(lower)) {
    const title =
      userMessage
        .replace(/^(remind me to|please remind me to|kal meri|set a reminder to)\s*/i, '')
        .replace(/\s+(tomorrow|today|kal|at \d+.*|friday).*$/i, '')
        .trim() || 'Reminder';
    const remindAt = resolveRelativeDateTime(userMessage);
    if (requireConfirmForReminder) {
      pendingAction = {
        type: 'create_reminder',
        title: title.charAt(0).toUpperCase() + title.slice(1),
        remind_at: remindAt,
        display_time: new Date(remindAt).toLocaleString('en-US', {
          weekday: 'short',
          month: 'short',
          day: 'numeric',
          hour: 'numeric',
          minute: '2-digit',
        }),
        timezone: (await dataStore.ensureUser(userId)).timezone,
      };
      reply = 'I can set that up. Here’s what I understood:';
    } else {
      const res = await executeToolCall(userId, 'create_reminder', {
        title: title.charAt(0).toUpperCase() + title.slice(1),
        remind_at: remindAt,
      });
      executedTools.push({ name: 'create_reminder', result: res });
      reply = `Done. I've set a reminder for "${title}" on ${new Date(remindAt).toLocaleString('en-US', {
        weekday: 'short',
        hour: 'numeric',
        minute: '2-digit',
      })}.`;
    }
  } else {
    const res = await executeToolCall(userId, 'create_task', {
      title: userMessage.trim(),
      due_at: resolveRelativeDateTime(userMessage, 11),
    });
    executedTools.push({ name: 'create_task', result: res });
    reply = `Done. Added "${userMessage.trim()}" to your tasks.`;
  }

  return {
    reply,
    modelUsed: `${modelUsed} (local-nlu)`,
    tier,
    executedTools,
    pendingAction,
    tokensEstimated: 180,
  };
}

export async function runBrainDumpExtraction(
  userId: string,
  transcript: string
): Promise<{
  draftId: string;
  modelUsed: string;
  tasks: BrainDumpItemDraft[];
  reminders: BrainDumpItemDraft[];
  shopping: BrainDumpItemDraft[];
  memories: BrainDumpItemDraft[];
}> {
  const route = selectModelForInput(transcript, true);
  let extracted = fallbackParseBrainDump(transcript);

  if (hasGeminiConfig()) {
    try {
      const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY! });
      const res = await ai.models.generateContent({
        model: route.model,
        contents: `Extract structured actions from this user voice brain dump. Return ONLY valid JSON with keys: tasks, reminders, shopping, memories. Each element must have {title, subtitle, due_at, category, priority}. Transcript:\n"${transcript}"`,
        config: {
          responseMimeType: 'application/json',
        },
      });
      const raw = res.text?.trim();
      if (raw) {
        const parsed = JSON.parse(raw) as Partial<Record<'tasks' | 'reminders' | 'shopping' | 'memories', Array<Record<string, unknown>>>>;
        const mapList = (
          arr: Array<Record<string, unknown>> | undefined,
          kind: BrainDumpItemDraft['kind']
        ): BrainDumpItemDraft[] =>
          (arr || []).map((x) => ({
            id: crypto.randomUUID(),
            kind,
            title: String(x.title || ''),
            subtitle: String(x.subtitle || (kind === 'shopping' ? 'Shopping' : 'Upcoming')),
            due_at: x.due_at ? String(x.due_at) : null,
            category: x.category ? String(x.category) : undefined,
            priority: x.priority === 'high' ? 'high' : 'normal',
            selected: true,
          }));
        extracted = {
          tasks: mapList(parsed.tasks, 'task'),
          reminders: mapList(parsed.reminders, 'reminder'),
          shopping: mapList(parsed.shopping, 'shopping'),
          memories: mapList(parsed.memories, 'memory'),
        };
      }
    } catch {
      // Fallback already populated
    }
  }

  const draftId = crypto.randomUUID();
  await dataStore.saveBrainDumpDraft({
    id: draftId,
    user_id: userId,
    transcript,
    extracted_items: extracted,
    status: 'pending_review',
    created_at: new Date().toISOString(),
  });

  return {
    draftId,
    modelUsed: hasGeminiConfig() ? route.model : `${route.model} (local-nlu)`,
    ...extracted,
  };
}
