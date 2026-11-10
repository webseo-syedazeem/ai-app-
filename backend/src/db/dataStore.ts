import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import { hasMongoConfig } from '../config/env.js';
import { getMongoDb } from './mongoClient.js';
import type {
  AffirmationItem,
  BrainDumpDraft,
  BudgetInfo,
  ChatMessage,
  EmailReportPrefs,
  ExpenseItem,
  GoalItem,
  KeepForLaterItem,
  MemoryItem,
  ReminderItem,
  ShoppingItem,
  TaskItem,
  UsageLog,
  UserProfile,
} from '../types/domain.js';

export const DEFAULT_USER_ID = '00000000-0000-0000-0000-000000000001';

interface LocalSnapshot {
  users: Record<string, UserProfile>;
  tasks: TaskItem[];
  reminders: ReminderItem[];
  shopping_items: ShoppingItem[];
  memories: MemoryItem[];
  keep_for_later: KeepForLaterItem[];
  goals: GoalItem[];
  affirmations: AffirmationItem[];
  messages: ChatMessage[];
  brain_dump_drafts: BrainDumpDraft[];
  usage_logs: UsageLog[];
  budgets: BudgetInfo[];
  expenses: ExpenseItem[];
  email_report_preferences: Record<string, EmailReportPrefs>;
}

const DATA_DIR =
  process.env.VERCEL === '1'
    ? path.join(os.tmpdir(), 'ai-daily-helper-data')
    : path.resolve(process.cwd(), '.data');
const DATA_FILE = path.join(DATA_DIR, 'dev-store.json');

function nowIso(): string {
  return new Date().toISOString();
}

function monthKey(date = new Date()): string {
  return date.toISOString().slice(0, 7);
}

function todayDateKey(date = new Date()): string {
  return date.toISOString().slice(0, 10);
}

function futureIso(daysOffset: number, hour: number, minute = 0): string {
  const d = new Date();
  d.setDate(d.getDate() + daysOffset);
  d.setHours(hour, minute, 0, 0);
  return d.toISOString();
}

