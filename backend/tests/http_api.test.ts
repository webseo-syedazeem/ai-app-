import { describe, expect, it } from 'vitest';
import { createApp } from '../src/index.js';
import { dataStore } from '../src/db/dataStore.js';
import http from 'node:http';

const TEST_HTTP_USER = '00000000-0000-0000-0000-000000000077';

async function requestJson(
  server: http.Server,
  method: string,
  path: string,
  body?: Record<string, unknown>
): Promise<{ status: number; data: Record<string, unknown> }> {
  const addr = server.address();
  if (!addr || typeof addr === 'string') throw new Error('Invalid server address');
  const url = `http://127.0.0.1:${addr.port}${path}`;
  const res = await fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'x-user-id': TEST_HTTP_USER,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = (await res.json()) as Record<string, unknown>;
  return { status: res.status, data };
}

describe('HTTP REST API', () => {
  it('serves health, dashboard, AI chat, brain dump, and forgetting endpoints', async () => {
    await dataStore.updateUser(TEST_HTTP_USER, { daily_actions_used: 0, plan: 'plus' });
    const app = createApp();
    const server = await new Promise<http.Server>((resolve) => {
      const s = app.listen(0, () => resolve(s));
    });

    try {
      const health = await requestJson(server, 'GET', '/api/health');
      expect(health.status).toBe(200);
      expect(health.data.ok).toBe(true);

      const chat = await requestJson(server, 'POST', '/api/ai/chat', {
        message: 'Add eggs and bread to my shopping list',
      });
      expect(chat.status).toBe(200);
      expect(String((chat.data.message as Record<string, unknown>).content).toLowerCase()).toContain('eggs');

      const dump = await requestJson(server, 'POST', '/api/ai/brain-dump', {
        transcript: 'Prepare update tomorrow, call Ali tomorrow at 5 PM, buy detergent',
      });
      expect(dump.status).toBe(200);
      expect(dump.data.draftId).toBeTruthy();

      const forgetting = await requestJson(server, 'GET', '/api/ai/forgetting');
      expect(forgetting.status).toBe(200);
      expect(typeof forgetting.data.summary).toBe('string');

      await requestJson(server, 'DELETE', '/api/user/account-data');
    } finally {
      await new Promise<void>((resolve) => server.close(() => resolve()));
    }
  }, 40000);

  it('supports real signup, login, JWT /auth/me, and protects against duplicate emails or bad passwords', async () => {
    const app = createApp();
    const server = await new Promise<http.Server>((resolve) => {
      const s = app.listen(0, () => resolve(s));
    });
    const addr = server.address();
    if (!addr || typeof addr === 'string') throw new Error('Invalid server address');
    const base = `http://127.0.0.1:${addr.port}`;
    const testEmail = `auth-${Date.now()}@example.com`;
    let createdUserId = '';

    try {
      const signupRes = await fetch(`${base}/api/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: 'Test User',
          email: testEmail,
          password: 'Password123!',
        }),
      });
      expect(signupRes.status).toBe(201);
      const signupJson = (await signupRes.json()) as {
        token: string;
        user: Record<string, unknown>;
      };
      expect(signupJson.token).toBeTruthy();
      expect(signupJson.user.email).toBe(testEmail);
      expect(signupJson.user.password_hash).toBeUndefined();
      createdUserId = String(signupJson.user.id);

      const dupRes = await fetch(`${base}/api/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: 'Duplicate',
          email: testEmail,
          password: 'Password123!',
        }),
      });
      expect(dupRes.status).toBe(409);

      const badLogin = await fetch(`${base}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: testEmail, password: 'WrongPassword' }),
      });
      expect(badLogin.status).toBe(401);

      const loginRes = await fetch(`${base}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: testEmail, password: 'Password123!' }),
      });
      expect(loginRes.status).toBe(200);
      const loginJson = (await loginRes.json()) as {
        token: string;
        user: Record<string, unknown>;
      };
      expect(loginJson.token).toBeTruthy();
      expect(loginJson.user.password_hash).toBeUndefined();

      const meRes = await fetch(`${base}/api/auth/me`, {
        headers: { Authorization: `Bearer ${loginJson.token}` },
      });
      expect(meRes.status).toBe(200);
      const meJson = (await meRes.json()) as { user: Record<string, unknown> };
      expect(meJson.user.id).toBe(createdUserId);
      expect(meJson.user.password_hash).toBeUndefined();

      const unauthMe = await fetch(`${base}/api/auth/me`);
      expect(unauthMe.status).toBe(401);

      const authHeaders = {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${loginJson.token}`,
      };

      // Shopping item create, edit, complete, clear completed
      const shopRes = await fetch(`${base}/api/shopping`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({ item: 'Green tea', category: 'Groceries' }),
      });
      expect(shopRes.status).toBe(201);
      const shopJson = (await shopRes.json()) as { item: { id: string } };
      const patchShop = await fetch(`${base}/api/shopping/${shopJson.item.id}`, {
        method: 'PATCH',
        headers: authHeaders,
        body: JSON.stringify({ item: 'Matcha tea', completed: true }),
      });
      expect(patchShop.status).toBe(200);
      const patchedShop = (await patchShop.json()) as {
        item: { item: string; completed: boolean };
      };
      expect(patchedShop.item.item).toBe('Matcha tea');
      expect(patchedShop.item.completed).toBe(true);

      const clearShop = await fetch(`${base}/api/shopping/completed`, {
        method: 'DELETE',
        headers: authHeaders,
      });
      expect(clearShop.status).toBe(200);

      // Memory create, patch, delete
      const memRes = await fetch(`${base}/api/memories`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({ title: 'Book club', content: 'Reads sci-fi', category: 'other' }),
      });
      expect(memRes.status).toBe(201);
      const memJson = (await memRes.json()) as { memory: { id: string } };
      const patchMem = await fetch(`${base}/api/memories/${memJson.memory.id}`, {
        method: 'PATCH',
        headers: authHeaders,
        body: JSON.stringify({ title: 'Monthly book club' }),
      });
      expect(patchMem.status).toBe(200);

      // Goal & Affirmation CRUD
      const goalRes = await fetch(`${base}/api/goals`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({ title: 'Walk daily', target_value: 5, unit_label: 'days' }),
      });
      expect(goalRes.status).toBe(201);
      const goalJson = (await goalRes.json()) as { goal: { id: string } };
      const delGoal = await fetch(`${base}/api/goals/${goalJson.goal.id}`, {
        method: 'DELETE',
        headers: authHeaders,
      });
      expect(delGoal.status).toBe(200);

      const affRes = await fetch(`${base}/api/affirmations`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({ quote: 'Stay calm and focused.' }),
      });
      expect(affRes.status).toBe(201);
      const affJson = (await affRes.json()) as { affirmation: { id: string } };
      const patchAff = await fetch(`${base}/api/affirmations/${affJson.affirmation.id}`, {
        method: 'PATCH',
        headers: authHeaders,
        body: JSON.stringify({ quote: 'One focused step at a time.' }),
      });
      expect(patchAff.status).toBe(200);
      const delAff = await fetch(`${base}/api/affirmations/${affJson.affirmation.id}`, {
        method: 'DELETE',
        headers: authHeaders,
      });
      expect(delAff.status).toBe(200);

      // Phase 2 Budget update (daily + monthly), folders, & expense delete
      const budgetPatch = await fetch(`${base}/api/phase2/budget`, {
        method: 'PATCH',
        headers: authHeaders,
        body: JSON.stringify({ monthly_limit: 55000, daily_limit: 2500 }),
      });
      expect(budgetPatch.status).toBe(200);
      const folderRes = await fetch(`${base}/api/phase2/budget/folders`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({ name: 'Family Utilities', period: 'monthly', tone: 'amber' }),
      });
      expect(folderRes.status).toBe(201);
      const folderJson = (await folderRes.json()) as { folder: { id: string; name: string } };

      const expRes = await fetch(`${base}/api/phase2/budget/expense`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({
          title: 'Coffee',
          amount: 450,
          category: 'Food',
          period: 'daily',
          folder_id: folderJson.folder.id,
          folder_name: folderJson.folder.name,
        }),
      });
      expect(expRes.status).toBe(201);
      const expJson = (await expRes.json()) as { expense: { id: string } };
      const delExp = await fetch(`${base}/api/phase2/budget/expense/${expJson.expense.id}`, {
        method: 'DELETE',
        headers: authHeaders,
      });
      expect(delExp.status).toBe(200);
      const delFolder = await fetch(`${base}/api/phase2/budget/folders/${folderJson.folder.id}`, {
        method: 'DELETE',
        headers: authHeaders,
      });
      expect(delFolder.status).toBe(200);

      // Google OAuth start check (json status when unconfigured or redirect when configured)
      const googleStart = await fetch(`${base}/api/auth/google/start?format=json`, {
        redirect: 'manual',
      });
      expect([200, 302, 503]).toContain(googleStart.status);
    } finally {
      if (createdUserId) {
        await dataStore.deleteAllUserData(createdUserId);
        const { getMongoDb } = await import('../src/db/mongoClient.js');
        const db = await getMongoDb();
        if (db) {
          await db.collection('users').deleteOne({ id: createdUserId });
        }
      }
      await new Promise<void>((resolve) => server.close(() => resolve()));
    }
  }, 15000);
});
