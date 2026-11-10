import crypto from 'node:crypto';
import { dataStore } from '../db/dataStore.js';
import type { BrainDumpItemDraft, MemoryItem, ReminderItem, ShoppingItem, TaskItem } from '../types/domain.js';

export function resolveRelativeDateTime(input?: string | null, defaultHour = 17): string {
  if (!input) {
    const d = new Date();
    d.setDate(d.getDate() + 1);
    d.setHours(defaultHour, 0, 0, 0);
    return d.toISOString();
  }

  const parsed = Date.parse(input);
  if (!Number.isNaN(parsed)) {
    return new Date(parsed).toISOString();
  }

  const lower = input.toLowerCase();
  const base = new Date();
  if (lower.includes('tomorrow') || lower.includes('kal')) {
    base.setDate(base.getDate() + 1);
  } else if (lower.includes('friday')) {
    const diff = (5 - base.getDay() + 7) % 7 || 7;
    base.setDate(base.getDate() + diff);
  } else if (lower.includes('next week')) {
    base.setDate(base.getDate() + 7);
  }

  const timeMatch = lower.match(/(\d{1,2})(?::(\d{2}))?\s*(am|pm)?/i);
  if (timeMatch) {
    let hour = Number(timeMatch[1]);
    const minute = Number(timeMatch[2] || 0);
    const meridiem = timeMatch[3]?.toLowerCase();
    if (meridiem === 'pm' && hour < 12) hour += 12;
    if (meridiem === 'am' && hour === 12) hour = 0;
    base.setHours(hour, minute, 0, 0);
  } else {
    base.setHours(defaultHour, 0, 0, 0);
  }
  return base.toISOString();
}

