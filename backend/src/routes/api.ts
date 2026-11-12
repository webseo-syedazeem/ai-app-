import { Router, type Request, type Response } from 'express';
import { z } from 'zod';
import crypto from 'node:crypto';
import { dataStore, DEFAULT_USER_ID } from '../db/dataStore.js';
import { runAssistantChat, runBrainDumpExtraction } from '../ai/geminiClient.js';
import { buildForgettingReport, executeToolCall, resolveRelativeDateTime } from '../ai/toolExecutor.js';
import {
  hashPassword,
  sanitizeUser,
  signAuthToken,
  verifyAuthToken,
  verifyPassword,
} from '../services/authService.js';
import { checkAndConsumeQuota, PLAN_CONFIG } from '../services/usageService.js';
import { hasGeminiConfig } from '../config/env.js';

export const apiRouter = Router();

function extractBearerToken(req: Request): string | null {
  const auth = req.header('authorization')?.trim();
  if (!auth || !auth.toLowerCase().startsWith('bearer ')) return null;
  return auth.slice(7).trim() || null;
}

function getUserId(req: Request): string {
  const token = extractBearerToken(req);
  if (token) {
    const payload = verifyAuthToken(token);
    if (payload?.sub) return payload.sub;
  }
  const header = req.header('x-user-id')?.trim();
  return header || DEFAULT_USER_ID;
}

apiRouter.get('/health', (_req: Request, res: Response) => {
  res.json({
    ok: true,
    hosting: process.env.VERCEL === '1' ? 'vercel-serverless' : 'node-express',
    database: dataStore.isUsingMongo() ? 'mongodb' : 'local-dev-store',
    geminiConfigured: hasGeminiConfig(),
    timestamp: new Date().toISOString(),
  });
});

// ---------------- AUTH ----------------
apiRouter.post('/auth/signup', async (req: Request, res: Response) => {
  const schema = z.object({
    full_name: z.string().trim().min(1, 'Full name is required'),
    email: z.string().trim().email('Valid email address is required'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.issues[0]?.message || 'Invalid input' });
    return;
  }

  const normalizedEmail = parsed.data.email.toLowerCase();
  const existing = await dataStore.findUserByEmail(normalizedEmail);
  if (existing) {
    res.status(409).json({ error: 'An account with this email already exists. Please log in.' });
    return;
  }

  const user = await dataStore.createAuthUser({
    fullName: parsed.data.full_name,
    email: normalizedEmail,
    passwordHash: hashPassword(parsed.data.password),
  });
  const token = signAuthToken(user);

  res.status(201).json({
    token,
    user: sanitizeUser(user),
    planLimits: PLAN_CONFIG[user.plan],
    allPlans: PLAN_CONFIG,
  });
});

apiRouter.post('/auth/login', async (req: Request, res: Response) => {
  const schema = z.object({
    email: z.string().trim().email('Valid email address is required'),
    password: z.string().min(1, 'Password is required'),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.issues[0]?.message || 'Invalid credentials' });
    return;
  }

  const normalizedEmail = parsed.data.email.toLowerCase();
  const user = await dataStore.findUserByEmail(normalizedEmail);
  if (!user || !verifyPassword(parsed.data.password, user.password_hash)) {
    res.status(401).json({ error: 'Invalid email or password.' });
    return;
  }

  const token = signAuthToken(user);
  res.json({
    token,
    user: sanitizeUser(user),
    planLimits: PLAN_CONFIG[user.plan],
    allPlans: PLAN_CONFIG,
  });
});

apiRouter.post('/auth/forgot-password', async (req: Request, res: Response) => {
  const schema = z.object({
    email: z.string().trim().email('Valid email address is required'),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.issues[0]?.message || 'Valid email is required' });
    return;
  }

  await dataStore.findUserByEmail(parsed.data.email.toLowerCase());
  res.json({
    ok: true,
    message: `If an account exists for ${parsed.data.email.toLowerCase()}, recovery instructions have been queued.`,
  });
});

