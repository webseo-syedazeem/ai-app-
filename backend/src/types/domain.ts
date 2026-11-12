export type PlanTier = 'free' | 'plus' | 'pro';
export type AssistantTone = 'friendly' | 'professional' | 'concise';
export type TaskPriority = 'low' | 'normal' | 'high';
export type TaskStatus = 'pending' | 'completed' | 'archived';
export type ReminderStatus = 'upcoming' | 'completed' | 'cancelled';
export type MemoryCategory = 'people' | 'dates' | 'preferences' | 'projects' | 'routines' | 'other';
export type MemoryTier = 'short_term' | 'long_term';

export interface UserProfile {
  id: string;
  email: string;
  full_name: string;
  password_hash?: string;
  plan: PlanTier;
  ai_credits: number;
  daily_actions_used: number;
  daily_actions_date: string;
  monthly_actions_used: number;
  voice_seconds_used: number;
  usage_month: string;
  preferred_tone: AssistantTone;
  focus_areas: string[];
  helper_context: string;
  timezone: string;
  push_notifications_enabled: boolean;
  onboarding_completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface TaskItem {
  id: string;
  user_id: string;
  title: string;
  notes: string;
  due_at: string | null;
  priority: TaskPriority;
  status: TaskStatus;
  completed_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface ReminderItem {
  id: string;
  user_id: string;
  title: string;
  person: string | null;
  remind_at: string;
  timezone: string;
  recurring: string | null;
  status: ReminderStatus;
  created_at: string;
  updated_at: string;
}

export interface ShoppingItem {
  id: string;
  user_id: string;
  item: string;
  category: string;
  completed: boolean;
  completed_at: string | null;
  created_at: string;
}

export interface MemoryItem {
  id: string;
  user_id: string;
  title: string;
  content: string;
  category: MemoryCategory;
  memory_tier: MemoryTier;
  importance: number;
  event_date: string | null;
  subtitle: string;
  created_at: string;
  updated_at: string;
}

export interface KeepForLaterItem {
  id: string;
  user_id: string;
  title: string;
  notes: string;
  status: 'inbox' | 'moved' | 'archived';
  moved_memory_id: string | null;
  captured_at: string;
}

export interface GoalItem {
  id: string;
  user_id: string;
  title: string;
  category: string;
  current_value: number;
  target_value: number;
  unit_label: string;
  period: 'week' | 'month';
  completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface AffirmationItem {
  id: string;
  user_id: string;
  quote: string;
  reminder_label: string;
  saved_at: string;
}

export interface ChatMessage {
  id: string;
  conversation_id: string;
  user_id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  pending_action: Record<string, unknown> | null;
  action_confirmed: boolean;
  model_used: string | null;
  created_at: string;
}

export interface BrainDumpItemDraft {
  id: string;
  kind: 'task' | 'reminder' | 'shopping' | 'memory';
  title: string;
  subtitle: string;
  due_at?: string | null;
  priority?: TaskPriority;
  category?: string;
  selected: boolean;
}

export interface BrainDumpDraft {
  id: string;
  user_id: string;
  transcript: string;
  extracted_items: {
    tasks: BrainDumpItemDraft[];
    reminders: BrainDumpItemDraft[];
    shopping: BrainDumpItemDraft[];
    memories: BrainDumpItemDraft[];
  };
  status: 'pending_review' | 'saved' | 'discarded';
  created_at: string;
}

export interface UsageLog {
  id: string;
  user_id: string;
  month_key: string;
  action_type: string;
  model_name: string;
  ai_tokens: number;
  voice_seconds: number;
  created_at: string;
}

export interface ExpenseItem {
  id: string;
  user_id: string;
  budget_id: string | null;
  category: string;
  title: string;
  amount: number;
  period?: 'daily' | 'monthly';
  folder_id?: string | null;
  folder_name?: string | null;
  spent_at: string;
}

export interface BudgetFolder {
  id: string;
  user_id: string;
  name: string;
  period: 'daily' | 'monthly' | 'all';
  tone: string;
  reminder_label?: string | null;
  reminder_id?: string | null;
  created_at: string;
}

export interface BudgetInfo {
  id: string;
  user_id: string;
  month_key: string;
  currency: string;
  monthly_limit: number;
  daily_limit?: number;
  created_at: string;
}

export interface EmailReportPrefs {
  user_id: string;
  enabled: boolean;
  weekly_summary_enabled: boolean;
  monthly_review_enabled: boolean;
  updated_at: string;
}

export interface PasswordResetToken {
  id: string;
  user_id: string;
  email: string;
  code_hash: string;
  expires_at: string;
  created_at: string;
}
