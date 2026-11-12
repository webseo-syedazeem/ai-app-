import dotenv from 'dotenv';

dotenv.config();

function cleanEnv(value?: string): string {
  const trimmed = value?.trim() || '';
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1).trim();
  }
  return trimmed;
}

export const env = {
  port: Number(process.env.PORT || 3000),
  nodeEnv: cleanEnv(process.env.NODE_ENV) || 'development',
  geminiApiKey: cleanEnv(process.env.GEMINI_API_KEY),
  geminiLiteModel: cleanEnv(process.env.GEMINI_LITE_MODEL) || 'gemini-3.5-flash-lite',
  geminiComplexModel: cleanEnv(process.env.GEMINI_COMPLEX_MODEL) || 'gemini-3.8-flash',
  mongoUri: cleanEnv(process.env.MONGODB_URI),
  mongoDbName: cleanEnv(process.env.MONGODB_DB_NAME) || 'ai_daily_helper',
  useLocalDevStore: cleanEnv(process.env.USE_LOCAL_DEV_STORE) === 'true',
  jwtSecret:
    cleanEnv(process.env.JWT_SECRET) || 'ai-daily-helper-dev-secret-change-in-prod',
  googleClientId: cleanEnv(process.env.GOOGLE_CLIENT_ID),
  googleClientSecret: cleanEnv(process.env.GOOGLE_CLIENT_SECRET),
  resendApiKey: cleanEnv(process.env.RESEND_API_KEY),
  emailFrom: cleanEnv(process.env.EMAIL_FROM) || 'AI Daily Helper <onboarding@resend.dev>',
  cronSecret: cleanEnv(process.env.CRON_SECRET),
  stripeSecretKey: cleanEnv(process.env.STRIPE_SECRET_KEY),
  stripePricePlus: cleanEnv(process.env.STRIPE_PRICE_PLUS),
  stripePricePro: cleanEnv(process.env.STRIPE_PRICE_PRO),
};

export function hasGoogleOAuthConfig(): boolean {
  return Boolean(env.googleClientId && env.googleClientSecret);
}

export function hasEmailConfig(): boolean {
  return Boolean(env.resendApiKey);
}

export function hasStripeConfig(): boolean {
  return Boolean(env.stripeSecretKey);
}

export function hasMongoConfig(): boolean {
  return !env.useLocalDevStore && Boolean(env.mongoUri);
}

export function hasGeminiConfig(): boolean {
  return Boolean(env.geminiApiKey);
}