export async function executeToolCall(
  userId: string,
  name: string,
  args: Record<string, unknown>
): Promise<Record<string, unknown>> {
  const user = await dataStore.ensureUser(userId);

  switch (name) {
    case 'create_task': {
      const title = String(args.title || '').trim();
      if (!title) return { ok: false, error: 'Missing task title' };
      const dueAt = args.due_at ? resolveRelativeDateTime(String(args.due_at), 11) : null;
      const priority =
        args.priority === 'high' || args.priority === 'low' ? args.priority : 'normal';
      const task = await dataStore.createTask(userId, { title, due_at: dueAt, priority });
      return { ok: true, action: 'create_task', task };
    }

    case 'complete_task': {
      const query = String(args.task_id_or_title || args.title || '').trim();
      const tasks = await dataStore.listTasks(userId);
      const target = tasks.find(
        (t) =>
          t.status === 'pending' &&
          (t.id === query || t.title.toLowerCase().includes(query.toLowerCase()))
      );
      if (!target) return { ok: false, error: `No matching pending task for "${query}"` };
      const updated = await dataStore.updateTask(userId, target.id, {
        status: 'completed',
        completed_at: new Date().toISOString(),
      });
      return { ok: true, action: 'complete_task', task: updated };
    }

    case 'delete_task': {
      const target = String(args.task_id_or_title || args.title || '').trim();
      const deleted = await dataStore.deleteTask(userId, target);
      return { ok: deleted, action: 'delete_task', target };
    }

    case 'create_reminder':
    case 'create_event': {
      const title = String(args.title || '').trim();
      if (!title) return { ok: false, error: 'Missing reminder title' };
      const remindAt = resolveRelativeDateTime(
        String(args.remind_at || args.datetime || args.event_at || 'tomorrow 17:00')
      );
      const reminder = await dataStore.createReminder(userId, {
        title,
        remind_at: remindAt,
        person: args.person ? String(args.person) : null,
        timezone: user.timezone,
        recurring: args.recurring ? String(args.recurring) : null,
      });
      return { ok: true, action: name, reminder };
    }

    case 'delete_reminder': {
      const target = String(args.reminder_id_or_title || args.title || '').trim();
      const deleted = await dataStore.deleteReminder(userId, target);
      return { ok: deleted, action: 'delete_reminder', target };
    }

    case 'create_shopping_item': {
      const item = String(args.item || '').trim();
      if (!item) return { ok: false, error: 'Missing item name' };
      const category = args.category ? String(args.category) : inferShoppingCategory(item);
      const created = await dataStore.createShoppingItem(userId, { item, category });
      return { ok: true, action: 'create_shopping_item', shopping_item: created };
    }

    case 'remove_shopping_item': {
      const item = String(args.item || args.id || '').trim();
      const removed = await dataStore.removeShoppingItem(userId, item);
      return { ok: removed, action: 'remove_shopping_item', item };
    }

    case 'save_memory': {
      const title = String(args.title || args.content || '').trim();
      const content = String(args.content || title).trim();
      const validCategories = ['people', 'dates', 'preferences', 'projects', 'routines', 'other'];
      const category = validCategories.includes(String(args.category))
        ? (String(args.category) as MemoryItem['category'])
        : 'other';
      const memory = await dataStore.createMemory(userId, {
        title,
        content,
        category,
        importance: Number(args.importance || 4),
        event_date: args.event_date ? String(args.event_date) : null,
        subtitle: args.subtitle ? String(args.subtitle) : 'Saved via assistant',
      });
      return { ok: true, action: 'save_memory', memory };
    }

    case 'get_memory': {
      const query = args.query ? String(args.query) : undefined;
      const category = args.category ? String(args.category) : undefined;
      const memories = await dataStore.listMemories(userId, query, category);
      return { ok: true, action: 'get_memory', memories };
    }

    case 'delete_memory': {
      const target = String(args.memory_id_or_title || args.query || '').trim();
      const deleted = await dataStore.deleteMemory(userId, target);
      return { ok: deleted, action: 'delete_memory', target };
    }

    case 'get_today': {
      const [tasks, reminders, shopping] = await Promise.all([
        dataStore.listTasks(userId),
        dataStore.listReminders(userId),
        dataStore.listShopping(userId),
      ]);
      const todayStr = new Date().toISOString().slice(0, 10);
      const todayTasks = tasks.filter(
        (t) => t.status === 'pending' && (!t.due_at || t.due_at.slice(0, 10) <= todayStr)
      );
      const todayReminders = reminders.filter(
        (r) => r.status === 'upcoming' && r.remind_at.slice(0, 10) <= todayStr
      );
      const pendingShopping = shopping.filter((s) => !s.completed);
      return {
        ok: true,
        action: 'get_today',
        tasks: todayTasks,
        reminders: todayReminders,
        shopping_pending_count: pendingShopping.length,
      };
    }

    case 'get_upcoming': {
      const days = Number(args.days || 7);
      const horizon = new Date();
      horizon.setDate(horizon.getDate() + days);
      const [tasks, reminders, memories] = await Promise.all([
        dataStore.listTasks(userId),
        dataStore.listReminders(userId),
        dataStore.listMemories(userId),
      ]);
      return {
        ok: true,
        action: 'get_upcoming',
        tasks: tasks.filter(
          (t) => t.status === 'pending' && t.due_at && new Date(t.due_at) <= horizon
        ),
        reminders: reminders.filter(
          (r) => r.status === 'upcoming' && new Date(r.remind_at) <= horizon
        ),
        important_dates: memories.filter((m) => m.category === 'dates'),
      };
    }

    case 'get_overdue_tasks': {
      const now = Date.now();
      const tasks = await dataStore.listTasks(userId);
      const overdue = tasks.filter(
        (t) => t.status === 'pending' && t.due_at && Date.parse(t.due_at) < now
      );
      return { ok: true, action: 'get_overdue_tasks', overdue };
    }

    default:
      return { ok: false, error: `Unknown tool: ${name}` };
  }
}

export function inferShoppingCategory(item: string): string {
  const lower = item.toLowerCase();
  if (/milk|egg|butter|cheese|yogurt/.test(lower)) return 'Dairy & essentials';
  if (/bread|bun|cake|croissant/.test(lower)) return 'Bakery';
  if (/detergent|soap|cleaner|tissue/.test(lower)) return 'Household';
  if (/toothpaste|shampoo|brush|deodorant/.test(lower)) return 'Personal care';
  if (/fruit|apple|banana|tomato|onion|veg/.test(lower)) return 'Produce';
  return 'General';
}

