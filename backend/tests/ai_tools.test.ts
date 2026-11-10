import { describe, expect, it } from 'vitest';
import { selectModelForInput } from '../src/ai/intentRouter.js';
import { executeToolCall, fallbackParseBrainDump } from '../src/ai/toolExecutor.js';
import { dataStore } from '../src/db/dataStore.js';
import { checkAndConsumeQuota } from '../src/services/usageService.js';

describe('Intent Router (Flash-Lite vs Flash)', () => {
  it('routes simple requests to Flash-Lite', () => {
    const decision = selectModelForInput('Add eggs to my shopping list');
    expect(decision.tier).toBe('simple');
    expect(decision.model).toContain('flash-lite');
  });

  it('routes brain dumps and complex planning to Flash', () => {
    const decision = selectModelForInput(
      'Tomorrow go to office, call Ali, car oil change, wife birthday coming up and Friday deliver website to client',
      true
    );
    expect(decision.tier).toBe('complex');
    expect(decision.model).not.toContain('flash-lite');
  });
});

describe('Tool Executor & Brain Dump Parser', () => {
  const testUser = '00000000-0000-0000-0000-000000000099';

  it('creates task, shopping item, reminder, and memory cleanly', async () => {
    const taskRes = await executeToolCall(testUser, 'create_task', {
      title: 'Test proposal',
      priority: 'high',
    });
    expect(taskRes.ok).toBe(true);

    const shopRes = await executeToolCall(testUser, 'create_shopping_item', {
      item: 'Toothpaste',
    });
    expect(shopRes.ok).toBe(true);

    const memRes = await executeToolCall(testUser, 'save_memory', {
      title: 'Sister birthday',
      content: 'December 18',
      category: 'dates',
    });
    expect(memRes.ok).toBe(true);

    const todayRes = await executeToolCall(testUser, 'get_today', {});
    expect(todayRes.ok).toBe(true);
    expect(Number(todayRes.shopping_pending_count)).toBeGreaterThanOrEqual(1);

    await dataStore.deleteAllUserData(testUser);
  });

  it('parses brain dump clauses into tasks, reminders, and shopping', () => {
    const parsed = fallbackParseBrainDump(
      'Prepare the project update tomorrow, call Ali tomorrow at 5 PM, buy eggs, bread and detergent'
    );
    expect(parsed.tasks.length + parsed.reminders.length + parsed.shopping.length).toBeGreaterThanOrEqual(3);
  });

  it('enforces free daily quota limits', async () => {
    const freeUser = '00000000-0000-0000-0000-000000000088';
    await dataStore.updateUser(freeUser, { plan: 'free', daily_actions_used: 0 });
    for (let i = 0; i < 5; i++) {
      const ok = await checkAndConsumeQuota(freeUser, 0);
      expect(ok.allowed).toBe(true);
    }
    const blocked = await checkAndConsumeQuota(freeUser, 0);
    expect(blocked.allowed).toBe(false);
    await dataStore.deleteAllUserData(freeUser);
  });
});
