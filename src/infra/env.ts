import "dotenv/config";
import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(3333),
  APP_URL: z.url(),
  FRONTEND_ORIGIN: z.url(),

  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().min(1),

  SESSION_COOKIE_NAME: z.string().min(1).default("sid"),
  SESSION_SECRET: z.string().min(32),
  SESSION_TTL_SECONDS: z.coerce.number().int().positive().default(604800),

  LOG_LEVEL: z.enum(["fatal", "error", "warn", "info", "debug", "trace"]).default("info"),

  SENTRY_DSN: z.string().optional(),

  SENDGRID_API_KEY: z.string().optional(),
  MAIL_FROM: z.email(),

  CLOUDINARY_CLOUD_NAME: z.string().optional(),
  CLOUDINARY_API_KEY: z.string().optional(),
  CLOUDINARY_API_SECRET: z.string().optional(),

  ABACATEPAY_API_KEY: z.string().optional(),
  ABACATEPAY_WEBHOOK_SECRET: z.string().optional(),

  AI_SERVICE_URL: z.url(),
  AI_SERVICE_API_KEY: z.string().optional(),
  AI_SERVICE_TIMEOUT_MS: z.coerce.number().int().positive().default(5000),
});

const parsed = schema.safeParse(process.env);

if (!parsed.success) {
  const faltando = z.treeifyError(parsed.error);
  console.error("Variaveis de ambiente invalidas:", JSON.stringify(faltando, null, 2));
  process.exit(1);
}

export const env = parsed.data;
