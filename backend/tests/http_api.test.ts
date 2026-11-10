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
      expect(String((chat.data.message as Record<string, unknown>).content)).toContain('Eggs');

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
  });
});
