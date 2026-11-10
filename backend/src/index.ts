import express from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import { apiRouter } from './routes/api.js';

export function createApp() {
  const app = express();
  app.use(cors());
  app.use(express.json({ limit: '2mb' }));
  app.use('/api', apiRouter);
  return app;
}

const isDirectRun =
  process.argv[1] &&
  import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop() || '');

if (isDirectRun) {
  const app = createApp();
  app.listen(env.port, () => {
    console.log(`AI Daily Helper API listening on http://localhost:${env.port}`);
  });
}