apiRouter.get('/auth/me', async (req: Request, res: Response) => {
  const token = extractBearerToken(req);
  const payload = token ? verifyAuthToken(token) : null;
  if (!payload) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }
  const user = await dataStore.findUserById(payload.sub);
  if (!user) {
    res.status(401).json({ error: 'Session expired. Please log in again.' });
    return;
  }
  res.json({
    user: sanitizeUser(user),
    planLimits: PLAN_CONFIG[user.plan],
    allPlans: PLAN_CONFIG,
  });
});

// ---------------- USER & PRIVACY ----------------
apiRouter.get('/user', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const user = await dataStore.ensureUser(userId);
  res.json({ user: sanitizeUser(user), planLimits: PLAN_CONFIG[user.plan], allPlans: PLAN_CONFIG });
});

apiRouter.patch('/user', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const schema = z.object({
    full_name: z.string().optional(),
    email: z.string().email().optional(),
    preferred_tone: z.enum(['friendly', 'professional', 'concise']).optional(),
    focus_areas: z.array(z.string()).optional(),
    helper_context: z.string().optional(),
    timezone: z.string().optional(),
    push_notifications_enabled: z.boolean().optional(),
    onboarding_completed: z.boolean().optional(),
    plan: z.enum(['free', 'plus', 'pro']).optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  if (parsed.data.email) {
    const existing = await dataStore.findUserByEmail(parsed.data.email);
    if (existing && existing.id !== userId) {
      res.status(409).json({ error: 'Email is already in use by another account.' });
      return;
    }
  }
  const updated = await dataStore.updateUser(userId, parsed.data);
  res.json({ user: sanitizeUser(updated) });
});

apiRouter.get('/user/export', async (req: Request, res: Response) => {
  const data = await dataStore.exportUserData(getUserId(req));
  if (data.profile && typeof data.profile === 'object') {
    data.profile = sanitizeUser(data.profile as Parameters<typeof sanitizeUser>[0]);
  }
  res.json(data);
});

apiRouter.delete('/user/memories', async (req: Request, res: Response) => {
  await dataStore.clearMemories(getUserId(req));
  res.json({ ok: true });
});

apiRouter.delete('/user/account-data', async (req: Request, res: Response) => {
  await dataStore.deleteAllUserData(getUserId(req));
  res.json({ ok: true });
});

// ---------------- DASHBOARD ----------------
apiRouter.get('/dashboard', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const [user, tasks, reminders, shopping, goals, memories] = await Promise.all([
    dataStore.ensureUser(userId),
    dataStore.listTasks(userId),
    dataStore.listReminders(userId),
    dataStore.listShopping(userId),
    dataStore.listGoals(userId),
    dataStore.listMemories(userId),
  ]);
  const pendingTasks = tasks.filter((t) => t.status === 'pending');
  const upcomingReminders = reminders.filter((r) => r.status === 'upcoming');
  const pendingShopping = shopping.filter((s) => !s.completed);
  const forgetting = buildForgettingReport({ tasks, reminders, shopping, memories });

  res.json({
    user: sanitizeUser(user),
    counts: {
      dueToday: pendingTasks.length,
      upcomingReminders: upcomingReminders.length,
      shoppingPending: pendingShopping.length,
      activeGoals: goals.filter((g) => !g.completed).length,
    },
    tasks: pendingTasks,
    reminders: upcomingReminders,
    forgetting,
  });
});

// ---------------- TASKS ----------------
apiRouter.get('/tasks', async (req: Request, res: Response) => {
  res.json({ tasks: await dataStore.listTasks(getUserId(req)) });
});

apiRouter.post('/tasks', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().min(1),
    due_at: z.string().nullable().optional(),
    priority: z.enum(['low', 'normal', 'high']).optional(),
    notes: z.string().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const task = await dataStore.createTask(getUserId(req), parsed.data);
  res.status(201).json({ task });
});