export function buildForgettingReport(data: {
  tasks: TaskItem[];
  reminders: ReminderItem[];
  shopping: ShoppingItem[];
  memories: MemoryItem[];
}): { summary: string; highlights: Array<{ type: string; title: string; detail: string }> } {
  const now = new Date();
  const tomorrow = new Date(now);
  tomorrow.setDate(now.getDate() + 1);
  const tomorrowKey = tomorrow.toISOString().slice(0, 10);

  const highlights: Array<{ type: string; title: string; detail: string }> = [];

  for (const t of data.tasks.filter((x) => x.status === 'pending')) {
    if (t.due_at && Date.parse(t.due_at) < now.getTime()) {
      highlights.push({
        type: 'overdue_task',
        title: t.title,
        detail: 'Overdue task — needs attention',
      });
    } else if (t.priority === 'high') {
      highlights.push({
        type: 'high_priority_task',
        title: t.title,
        detail: 'High priority deadline',
      });
    }
  }

  for (const r of data.reminders.filter((x) => x.status === 'upcoming')) {
    if (r.remind_at.slice(0, 10) <= tomorrowKey) {
      highlights.push({
        type: 'upcoming_reminder',
        title: r.title,
        detail: new Date(r.remind_at).toLocaleString('en-US', {
          weekday: 'short',
          month: 'short',
          day: 'numeric',
          hour: 'numeric',
          minute: '2-digit',
        }),
      });
    }
  }

  const remainingShopping = data.shopping.filter((s) => !s.completed);
  if (remainingShopping.length > 0) {
    highlights.push({
      type: 'shopping',
      title: `${remainingShopping.length} items left on shopping list`,
      detail: remainingShopping.map((s) => s.item).slice(0, 4).join(', '),
    });
  }

  const importantDates = data.memories.filter((m) => m.category === 'dates').slice(0, 2);
  for (const m of importantDates) {
    highlights.push({
      type: 'memory_date',
      title: m.title,
      detail: m.subtitle || m.content,
    });
  }

  const top3 = highlights.slice(0, 3);
  const summary =
    top3.length === 0
      ? 'You are completely caught up right now.'
      : `You have ${top3.length} things you might want to handle: ${top3
          .map((h) => `${h.title} (${h.detail})`)
          .join('; ')}.`;

  return { summary, highlights };
}

export function fallbackParseBrainDump(transcript: string): {
  tasks: BrainDumpItemDraft[];
  reminders: BrainDumpItemDraft[];
  shopping: BrainDumpItemDraft[];
  memories: BrainDumpItemDraft[];
} {
  const tasks: BrainDumpItemDraft[] = [];
  const reminders: BrainDumpItemDraft[] = [];
  const shopping: BrainDumpItemDraft[] = [];
  const memories: BrainDumpItemDraft[] = [];

  const clauses = transcript
    .split(/[,.;\n]+|\band\b|\baur\b/i)
    .map((c) => c.trim())
    .filter(Boolean);

  for (const clause of clauses) {
    const lower = clause.toLowerCase();
    if (/birthday|anniversary|remember|yaad rakh/i.test(lower)) {
      memories.push({
        id: crypto.randomUUID(),
        kind: 'memory',
        title: clause,
        subtitle: 'Important date / memory',
        category: 'dates',
        selected: true,
      });
    } else if (/call|remind|meeting|appointment|yaad dil/i.test(lower)) {
      reminders.push({
        id: crypto.randomUUID(),
        kind: 'reminder',
        title: clause.replace(/^(remind me to|call|yaad dilana)\s*/i, '').trim() || clause,
        subtitle: /tomorrow|kal/i.test(lower) ? 'Tomorrow at 5:00 PM' : 'Upcoming reminder',
        due_at: resolveRelativeDateTime(lower),
        selected: true,
      });
    } else if (/buy|eggs|bread|milk|detergent|toothpaste|grocer|market|lena hai/i.test(lower)) {
      const cleaned = clause
        .replace(/^(buy|get|pick up|add|need|market se)\s*/i, '')
        .replace(/\blena hai\b/i, '')
        .trim();
      if (cleaned) {
        shopping.push({
          id: crypto.randomUUID(),
          kind: 'shopping',
          title: cleaned.charAt(0).toUpperCase() + cleaned.slice(1),
          subtitle: inferShoppingCategory(cleaned),
          category: inferShoppingCategory(cleaned),
          selected: true,
        });
      }
    } else if (clause.length > 3) {
      tasks.push({
        id: crypto.randomUUID(),
        kind: 'task',
        title: clause.charAt(0).toUpperCase() + clause.slice(1),
        subtitle: /friday/i.test(lower) ? 'Friday' : 'Tomorrow',
        due_at: resolveRelativeDateTime(lower, 11),
        priority: /client|deliver|website|urgent/i.test(lower) ? 'high' : 'normal',
        selected: true,
      });
    }
  }

  return { tasks, reminders, shopping, memories };
}