function createInitialSnapshot(): LocalSnapshot {
  const uid = DEFAULT_USER_ID;
  const now = nowIso();
  const mk = monthKey();
  const budgetId = crypto.randomUUID();
  const convId = crypto.randomUUID();

  return {
    users: {
      [uid]: {
        id: uid,
        email: 'azeem@example.com',
        full_name: 'Azeem',
        plan: 'plus',
        ai_credits: 1000,
        daily_actions_used: 0,
        daily_actions_date: todayDateKey(),
        monthly_actions_used: 14,
        voice_seconds_used: 420,
        usage_month: mk,
        preferred_tone: 'friendly',
        focus_areas: ['work', 'shopping', 'personal'],
        helper_context:
          'Help me stay on top of work, remember appointments and organize errands.',
        timezone: 'Asia/Karachi',
        push_notifications_enabled: true,
        onboarding_completed: true,
        created_at: now,
        updated_at: now,
      },
    },
    tasks: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Send client proposal',
        notes: 'Final PDF with timeline',
        due_at: futureIso(0, 11, 0),
        priority: 'high',
        status: 'pending',
        completed_at: null,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Review homepage design',
        notes: '',
        due_at: futureIso(0, 15, 30),
        priority: 'normal',
        status: 'pending',
        completed_at: null,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Book car service',
        notes: 'Oil change + filter check',
        due_at: futureIso(1, 10, 0),
        priority: 'normal',
        status: 'pending',
        completed_at: null,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Plan weekend groceries',
        notes: '',
        due_at: futureIso(2, 18, 0),
        priority: 'normal',
        status: 'pending',
        completed_at: null,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Finish project handover',
        notes: '',
        due_at: futureIso(3, 16, 0),
        priority: 'high',
        status: 'pending',
        completed_at: null,
        created_at: now,
        updated_at: now,
      },
    ],
    reminders: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Call Ali',
        person: 'Ali',
        remind_at: futureIso(1, 17, 0),
        timezone: 'Asia/Karachi',
        recurring: null,
        status: 'upcoming',
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Dentist appointment',
        person: null,
        remind_at: futureIso(2, 16, 0),
        timezone: 'Asia/Karachi',
        recurring: null,
        status: 'upcoming',
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Send final website',
        person: 'Client',
        remind_at: futureIso(3, 11, 0),
        timezone: 'Asia/Karachi',
        recurring: null,
        status: 'upcoming',
        created_at: now,
        updated_at: now,
      },
    ],
    shopping_items: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        item: 'Eggs',
        category: 'Dairy & essentials',
        completed: false,
        completed_at: null,
        created_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        item: 'Bread',
        category: 'Bakery',
        completed: false,
        completed_at: null,
        created_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        item: 'Detergent',
        category: 'Household',
        completed: false,
        completed_at: null,
        created_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        item: 'Toothpaste',
        category: 'Personal care',
        completed: false,
        completed_at: null,
        created_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        item: 'Milk',
        category: 'Dairy & essentials',
        completed: true,
        completed_at: now,
        created_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        item: 'Fruit',
        category: 'Produce',
        completed: true,
        completed_at: now,
        created_at: now,
      },
    ],
    memories: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Mom’s birthday',
        content: 'Mom’s birthday is on March 5.',
        category: 'dates',
        memory_tier: 'long_term',
        importance: 5,
        event_date: '2026-03-05',
        subtitle: 'March 5 · Saved by you',
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Project kickoff',
        content: 'Project kickoff scheduled Feb 10 at 10:00 AM.',
        category: 'dates',
        memory_tier: 'long_term',
        importance: 4,
        event_date: '2026-02-10',
        subtitle: 'Feb 10 · 10:00 AM',
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Ali’s contact number',
        content: 'Ali — +92 300 1234567 (Personal)',
        category: 'people',
        memory_tier: 'long_term',
        importance: 4,
        event_date: null,
        subtitle: 'Saved yesterday · Personal',
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Preferred meeting hours',
        content: 'Weekdays after 10 AM',
        category: 'preferences',
        memory_tier: 'long_term',
        importance: 4,
        event_date: null,
        subtitle: 'Weekdays after 10 AM',
        created_at: now,
        updated_at: now,
      },
    ],
    keep_for_later: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Article about building better habits',
        notes: 'Read and summarize key takeaways',
        status: 'inbox',
        moved_memory_id: null,
        captured_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Weekend trip idea',
        notes: 'Check hotel availability for Islamabad',
        status: 'inbox',
        moved_memory_id: null,
        captured_at: futureIso(-1, 19, 15),
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Ask Sara about the new course',
        notes: '',
        status: 'inbox',
        moved_memory_id: null,
        captured_at: futureIso(-4, 14, 20),
      },
    ],
    goals: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Complete 3 work tasks',
        category: 'work',
        current_value: 2,
        target_value: 3,
        unit_label: 'complete',
        period: 'week',
        completed: false,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Read for 30 minutes',
        category: 'learning',
        current_value: 3,
        target_value: 7,
        unit_label: 'days',
        period: 'week',
        completed: false,
        created_at: now,
        updated_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        title: 'Organize shopping',
        category: 'shopping',
        current_value: 1,
        target_value: 1,
        unit_label: 'Completed',
        period: 'week',
        completed: true,
        created_at: now,
        updated_at: now,
      },
    ],
    affirmations: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        quote: '“I will finish what I start, one step at a time.”',
        reminder_label: 'Saved Nov 8, 2026',
        saved_at: futureIso(-2, 9, 0),
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        quote: '“Progress matters more than perfection.”',
        reminder_label: 'Saved Nov 3, 2026',
        saved_at: futureIso(-7, 9, 0),
      },
    ],
    messages: [
      {
        id: crypto.randomUUID(),
        conversation_id: convId,
        user_id: uid,
        role: 'user',
        content: 'Remind me to call Ali tomorrow at 5 PM.',
        pending_action: null,
        action_confirmed: true,
        model_used: null,
        created_at: now,
      },
      {
        id: crypto.randomUUID(),
        conversation_id: convId,
        user_id: uid,
        role: 'assistant',
        content: 'I can set that up. Here’s what I understood:',
        pending_action: {
          type: 'create_reminder',
          title: 'Call Ali',
          remind_at: futureIso(1, 17, 0),
          display_time: 'Wed, Nov 11 · 5:00 PM',
          timezone: 'Asia/Karachi',
        },
        action_confirmed: false,
        model_used: 'gemini-2.5-flash-lite',
        created_at: now,
      },
    ],
    brain_dump_drafts: [],
    usage_logs: [],
    budgets: [
      {
        id: budgetId,
        user_id: uid,
        month_key: mk,
        currency: 'Rs.',
        monthly_limit: 45000,
        created_at: now,
      },
    ],
    expenses: [
      {
        id: crypto.randomUUID(),
        user_id: uid,
        budget_id: budgetId,
        category: 'Groceries',
        title: 'Weekly groceries',
        amount: 8500,
        spent_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        budget_id: budgetId,
        category: 'Bills',
        title: 'Electricity & internet',
        amount: 6250,
        spent_at: now,
      },
      {
        id: crypto.randomUUID(),
        user_id: uid,
        budget_id: budgetId,
        category: 'Personal',
        title: 'Coffee & dining',
        amount: 3500,
        spent_at: now,
      },
    ],
    email_report_preferences: {
      [uid]: {
        user_id: uid,
        enabled: false,
        weekly_summary_enabled: true,
        monthly_review_enabled: true,
        updated_at: now,
      },
    },
  };
}