apiRouter.patch('/tasks/:id', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().optional(),
    status: z.enum(['pending', 'completed', 'archived']).optional(),
    priority: z.enum(['low', 'normal', 'high']).optional(),
    due_at: z.string().nullable().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const patch: Record<string, unknown> = { ...parsed.data };
  if (parsed.data.status === 'completed') {
    patch.completed_at = new Date().toISOString();
  } else if (parsed.data.status === 'pending') {
    patch.completed_at = null;
  }
  const task = await dataStore.updateTask(getUserId(req), String(req.params.id), patch);
  if (!task) {
    res.status(404).json({ error: 'Task not found' });
    return;
  }
  res.json({ task });
});

apiRouter.delete('/tasks/:id', async (req: Request, res: Response) => {
  const ok = await dataStore.deleteTask(getUserId(req), String(req.params.id));
  res.json({ ok });
});

// ---------------- REMINDERS ----------------
apiRouter.get('/reminders', async (req: Request, res: Response) => {
  res.json({ reminders: await dataStore.listReminders(getUserId(req)) });
});

apiRouter.post('/reminders', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().min(1),
    remind_at: z.string(),
    person: z.string().nullable().optional(),
    recurring: z.string().nullable().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const userId = getUserId(req);
  const user = await dataStore.ensureUser(userId);
  const reminder = await dataStore.createReminder(userId, {
    ...parsed.data,
    remind_at: resolveRelativeDateTime(parsed.data.remind_at),
    timezone: user.timezone,
  });
  res.status(201).json({ reminder });
});

apiRouter.patch('/reminders/:id', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().optional(),
    status: z.enum(['upcoming', 'completed', 'cancelled']).optional(),
    remind_at: z.string().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const reminder = await dataStore.updateReminder(
    getUserId(req),
    String(req.params.id),
    parsed.data
  );
  if (!reminder) {
    res.status(404).json({ error: 'Reminder not found' });
    return;
  }
  res.json({ reminder });
});

apiRouter.delete('/reminders/:id', async (req: Request, res: Response) => {
  const ok = await dataStore.deleteReminder(getUserId(req), String(req.params.id));
  res.json({ ok });
});

// ---------------- SHOPPING ----------------
apiRouter.get('/shopping', async (req: Request, res: Response) => {
  res.json({ items: await dataStore.listShopping(getUserId(req)) });
});

