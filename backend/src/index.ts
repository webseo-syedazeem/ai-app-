import express, { type NextFunction, type Request, type Response } from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import { apiRouter } from './routes/api.js';

export function createApp() {
  const app = express();
  app.use(cors());
  app.use(express.json({ limit: '2mb' }));

  app.get('/', (_req: Request, res: Response) => {
    res.json({
      ok: true,
      service: 'AI Daily Helper API',
      health: '/api/health',
    });
  });

  app.use('/api', apiRouter);

  app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
    const message = err instanceof Error ? err.message : 'Internal server error';
    console.error('API Error:', message);
    if (!res.headersSent) {
      res.status(500).json({ ok: false, error: message });
    }
  });

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
