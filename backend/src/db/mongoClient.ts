import { Db, MongoClient } from 'mongodb';
import { env, hasMongoConfig } from '../config/env.js';

declare global {
  var __mongoClientPromise: Promise<MongoClient> | undefined;
  var __mongoIndexesReady: boolean | undefined;
}

/**
 * Reuses a global cached MongoClient promise across Vercel serverless invocations
 * to prevent connection pool exhaustion on warm lambdas.
 */
export async function getMongoDb(): Promise<Db | null> {
  if (!hasMongoConfig()) return null;

  if (!globalThis.__mongoClientPromise) {
    const client = new MongoClient(env.mongoUri, {
      maxPoolSize: 10,
      connectTimeoutMS: 5000,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 10000,
    });
    globalThis.__mongoClientPromise = client.connect().catch((err) => {
      globalThis.__mongoClientPromise = undefined;
      throw err;
    });
  }

  const client = await globalThis.__mongoClientPromise;
  const db = client.db(env.mongoDbName);

  if (!globalThis.__mongoIndexesReady) {
    try {
      await ensureMongoIndexes(db);
    } catch (err) {
      console.warn('Mongo index check warning:', err instanceof Error ? err.message : err);
    }
    globalThis.__mongoIndexesReady = true;
  }

  return db;
}

async function ensureMongoIndexes(db: Db): Promise<void> {
  await Promise.all([
    db.collection('users').createIndex({ id: 1 }, { unique: true }),
    db.collection('users').createIndex({ email: 1 }, { unique: true }),
    db.collection('tasks').createIndex({ user_id: 1, status: 1, due_at: 1 }),
    db.collection('reminders').createIndex({ user_id: 1, status: 1, remind_at: 1 }),
    db.collection('shopping_items').createIndex({ user_id: 1, completed: 1 }),
    db.collection('memories').createIndex({ user_id: 1, category: 1 }),
    db.collection('keep_for_later').createIndex({ user_id: 1, status: 1 }),
    db.collection('conversation_messages').createIndex({ user_id: 1, created_at: 1 }),
    db.collection('brain_dump_drafts').createIndex({ user_id: 1, created_at: -1 }),
    db.collection('goals').createIndex({ user_id: 1, period: 1 }),
    db.collection('affirmations').createIndex({ user_id: 1, saved_at: -1 }),
    db.collection('usage_logs').createIndex({ user_id: 1, month_key: 1 }),
    db.collection('budgets').createIndex({ user_id: 1, month_key: 1 }, { unique: true }),
    db.collection('expenses').createIndex({ user_id: 1, spent_at: -1 }),
    db.collection('email_report_preferences').createIndex({ user_id: 1 }, { unique: true }),
  ]);
}