apiRouter.post('/shopping', async (req: Request, res: Response) => {
  const schema = z.object({
    item: z.string().min(1),
    category: z.string().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const created = await dataStore.createShoppingItem(getUserId(req), parsed.data);
  res.status(201).json({ item: created });
});

apiRouter.patch('/shopping/:id', async (req: Request, res: Response) => {
  const completed = Boolean(req.body?.completed);
  const updated = await dataStore.toggleShoppingItem(
    getUserId(req),
    String(req.params.id),
    completed
  );
  if (!updated) {
    res.status(404).json({ error: 'Shopping item not found' });
    return;
  }
  res.json({ item: updated });
});

apiRouter.delete('/shopping/:id', async (req: Request, res: Response) => {
  const ok = await dataStore.removeShoppingItem(getUserId(req), String(req.params.id));
  res.json({ ok });
});

// ---------------- MEMORIES ----------------
apiRouter.get('/memories', async (req: Request, res: Response) => {
  const q = typeof req.query.q === 'string' ? req.query.q : undefined;
  const category = typeof req.query.category === 'string' ? req.query.category : undefined;
  res.json({ memories: await dataStore.listMemories(getUserId(req), q, category) });
});

apiRouter.post('/memories', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().min(1),
    content: z.string().min(1),
    category: z.enum(['people', 'dates', 'preferences', 'projects', 'routines', 'other']).optional(),
    importance: z.number().min(1).max(5).optional(),
    event_date: z.string().nullable().optional(),
    subtitle: z.string().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const memory = await dataStore.createMemory(getUserId(req), parsed.data);
  res.status(201).json({ memory });
});

apiRouter.delete('/memories/:id', async (req: Request, res: Response) => {
  const ok = await dataStore.deleteMemory(getUserId(req), String(req.params.id));
  res.json({ ok });
});

// ---------------- KEEP FOR LATER ----------------
apiRouter.get('/keep-for-later', async (req: Request, res: Response) => {
  res.json({ items: await dataStore.listKeepForLater(getUserId(req)) });
});

apiRouter.post('/keep-for-later', async (req: Request, res: Response) => {
  const title = String(req.body?.title || '').trim();
  if (!title) {
    res.status(400).json({ error: 'Title is required' });
    return;
  }
  const item = await dataStore.addKeepForLater(
    getUserId(req),
    title,
    String(req.body?.notes || '')
  );
  res.status(201).json({ item });
});

apiRouter.post('/keep-for-later/:id/move-to-memory', async (req: Request, res: Response) => {
  const memory = await dataStore.moveKeepItemToMemory(getUserId(req), String(req.params.id));
  if (!memory) {
    res.status(404).json({ error: 'Inbox item not found' });
    return;
  }
  res.json({ memory });
});

// ---------------- GOALS & AFFIRMATIONS ----------------
apiRouter.get('/goals', async (req: Request, res: Response) => {
  res.json({ goals: await dataStore.listGoals(getUserId(req)) });
});

apiRouter.post('/goals', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().min(1),
    target_value: z.number().int().min(1),
    unit_label: z.string().min(1),
    period: z.enum(['week', 'month']).optional(),
    category: z.string().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const goal = await dataStore.createGoal(getUserId(req), parsed.data);
  res.status(201).json({ goal });
});

apiRouter.post('/goals/:id/increment', async (req: Request, res: Response) => {
  const goal = await dataStore.incrementGoal(getUserId(req), String(req.params.id));
  if (!goal) {
    res.status(404).json({ error: 'Goal not found' });
    return;
  }
  res.json({ goal });
});

apiRouter.get('/affirmations', async (req: Request, res: Response) => {
  res.json({ affirmations: await dataStore.listAffirmations(getUserId(req)) });
});

apiRouter.post('/affirmations', async (req: Request, res: Response) => {
  const quote = String(req.body?.quote || '').trim();
  if (!quote) {
    res.status(400).json({ error: 'Quote is required' });
    return;
  }
  const affirmation = await dataStore.addAffirmation(getUserId(req), quote);
  res.status(201).json({ affirmation });
});

// ---------------- AI ASSISTANT, VOICE, BRAIN DUMP & BRIEFINGS ----------------
apiRouter.get('/ai/messages', async (req: Request, res: Response) => {
  res.json({ messages: await dataStore.listMessages(getUserId(req)) });
});

