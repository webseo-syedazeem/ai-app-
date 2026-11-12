import { env, hasStripeConfig } from '../config/env.js';

export type PaidPlanTier = 'plus' | 'pro';

export interface StripeCheckoutResult {
  configured: boolean;
  url?: string;
  sessionId?: string;
  reason?: string;
}

export interface StripeSessionStatus {
  valid: boolean;
  paid: boolean;
  plan?: PaidPlanTier;
  userId?: string;
  reason?: string;
}

/** Creates a hosted Stripe Checkout Subscription Session for Plus ($4.99/mo) or Pro ($9.99/mo). */
export async function createStripeCheckoutSession(params: {
  plan: PaidPlanTier;
  userId: string;
  email: string;
  successUrl: string;
  cancelUrl: string;
}): Promise<StripeCheckoutResult> {
  if (!hasStripeConfig()) {
    return {
      configured: false,
      reason: 'STRIPE_SECRET_KEY is not configured on the server yet.',
    };
  }

  const form = new URLSearchParams();
  form.set('mode', 'subscription');
  form.set('success_url', params.successUrl);
  form.set('cancel_url', params.cancelUrl);
  if (params.email.includes('@')) {
    form.set('customer_email', params.email);
  }
  form.set('metadata[user_id]', params.userId);
  form.set('metadata[plan]', params.plan);

  const explicitPriceId =
    params.plan === 'pro' ? env.stripePricePro : env.stripePricePlus;
  if (explicitPriceId) {
    form.set('line_items[0][price]', explicitPriceId);
    form.set('line_items[0][quantity]', '1');
  } else {
    const isPro = params.plan === 'pro';
    form.set('line_items[0][quantity]', '1');
    form.set('line_items[0][price_data][currency]', 'usd');
    form.set('line_items[0][price_data][unit_amount]', isPro ? '999' : '499');
    form.set('line_items[0][price_data][recurring][interval]', 'month');
    form.set(
      'line_items[0][price_data][product_data][name]',
      isPro ? 'AI Daily Helper Pro' : 'AI Daily Helper Plus'
    );
  }

  try {
    const response = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: form.toString(),
    });
    const data = (await response.json().catch(() => ({}))) as {
      id?: string;
      url?: string;
      error?: { message?: string };
    };
    if (!response.ok || !data.url || !data.id) {
      return {
        configured: true,
        reason: data.error?.message || `Stripe returned HTTP ${response.status}`,
      };
    }
    return {
      configured: true,
      url: data.url,
      sessionId: data.id,
    };
  } catch (error) {
    return {
      configured: true,
      reason: error instanceof Error ? error.message : 'Network error calling Stripe',
    };
  }
}

/** Verifies a completed Stripe Checkout Session ID directly with Stripe. */
export async function retrieveStripeCheckoutSession(
  sessionId: string
): Promise<StripeSessionStatus> {
  if (!hasStripeConfig()) {
    return { valid: false, paid: false, reason: 'Stripe is not configured on the server.' };
  }
  try {
    const response = await fetch(
      `https://api.stripe.com/v1/checkout/sessions/${encodeURIComponent(sessionId)}`,
      {
        method: 'GET',
        headers: { Authorization: `Bearer ${env.stripeSecretKey}` },
      }
    );
    const data = (await response.json().catch(() => ({}))) as {
      status?: string;
      payment_status?: string;
      metadata?: { user_id?: string; plan?: string };
      error?: { message?: string };
    };
    if (!response.ok) {
      return {
        valid: false,
        paid: false,
        reason: data.error?.message || 'Unable to verify Stripe checkout session.',
      };
    }
    const plan =
      data.metadata?.plan === 'pro' || data.metadata?.plan === 'plus'
        ? data.metadata.plan
        : undefined;
    const paid = data.payment_status === 'paid' || data.status === 'complete';
    return {
      valid: true,
      paid,
      plan,
      userId: data.metadata?.user_id,
    };
  } catch (error) {
    return {
      valid: false,
      paid: false,
      reason: error instanceof Error ? error.message : 'Error verifying Stripe session',
    };
  }
}