class LocalStore {
  private snapshot: LocalSnapshot;

  constructor() {
    if (fs.existsSync(DATA_FILE)) {
      try {
        this.snapshot = JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8')) as LocalSnapshot;
      } catch {
        this.snapshot = createInitialSnapshot();
        this.persist();
      }
    } else {
      this.snapshot = createInitialSnapshot();
      this.persist();
    }
  }

  private persist(): void {
    fs.mkdirSync(DATA_DIR, { recursive: true });
    fs.writeFileSync(DATA_FILE, JSON.stringify(this.snapshot, null, 2), 'utf-8');
  }

  read(): LocalSnapshot {
    return this.snapshot;
  }

  save(): void {
    this.persist();
  }

  resetUser(userId: string): void {
    this.snapshot.tasks = this.snapshot.tasks.filter((t) => t.user_id !== userId);
    this.snapshot.reminders = this.snapshot.reminders.filter((r) => r.user_id !== userId);
    this.snapshot.shopping_items = this.snapshot.shopping_items.filter((s) => s.user_id !== userId);
    this.snapshot.memories = this.snapshot.memories.filter((m) => m.user_id !== userId);
    this.snapshot.keep_for_later = this.snapshot.keep_for_later.filter((k) => k.user_id !== userId);
    this.snapshot.goals = this.snapshot.goals.filter((g) => g.user_id !== userId);
    this.snapshot.affirmations = this.snapshot.affirmations.filter((a) => a.user_id !== userId);
    this.snapshot.messages = this.snapshot.messages.filter((m) => m.user_id !== userId);
    this.snapshot.brain_dump_drafts = this.snapshot.brain_dump_drafts.filter((d) => d.user_id !== userId);
    this.snapshot.expenses = this.snapshot.expenses.filter((e) => e.user_id !== userId);
    this.persist();
  }
}

function stripMongoId<T>(doc: T): T {
  const copy = { ...(doc as Record<string, unknown>) };
  delete copy._id;
  return copy as T;
}

export class DataStore {
  private local = new LocalStore();

  isUsingMongo(): boolean {
    return hasMongoConfig();
  }

  async ensureUser(userId: string): Promise<UserProfile> {
    const db = await getMongoDb();
    if (db) {
      const existing = await db.collection<UserProfile>('users').findOne({ id: userId });
      if (existing) return stripMongoId(existing);

      const now = nowIso();
      const fresh: UserProfile = {
        id: userId,
        email: `${userId.slice(0, 8)}@example.com`,
        full_name: 'Azeem',
        plan: 'free',
        ai_credits: 5,
        daily_actions_used: 0,
        daily_actions_date: todayDateKey(),
        monthly_actions_used: 0,
        voice_seconds_used: 0,
        usage_month: monthKey(),
        preferred_tone: 'friendly',
        focus_areas: ['work', 'shopping', 'personal'],
        helper_context: '',
        timezone: 'Asia/Karachi',
        push_notifications_enabled: true,
        onboarding_completed: false,
        created_at: now,
        updated_at: now,
      };
      await db.collection<UserProfile>('users').insertOne({ ...fresh });
      return fresh;
    }

    const snap = this.local.read();
    if (!snap.users[userId]) {
      const now = nowIso();
      snap.users[userId] = {
        id: userId,
        email: 'user@example.com',
        full_name: 'Azeem',
        plan: 'free',
        ai_credits: 5,
        daily_actions_used: 0,
        daily_actions_date: todayDateKey(),
        monthly_actions_used: 0,
        voice_seconds_used: 0,
        usage_month: monthKey(),
        preferred_tone: 'friendly',
        focus_areas: ['work', 'shopping', 'personal'],
        helper_context: '',
        timezone: 'Asia/Karachi',
        push_notifications_enabled: true,
        onboarding_completed: false,
        created_at: now,
        updated_at: now,
      };
      this.local.save();
    }
    return snap.users[userId];
  }