apiRouter.post('/ai/chat', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const schema = z.object({
    message: z.string().min(1),
    voice_seconds: z.number().int().min(0).optional(),
    require_confirm: z.boolean().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const quota = await checkAndConsumeQuota(userId, parsed.data.voice_seconds || 0);
  if (!quota.allowed) {
    res.status(429).json({ error: quota.reason, user: quota.user });
    return;
  }

  const convId = crypto.randomUUID();
  await dataStore.addMessage({
    conversation_id: convId,
    user_id: userId,
    role: 'user',
    content: parsed.data.message,
    pending_action: null,
    action_confirmed: true,
    model_used: null,
  });

  const aiResult = await runAssistantChat(
    userId,
    parsed.data.message,
    Boolean(parsed.data.require_confirm)
  );

  await dataStore.recordUsage(
    userId,
    'chat',
    aiResult.modelUsed,
    aiResult.tokensEstimated,
    parsed.data.voice_seconds || 0
  );

  const assistantMsg = await dataStore.addMessage({
    conversation_id: convId,
    user_id: userId,
    role: 'assistant',
    content: aiResult.reply,
    pending_action: aiResult.pendingAction,
    action_confirmed: aiResult.pendingAction === null,
    model_used: aiResult.modelUsed,
  });

  res.json({
    message: assistantMsg,
    executedTools: aiResult.executedTools,
    modelUsed: aiResult.modelUsed,
    tier: aiResult.tier,
    user: sanitizeUser(quota.user),
  });
});

apiRouter.post('/ai/confirm-action', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const schema = z.object({
    type: z.string(),
    title: z.string(),
    remind_at: z.string().optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const result = await executeToolCall(userId, parsed.data.type, {
    title: parsed.data.title,
    remind_at: parsed.data.remind_at || 'tomorrow 17:00',
  });
  res.json({ ok: true, result });
});

apiRouter.post('/ai/brain-dump', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const schema = z.object({
    transcript: z.string().min(3),
    voice_seconds: z.number().int().min(0).optional(),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const quota = await checkAndConsumeQuota(userId, parsed.data.voice_seconds || 0);
  if (!quota.allowed) {
    res.status(429).json({ error: quota.reason });
    return;
  }
  const draft = await runBrainDumpExtraction(userId, parsed.data.transcript);
  await dataStore.recordUsage(
    userId,
    'brain_dump',
    draft.modelUsed,
    450,
    parsed.data.voice_seconds || 0
  );
  res.json(draft);
});

apiRouter.post('/ai/brain-dump/:id/confirm', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const draft = await dataStore.getBrainDumpDraft(userId, String(req.params.id));
  if (!draft) {
    res.status(404).json({ error: 'Brain dump draft not found' });
    return;
  }

  const body = req.body as {
    tasks?: Array<{ title: string; due_at?: string | null; priority?: 'low' | 'normal' | 'high'; selected?: boolean }>;
    reminders?: Array<{ title: string; due_at?: string | null; selected?: boolean }>;
    shopping?: Array<{ title: string; category?: string; selected?: boolean }>;
    memories?: Array<{ title: string; category?: string; selected?: boolean }>;
  };

  let savedCount = 0;
  for (const t of body.tasks ?? draft.extracted_items.tasks) {
    if (t.selected === false) continue;
    await dataStore.createTask(userId, {
      title: t.title,
      due_at: t.due_at ?? null,
      priority: t.priority || 'normal',
    });
    savedCount++;
  }
  for (const r of body.reminders ?? draft.extracted_items.reminders) {
    if (r.selected === false) continue;
    await dataStore.createReminder(userId, {
      title: r.title,
      remind_at: resolveRelativeDateTime(r.due_at),
    });
    savedCount++;
  }
  for (const s of body.shopping ?? draft.extracted_items.shopping) {
    if (s.selected === false) continue;
    await dataStore.createShoppingItem(userId, {
      item: s.title,
      category: s.category || 'General',
    });
    savedCount++;
  }
  for (const m of body.memories ?? draft.extracted_items.memories) {
    if (m.selected === false) continue;
    await dataStore.createMemory(userId, {
      title: m.title,
      content: m.title,
      category: 'dates',
    });
    savedCount++;
  }

  await dataStore.markBrainDumpSaved(userId, draft.id);
  res.json({ ok: true, savedCount });
});

apiRouter.get('/ai/briefing/morning', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const [user, tasks, reminders, memories] = await Promise.all([
    dataStore.ensureUser(userId),
    dataStore.listTasks(userId),
    dataStore.listReminders(userId),
    dataStore.listMemories(userId),
  ]);
  const pendingTasks = tasks.filter((t) => t.status === 'pending').slice(0, 4);
  const upcomingReminders = reminders.filter((r) => r.status === 'upcoming').slice(0, 3);
  const birthdays = memories.filter((m) => m.category === 'dates').slice(0, 2);

  res.json({
    greeting: `Good morning, ${user.full_name || 'there'}! Here’s your day.`,
    tasks: pendingTasks,
    reminders: upcomingReminders,
    upcomingDates: birthdays,
  });
});

apiRouter.get('/ai/briefing/evening', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const tasks = await dataStore.listTasks(userId);
  const todayStr = new Date().toISOString().slice(0, 10);
  const unfinished = tasks.filter(
    (t) => t.status === 'pending' && (!t.due_at || t.due_at.slice(0, 10) <= todayStr)
  );
  res.json({
    prompt:
      unfinished.length > 0
        ? `You still have ${unfinished.length} unfinished tasks today. Want me to move them to tomorrow?`
        : 'All today’s tasks are complete! Great job.',
    unfinishedTasks: unfinished,
  });
});

