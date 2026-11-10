import { env } from '../config/env.js';
import type { AssistantTone, MemoryItem, UserProfile } from '../types/domain.js';

export type ComplexityTier = 'simple' | 'complex';

export interface RouteDecision {
  tier: ComplexityTier;
  model: string;
  reason: string;
}

export function selectModelForInput(text: string, isBrainDump = false): RouteDecision {
  if (isBrainDump) {
    return {
      tier: 'complex',
      model: env.geminiComplexModel,
      reason: 'brain_dump_multi_extraction',
    };
  }

  const trimmed = text.trim();
  const wordCount = trimmed.split(/\s+/).length;
  const multiClause = (trimmed.match(/,|and|aur|then|also|phir/gi) || []).length >= 2;
  const complexKeywords =
    /forgetting|plan|organize|schedule|briefing|summary|trip|project|brain dump/i.test(trimmed);

  if (wordCount > 24 || multiClause || complexKeywords) {
    return {
      tier: 'complex',
      model: env.geminiComplexModel,
      reason: 'multi_step_or_planning_request',
    };
  }

  return {
    tier: 'simple',
    model: env.geminiLiteModel,
    reason: 'single_intent_or_quick_query',
  };
}

export function buildSystemPrompt(user: UserProfile, memories: MemoryItem[]): string {
  const toneInstruction: Record<AssistantTone, string> = {
    friendly: 'Warm, reassuring, and natural.',
    professional: 'Crisp, structured, and businesslike.',
    concise: 'Ultra-brief, direct confirmations with zero fluff.',
  };

  const memoryBlock =
    memories.length === 0
      ? 'No long-term memories saved yet.'
      : memories
          .slice(0, 12)
          .map((m) => `- [${m.category}] ${m.title}: ${m.content}`)
          .join('\n');

  return [
    'You are the user’s personal daily assistant ("AI Daily Helper").',
    `User name: ${user.full_name || 'User'} | Timezone: ${user.timezone}`,
    `Preferred tone: ${user.preferred_tone} — ${toneInstruction[user.preferred_tone]}`,
    user.helper_context ? `User focus note: ${user.helper_context}` : '',
    '',
    'Your job is to help the user organize everyday life across English and Roman Urdu.',
    'You can create/complete/delete tasks, create/delete reminders and events, manage shopping items, save/retrieve/delete memories, and check today/upcoming/overdue items using the provided tools.',
    'Never invent actions that were not completed via a tool call.',
    'Keep responses concise (1–2 short sentences). Do not unnecessarily explain what you are doing.',
    'You are an assistant that helps the user take action, not merely a chatbot.',
    '',
    'Relevant user memories:',
    memoryBlock,
  ]
    .filter(Boolean)
    .join('\n');
}