  async updateUser(userId: string, patch: Partial<UserProfile>): Promise<UserProfile> {
    const current = await this.ensureUser(userId);
    const updated: UserProfile = {
      ...current,
      ...patch,
      updated_at: nowIso(),
    };
    const db = await getMongoDb();
    if (db) {
      await db
        .collection<UserProfile>('users')
        .updateOne({ id: userId }, { $set: { ...patch, updated_at: updated.updated_at } });
      return updated;
    }
    this.local.read().users[userId] = updated;
    this.local.save();
    return updated;
  }

  // ---------------- TASKS ----------------
  async listTasks(userId: string): Promise<TaskItem[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<TaskItem>('tasks')
        .find({ user_id: userId })
        .sort({ due_at: 1 })
        .toArray();
      return docs.map(stripMongoId);
    }
    return this.local
      .read()
      .tasks.filter((t) => t.user_id === userId)
      .sort((a, b) => (a.due_at || '9999').localeCompare(b.due_at || '9999'));
  }

  async createTask(
    userId: string,
    input: { title: string; due_at?: string | null; priority?: 'low' | 'normal' | 'high'; notes?: string }
  ): Promise<TaskItem> {
    const now = nowIso();
    const row: TaskItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      title: input.title,
      notes: input.notes || '',
      due_at: input.due_at ?? null,
      priority: input.priority || 'normal',
      status: 'pending',
      completed_at: null,
      created_at: now,
      updated_at: now,
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<TaskItem>('tasks').insertOne({ ...row });
      return row;
    }
    this.local.read().tasks.push(row);
    this.local.save();
    return row;
  }

  async updateTask(userId: string, taskId: string, patch: Partial<TaskItem>): Promise<TaskItem | null> {
    const db = await getMongoDb();
    if (db) {
      const res = await db.collection<TaskItem>('tasks').findOneAndUpdate(
        { id: taskId, user_id: userId },
        { $set: { ...patch, updated_at: nowIso() } },
        { returnDocument: 'after' }
      );
      return res ? stripMongoId(res) : null;
    }
    const list = this.local.read().tasks;
    const idx = list.findIndex((t) => t.id === taskId && t.user_id === userId);
    if (idx === -1) return null;
    list[idx] = { ...list[idx], ...patch, updated_at: nowIso() };
    this.local.save();
    return list[idx];
  }

  async deleteTask(userId: string, taskIdOrTitle: string): Promise<boolean> {
    const tasks = await this.listTasks(userId);
    const match = tasks.find(
      (t) =>
        t.id === taskIdOrTitle ||
        t.title.toLowerCase().includes(taskIdOrTitle.toLowerCase())
    );
    if (!match) return false;
    const db = await getMongoDb();
    if (db) {
      await db.collection<TaskItem>('tasks').deleteOne({ id: match.id, user_id: userId });
      return true;
    }
    const snap = this.local.read();
    snap.tasks = snap.tasks.filter((t) => t.id !== match.id);
    this.local.save();
    return true;
  }

  // ---------------- REMINDERS ----------------
  async listReminders(userId: string): Promise<ReminderItem[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<ReminderItem>('reminders')
        .find({ user_id: userId })
        .sort({ remind_at: 1 })
        .toArray();
      return docs.map(stripMongoId);
    }
    return this.local
      .read()
      .reminders.filter((r) => r.user_id === userId)
      .sort((a, b) => a.remind_at.localeCompare(b.remind_at));
  }

  async createReminder(
    userId: string,
    input: { title: string; remind_at: string; person?: string | null; timezone?: string; recurring?: string | null }
  ): Promise<ReminderItem> {
    const now = nowIso();
    const row: ReminderItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      title: input.title,
      person: input.person ?? null,
      remind_at: input.remind_at,
      timezone: input.timezone || 'Asia/Karachi',
      recurring: input.recurring ?? null,
      status: 'upcoming',
      created_at: now,
      updated_at: now,
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<ReminderItem>('reminders').insertOne({ ...row });
      return row;
    }
    this.local.read().reminders.push(row);
    this.local.save();
    return row;
  }

  async updateReminder(
    userId: string,
    reminderId: string,
    patch: Partial<ReminderItem>
  ): Promise<ReminderItem | null> {
    const db = await getMongoDb();
    if (db) {
      const res = await db.collection<ReminderItem>('reminders').findOneAndUpdate(
        { id: reminderId, user_id: userId },
        { $set: { ...patch, updated_at: nowIso() } },
        { returnDocument: 'after' }
      );
      return res ? stripMongoId(res) : null;
    }
    const list = this.local.read().reminders;
    const idx = list.findIndex((r) => r.id === reminderId && r.user_id === userId);
    if (idx === -1) return null;
    list[idx] = { ...list[idx], ...patch, updated_at: nowIso() };
    this.local.save();
    return list[idx];
  }

  async deleteReminder(userId: string, reminderIdOrTitle: string): Promise<boolean> {
    const list = await this.listReminders(userId);
    const match = list.find(
      (r) =>
        r.id === reminderIdOrTitle ||
        r.title.toLowerCase().includes(reminderIdOrTitle.toLowerCase())
    );
    if (!match) return false;
    const db = await getMongoDb();
    if (db) {
      await db.collection<ReminderItem>('reminders').deleteOne({ id: match.id, user_id: userId });
      return true;
    }
    const snap = this.local.read();
    snap.reminders = snap.reminders.filter((r) => r.id !== match.id);
    this.local.save();
    return true;
  }

  // ---------------- SHOPPING ----------------
  async listShopping(userId: string): Promise<ShoppingItem[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<ShoppingItem>('shopping_items')
        .find({ user_id: userId })
        .sort({ created_at: -1 })
        .toArray();
      return docs.map(stripMongoId);
    }
    return this.local.read().shopping_items.filter((s) => s.user_id === userId);
  }

  async createShoppingItem(
    userId: string,
    input: { item: string; category?: string }
  ): Promise<ShoppingItem> {
    const row: ShoppingItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      item: input.item,
      category: input.category || 'General',
      completed: false,
      completed_at: null,
      created_at: nowIso(),
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<ShoppingItem>('shopping_items').insertOne({ ...row });
      return row;
    }
    this.local.read().shopping_items.unshift(row);
    this.local.save();
    return row;
  }

  async toggleShoppingItem(userId: string, itemId: string, completed: boolean): Promise<ShoppingItem | null> {
    const patch = { completed, completed_at: completed ? nowIso() : null };
    const db = await getMongoDb();
    if (db) {
      const res = await db.collection<ShoppingItem>('shopping_items').findOneAndUpdate(
        { id: itemId, user_id: userId },
        { $set: patch },
        { returnDocument: 'after' }
      );
      return res ? stripMongoId(res) : null;
    }
    const list = this.local.read().shopping_items;
    const idx = list.findIndex((s) => s.id === itemId && s.user_id === userId);
    if (idx === -1) return null;
    list[idx] = { ...list[idx], ...patch };
    this.local.save();
    return list[idx];
  }

  async removeShoppingItem(userId: string, idOrName: string): Promise<boolean> {
    const items = await this.listShopping(userId);
    const match = items.find(
      (s) => s.id === idOrName || s.item.toLowerCase() === idOrName.toLowerCase()
    );
    if (!match) return false;
    const db = await getMongoDb();
    if (db) {
      await db.collection<ShoppingItem>('shopping_items').deleteOne({ id: match.id, user_id: userId });
      return true;
    }
    const snap = this.local.read();
    snap.shopping_items = snap.shopping_items.filter((s) => s.id !== match.id);
    this.local.save();
    return true;
  }

  // ---------------- MEMORIES ----------------
  async listMemories(userId: string, query?: string, category?: string): Promise<MemoryItem[]> {
    let items: MemoryItem[];
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<MemoryItem>('memories')
        .find({ user_id: userId })
        .sort({ importance: -1 })
        .toArray();
      items = docs.map(stripMongoId);
    } else {
      items = this.local.read().memories.filter((m) => m.user_id === userId);
    }

    if (category && category !== 'all') {
      items = items.filter((m) => m.category === category);
    }
    if (query && query.trim()) {
      const q = query.trim().toLowerCase();
      items = items.filter(
        (m) =>
          m.title.toLowerCase().includes(q) ||
          m.content.toLowerCase().includes(q) ||
          m.subtitle.toLowerCase().includes(q)
      );
    }
    return items;
  }

  async createMemory(
    userId: string,
    input: {
      title: string;
      content: string;
      category?: MemoryItem['category'];
      memory_tier?: MemoryItem['memory_tier'];
      importance?: number;
      event_date?: string | null;
      subtitle?: string;
    }
  ): Promise<MemoryItem> {
    const now = nowIso();
    const row: MemoryItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      title: input.title,
      content: input.content,
      category: input.category || 'other',
      memory_tier: input.memory_tier || 'long_term',
      importance: input.importance || 4,
      event_date: input.event_date ?? null,
      subtitle: input.subtitle || 'Saved by you',
      created_at: now,
      updated_at: now,
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<MemoryItem>('memories').insertOne({ ...row });
      return row;
    }
    this.local.read().memories.unshift(row);
    this.local.save();
    return row;
  }

  async deleteMemory(userId: string, memoryIdOrTitle: string): Promise<boolean> {
    const list = await this.listMemories(userId);
    const match = list.find(
      (m) =>
        m.id === memoryIdOrTitle ||
        m.title.toLowerCase().includes(memoryIdOrTitle.toLowerCase()) ||
        m.content.toLowerCase().includes(memoryIdOrTitle.toLowerCase())
    );
    if (!match) return false;
    const db = await getMongoDb();
    if (db) {
      await db.collection<MemoryItem>('memories').deleteOne({ id: match.id, user_id: userId });
      return true;
    }
    const snap = this.local.read();
    snap.memories = snap.memories.filter((m) => m.id !== match.id);
    this.local.save();
    return true;
  }

  async clearMemories(userId: string): Promise<void> {
    const db = await getMongoDb();
    if (db) {
      await db.collection<MemoryItem>('memories').deleteMany({ user_id: userId });
      return;
    }
    const snap = this.local.read();
    snap.memories = snap.memories.filter((m) => m.user_id !== userId);
    this.local.save();
  }

  // ---------------- KEEP FOR LATER ----------------
  async listKeepForLater(userId: string): Promise<KeepForLaterItem[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<KeepForLaterItem>('keep_for_later')
        .find({ user_id: userId, status: 'inbox' })
        .sort({ captured_at: -1 })
        .toArray();
      return docs.map(stripMongoId);
    }
    return this.local
      .read()
      .keep_for_later.filter((k) => k.user_id === userId && k.status === 'inbox');
  }

  async addKeepForLater(userId: string, title: string, notes = ''): Promise<KeepForLaterItem> {
    const row: KeepForLaterItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      title,
      notes,
      status: 'inbox',
      moved_memory_id: null,
      captured_at: nowIso(),
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<KeepForLaterItem>('keep_for_later').insertOne({ ...row });
      return row;
    }
    this.local.read().keep_for_later.unshift(row);
    this.local.save();
    return row;
  }

  async moveKeepItemToMemory(userId: string, itemId: string): Promise<MemoryItem | null> {
    const items = await this.listKeepForLater(userId);
    const target = items.find((k) => k.id === itemId);
    if (!target) return null;
    const memory = await this.createMemory(userId, {
      title: target.title,
      content: target.notes || target.title,
      category: 'preferences',
      subtitle: 'Moved from Keep for later',
    });
    const db = await getMongoDb();
    if (db) {
      await db
        .collection<KeepForLaterItem>('keep_for_later')
        .updateOne({ id: itemId, user_id: userId }, { $set: { status: 'moved', moved_memory_id: memory.id } });
    } else {
      const row = this.local.read().keep_for_later.find((k) => k.id === itemId);
      if (row) {
        row.status = 'moved';
        row.moved_memory_id = memory.id;
        this.local.save();
      }
    }
    return memory;
  }

  // ---------------- GOALS & AFFIRMATIONS ----------------
  async listGoals(userId: string): Promise<GoalItem[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db.collection<GoalItem>('goals').find({ user_id: userId }).toArray();
      return docs.map(stripMongoId);
    }
    return this.local.read().goals.filter((g) => g.user_id === userId);
  }

  async createGoal(
    userId: string,
    input: { title: string; target_value: number; unit_label: string; period?: 'week' | 'month'; category?: string }
  ): Promise<GoalItem> {
    const now = nowIso();
    const row: GoalItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      title: input.title,
      category: input.category || 'work',
      current_value: 0,
      target_value: Math.max(1, input.target_value),
      unit_label: input.unit_label,
      period: input.period || 'week',
      completed: false,
      created_at: now,
      updated_at: now,
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<GoalItem>('goals').insertOne({ ...row });
      return row;
    }
    this.local.read().goals.push(row);
    this.local.save();
    return row;
  }

  async incrementGoal(userId: string, goalId: string): Promise<GoalItem | null> {
    const list = await this.listGoals(userId);
    const target = list.find((g) => g.id === goalId);
    if (!target) return null;
    const next = Math.min(target.target_value, target.current_value + 1);
    const completed = next >= target.target_value;
    const db = await getMongoDb();
    if (db) {
      const res = await db.collection<GoalItem>('goals').findOneAndUpdate(
        { id: goalId, user_id: userId },
        { $set: { current_value: next, completed, updated_at: nowIso() } },
        { returnDocument: 'after' }
      );
      return res ? stripMongoId(res) : null;
    }
    target.current_value = next;
    target.completed = completed;
    target.updated_at = nowIso();
    this.local.save();
    return target;
  }

  async listAffirmations(userId: string): Promise<AffirmationItem[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<AffirmationItem>('affirmations')
        .find({ user_id: userId })
        .sort({ saved_at: -1 })
        .toArray();
      return docs.map(stripMongoId);
    }
    return this.local.read().affirmations.filter((a) => a.user_id === userId);
  }

  async addAffirmation(userId: string, quote: string): Promise<AffirmationItem> {
    const now = nowIso();
    const row: AffirmationItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      quote: quote.startsWith('“') ? quote : `“${quote}”`,
      reminder_label: `Saved ${new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`,
      saved_at: now,
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<AffirmationItem>('affirmations').insertOne({ ...row });
      return row;
    }
    this.local.read().affirmations.unshift(row);
    this.local.save();
    return row;
  }

  // ---------------- MESSAGES & BRAIN DUMPS ----------------
  async listMessages(userId: string): Promise<ChatMessage[]> {
    const db = await getMongoDb();
    if (db) {
      const docs = await db
        .collection<ChatMessage>('conversation_messages')
        .find({ user_id: userId })
        .sort({ created_at: 1 })
        .toArray();
      return docs.map(stripMongoId);
    }
    return this.local.read().messages.filter((m) => m.user_id === userId);
  }

  async addMessage(msg: Omit<ChatMessage, 'id' | 'created_at'>): Promise<ChatMessage> {
    const row: ChatMessage = {
      ...msg,
      id: crypto.randomUUID(),
      created_at: nowIso(),
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<ChatMessage>('conversation_messages').insertOne({ ...row });
      return row;
    }
    this.local.read().messages.push(row);
    this.local.save();
    return row;
  }

  async saveBrainDumpDraft(draft: BrainDumpDraft): Promise<BrainDumpDraft> {
    const db = await getMongoDb();
    if (db) {
      await db.collection<BrainDumpDraft>('brain_dump_drafts').insertOne({ ...draft });
      return draft;
    }
    this.local.read().brain_dump_drafts.unshift(draft);
    this.local.save();
    return draft;
  }

  async getBrainDumpDraft(userId: string, draftId: string): Promise<BrainDumpDraft | null> {
    const db = await getMongoDb();
    if (db) {
      const doc = await db
        .collection<BrainDumpDraft>('brain_dump_drafts')
        .findOne({ id: draftId, user_id: userId });
      return doc ? stripMongoId(doc) : null;
    }
    return (
      this.local
        .read()
        .brain_dump_drafts.find((d) => d.id === draftId && d.user_id === userId) || null
    );
  }

  async markBrainDumpSaved(userId: string, draftId: string): Promise<void> {
    const db = await getMongoDb();
    if (db) {
      await db
        .collection<BrainDumpDraft>('brain_dump_drafts')
        .updateOne({ id: draftId, user_id: userId }, { $set: { status: 'saved' } });
      return;
    }
    const found = this.local
      .read()
      .brain_dump_drafts.find((d) => d.id === draftId && d.user_id === userId);
    if (found) {
      found.status = 'saved';
      this.local.save();
    }
  }

  // ---------------- USAGE LOGS ----------------
  async recordUsage(
    userId: string,
    actionType: string,
    modelName: string,
    aiTokens: number,
    voiceSeconds = 0
  ): Promise<void> {
    const mk = monthKey();
    const row: UsageLog = {
      id: crypto.randomUUID(),
      user_id: userId,
      month_key: mk,
      action_type: actionType,
      model_name: modelName,
      ai_tokens: aiTokens,
      voice_seconds: voiceSeconds,
      created_at: nowIso(),
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<UsageLog>('usage_logs').insertOne({ ...row });
    } else {
      this.local.read().usage_logs.push(row);
      this.local.save();
    }
  }

  // ---------------- PHASE 2: BUDGETING & EMAIL REPORTS ----------------
  async getBudgetOverview(userId: string): Promise<{ budget: BudgetInfo; expenses: ExpenseItem[] }> {
    const mk = monthKey();
    const db = await getMongoDb();
    if (db) {
      const existingBudget = await db
        .collection<BudgetInfo>('budgets')
        .findOne({ user_id: userId, month_key: mk });
      let budget: BudgetInfo;
      if (existingBudget) {
        budget = stripMongoId<BudgetInfo>(existingBudget);
      } else {
        budget = {
          id: crypto.randomUUID(),
          user_id: userId,
          month_key: mk,
          currency: 'Rs.',
          monthly_limit: 45000,
          created_at: nowIso(),
        };
        await db.collection<BudgetInfo>('budgets').insertOne({ ...budget });
      }
      const expenses = await db
        .collection<ExpenseItem>('expenses')
        .find({ user_id: userId })
        .sort({ spent_at: -1 })
        .toArray();
      return { budget, expenses: expenses.map((e) => stripMongoId<ExpenseItem>(e)) };
    }

    const snap = this.local.read();
    let budget = snap.budgets.find((b) => b.user_id === userId && b.month_key === mk);
    if (!budget) {
      budget = {
        id: crypto.randomUUID(),
        user_id: userId,
        month_key: mk,
        currency: 'Rs.',
        monthly_limit: 45000,
        created_at: nowIso(),
      };
      snap.budgets.push(budget);
      this.local.save();
    }
    const expenses = snap.expenses.filter((e) => e.user_id === userId);
    return { budget, expenses };
  }

  async addExpense(
    userId: string,
    input: { title: string; amount: number; category: string }
  ): Promise<ExpenseItem> {
    const { budget } = await this.getBudgetOverview(userId);
    const row: ExpenseItem = {
      id: crypto.randomUUID(),
      user_id: userId,
      budget_id: budget.id,
      category: input.category || 'Personal',
      title: input.title,
      amount: input.amount,
      spent_at: nowIso(),
    };
    const db = await getMongoDb();
    if (db) {
      await db.collection<ExpenseItem>('expenses').insertOne({ ...row });
      return row;
    }
    this.local.read().expenses.unshift(row);
    this.local.save();
    return row;
  }

  async getEmailReportPrefs(userId: string): Promise<EmailReportPrefs> {
    const db = await getMongoDb();
    if (db) {
      const found = await db
        .collection<EmailReportPrefs>('email_report_preferences')
        .findOne({ user_id: userId });
      if (found) return stripMongoId(found);
      const fresh: EmailReportPrefs = {
        user_id: userId,
        enabled: false,
        weekly_summary_enabled: true,
        monthly_review_enabled: true,
        updated_at: nowIso(),
      };
      await db.collection<EmailReportPrefs>('email_report_preferences').insertOne({ ...fresh });
      return fresh;
    }
    const snap = this.local.read();
    if (!snap.email_report_preferences[userId]) {
      snap.email_report_preferences[userId] = {
        user_id: userId,
        enabled: false,
        weekly_summary_enabled: true,
        monthly_review_enabled: true,
        updated_at: nowIso(),
      };
      this.local.save();
    }
    return snap.email_report_preferences[userId];
  }

  async updateEmailReportPrefs(
    userId: string,
    patch: Partial<EmailReportPrefs>
  ): Promise<EmailReportPrefs> {
    const current = await this.getEmailReportPrefs(userId);
    const updated = { ...current, ...patch, updated_at: nowIso() };
    const db = await getMongoDb();
    if (db) {
      await db
        .collection<EmailReportPrefs>('email_report_preferences')
        .updateOne({ user_id: userId }, { $set: updated }, { upsert: true });
      return updated;
    }
    this.local.read().email_report_preferences[userId] = updated;
    this.local.save();
    return updated;
  }

  // ---------------- PRIVACY: EXPORT & DELETE ----------------
  async exportUserData(userId: string): Promise<Record<string, unknown>> {
    const [profile, tasks, reminders, shopping, memories, keepForLater, goals, affirmations] =
      await Promise.all([
        this.ensureUser(userId),
        this.listTasks(userId),
        this.listReminders(userId),
        this.listShopping(userId),
        this.listMemories(userId),
        this.listKeepForLater(userId),
        this.listGoals(userId),
        this.listAffirmations(userId),
      ]);
    return {
      exported_at: nowIso(),
      profile,
      tasks,
      reminders,
      shopping_items: shopping,
      memories,
      keep_for_later: keepForLater,
      goals,
      affirmations,
    };
  }

  async deleteAllUserData(userId: string): Promise<void> {
    const db = await getMongoDb();
    if (db) {
      await Promise.all([
        db.collection('tasks').deleteMany({ user_id: userId }),
        db.collection('reminders').deleteMany({ user_id: userId }),
        db.collection('shopping_items').deleteMany({ user_id: userId }),
        db.collection('memories').deleteMany({ user_id: userId }),
        db.collection('keep_for_later').deleteMany({ user_id: userId }),
        db.collection('goals').deleteMany({ user_id: userId }),
        db.collection('affirmations').deleteMany({ user_id: userId }),
        db.collection('conversation_messages').deleteMany({ user_id: userId }),
        db.collection('brain_dump_drafts').deleteMany({ user_id: userId }),
        db.collection('expenses').deleteMany({ user_id: userId }),
      ]);
      return;
    }
    this.local.resetUser(userId);
  }
}

export const dataStore = new DataStore();