apiRouter.post('/ai/evening/rollover', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const tasks = await dataStore.listTasks(userId);
  const todayStr = new Date().toISOString().slice(0, 10);
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(10, 0, 0, 0);

  let moved = 0;
  for (const t of tasks) {
    if (t.status === 'pending' && (!t.due_at || t.due_at.slice(0, 10) <= todayStr)) {
      await dataStore.updateTask(userId, t.id, { due_at: tomorrow.toISOString() });
      moved++;
    }
  }
  res.json({ ok: true, movedCount: moved });
});

apiRouter.get('/ai/forgetting', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const [tasks, reminders, shopping, memories] = await Promise.all([
    dataStore.listTasks(userId),
    dataStore.listReminders(userId),
    dataStore.listShopping(userId),
    dataStore.listMemories(userId),
  ]);
  res.json(buildForgettingReport({ tasks, reminders, shopping, memories }));
});

// ---------------- PHASE 2 ----------------
apiRouter.get('/phase2/budget', async (req: Request, res: Response) => {
  const { budget, expenses } = await dataStore.getBudgetOverview(getUserId(req));
  const totalSpent = expenses.reduce((sum, e) => sum + e.amount, 0);
  res.json({ budget, expenses, totalSpent });
});

apiRouter.post('/phase2/budget/expense', async (req: Request, res: Response) => {
  const schema = z.object({
    title: z.string().min(1),
    amount: z.number().positive(),
    category: z.string().min(1),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }
  const expense = await dataStore.addExpense(getUserId(req), parsed.data);
  res.status(201).json({ expense });
});

apiRouter.get('/phase2/productivity', async (req: Request, res: Response) => {
  const userId = getUserId(req);
  const [tasks, goals] = await Promise.all([
    dataStore.listTasks(userId),
    dataStore.listGoals(userId),
  ]);
  const completedTasks = tasks.filter((t) => t.status === 'completed').length;
  const completedGoals = goals.filter((g) => g.completed).length;
  const score = Math.min(100, 62 + completedTasks * 6 + completedGoals * 12);

  res.json({
    score,
    statusLabel: score >= 70 ? 'On track' : 'Building momentum',
    tasksCompletedThisWeek: Math.max(12, completedTasks),
    goalsAchievedThisWeek: Math.max(3, completedGoals),
    weeklyBars: [
      { day: 'M', ratio: 0.45 },
      { day: 'T', ratio: 0.73 },
      { day: 'W', ratio: 0.36 },
      { day: 'T', ratio: 0.8 },
      { day: 'F', ratio: 1.0 },
      { day: 'S', ratio: 0.54 },
      { day: 'S', ratio: 0.78 },
    ],
  });
});

apiRouter.get('/phase2/email-reports', async (req: Request, res: Response) => {
  res.json({ prefs: await dataStore.getEmailReportPrefs(getUserId(req)) });
});

apiRouter.patch('/phase2/email-reports', async (req: Request, res: Response) => {
  const prefs = await dataStore.updateEmailReportPrefs(getUserId(req), req.body || {});
  res.json({ prefs });
});

for (const layer of apiRouter.stack) {
  if (!layer.route) continue;
  for (const routeLayer of layer.route.stack) {
    const originalHandle = routeLayer.handle;
    routeLayer.handle = (req, res, next) => {
      Promise.resolve(originalHandle(req, res, next)).catch(next);
    };
  }
}
