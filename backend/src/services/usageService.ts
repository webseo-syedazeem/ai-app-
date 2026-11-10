import { dataStore } from '../db/dataStore.js';
import type { PlanTier, UserProfile } from '../types/domain.js';

export interface PlanLimits {
  label: string;
  priceMonthly: string;
  dailyActionsLimit: number | null;
  monthlyActionsLimit: number;
  voiceMinutesLimit: number;
}

export const PLAN_CONFIG: Record<PlanTier, PlanLimits> = {
  free: {
    label: 'Free',
    priceMonthly: '$0',
    dailyActionsLimit: 5,
    monthlyActionsLimit: 150,
    voiceMinutesLimit: 15,
  },
  plus: {
    label: 'Plus',
    priceMonthly: '$4.99/month',
    dailyActionsLimit: null,
    monthlyActionsLimit: 1000,
    voiceMinutesLimit: 120,
  },
  pro: {
    label: 'Pro',
    priceMonthly: '$9.99/month',
    dailyActionsLimit: null,
    monthlyActionsLimit: 3000,
    voiceMinutesLimit: 500,
  },
};

export interface QuotaCheckResult {
  allowed: boolean;
  reason?: string;
  user: UserProfile;
  limits: PlanLimits;
}

export async function checkAndConsumeQuota(
  userId: string,
  voiceSeconds = 0
): Promise<QuotaCheckResult> {
  const user = await dataStore.ensureUser(userId);
  const limits = PLAN_CONFIG[user.plan];
  const todayKey = new Date().toISOString().slice(0, 10);
  const currentMonth = new Date().toISOString().slice(0, 7);

  let dailyUsed = user.daily_actions_date === todayKey ? user.daily_actions_used : 0;
  let monthlyUsed = user.usage_month === currentMonth ? user.monthly_actions_used : 0;
  let voiceUsed = user.usage_month === currentMonth ? user.voice_seconds_used : 0;

  if (limits.dailyActionsLimit !== null && dailyUsed >= limits.dailyActionsLimit) {
    return {
      allowed: false,
      reason: `Free plan daily limit reached (${limits.dailyActionsLimit} AI actions/day). Upgrade to Plus for up to 1,000 AI actions/month.`,
      user,
      limits,
    };
  }

  if (monthlyUsed >= limits.monthlyActionsLimit) {
    return {
      allowed: false,
      reason: `Monthly AI action limit reached (${limits.monthlyActionsLimit} actions).`,
      user,
      limits,
    };
  }

  if (voiceSeconds > 0 && voiceUsed + voiceSeconds > limits.voiceMinutesLimit * 60) {
    return {
      allowed: false,
      reason: `Monthly voice limit reached (${limits.voiceMinutesLimit} voice minutes/month).`,
      user,
      limits,
    };
  }

  dailyUsed += 1;
  monthlyUsed += 1;
  voiceUsed += voiceSeconds;

  const updated = await dataStore.updateUser(userId, {
    daily_actions_used: dailyUsed,
    daily_actions_date: todayKey,
    monthly_actions_used: monthlyUsed,
    voice_seconds_used: voiceUsed,
    usage_month: currentMonth,
    ai_credits: Math.max(0, limits.monthlyActionsLimit - monthlyUsed),
  });

  return { allowed: true, user: updated, limits };
}
