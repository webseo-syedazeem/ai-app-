import dotenv from 'dotenv';

dotenv.config();

export const env = {
  port: Number(process.env.PORT || 3000),
  nodeEnv: process.env.NODE_ENV || 'development',
  geminiApiKey: process.env.GEMINI_API_KEY?.trim() || '',
  geminiLiteModel: process.env.GEMINI_LITE_MODEL?.trim() || 'gemini-2.5-flash-lite',
  geminiComplexModel: process.env.GEMINI_COMPLEX_MODEL?.trim() || 'gemini-2.5-flash',
  mongoUri: process.env.MONGODB_URI?.trim() || '',
  mongoDbName: process.env.MONGODB_DB_NAME?.trim() || 'ai_daily_helper',
  useLocalDevStore: process.env.USE_LOCAL_DEV_STORE === 'true',
};

export function hasMongoConfig(): boolean {
  return !env.useLocalDevStore && Boolean(env.mongoUri);
}

export function hasGeminiConfig(): boolean {
  return Boolean(env.geminiApiKey);
}
