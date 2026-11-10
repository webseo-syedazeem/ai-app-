// AI Daily Helper — MongoDB Collections & Index Initialization Script
// Run via mongosh: mongosh "<MONGODB_URI>" mongodb/schema_and_indexes.js

const database = db.getSiblingDB('ai_daily_helper');

const collections = [
  'users',
  'tasks',
  'reminders',
  'shopping_items',
  'memories',
  'keep_for_later',
  'conversations',
  'conversation_messages',
  'brain_dump_drafts',
  'goals',
  'affirmations',
  'usage_logs',
  'budgets',
  'expenses',
  'email_report_preferences',
];

for (const name of collections) {
  if (!database.getCollectionNames().includes(name)) {
    database.createCollection(name);
  }
}

database.users.createIndex({ id: 1 }, { unique: true });
database.users.createIndex({ email: 1 }, { unique: true });
database.tasks.createIndex({ user_id: 1, status: 1, due_at: 1 });
database.reminders.createIndex({ user_id: 1, status: 1, remind_at: 1 });
database.shopping_items.createIndex({ user_id: 1, completed: 1 });
database.memories.createIndex({ user_id: 1, category: 1 });
database.keep_for_later.createIndex({ user_id: 1, status: 1 });
database.conversation_messages.createIndex({ user_id: 1, created_at: 1 });
database.brain_dump_drafts.createIndex({ user_id: 1, created_at: -1 });
database.goals.createIndex({ user_id: 1, period: 1 });
database.affirmations.createIndex({ user_id: 1, saved_at: -1 });
database.usage_logs.createIndex({ user_id: 1, month_key: 1 });
database.budgets.createIndex({ user_id: 1, month_key: 1 }, { unique: true });
database.expenses.createIndex({ user_id: 1, spent_at: -1 });
database.email_report_preferences.createIndex({ user_id: 1 }, { unique: true });

print('AI Daily Helper MongoDB collections and indexes initialized.');
