import pino from "pino";
import { env } from "./env.js";

export const logger = pino({
  level: env.LOG_LEVEL,
  redact: {
    paths: ["req.headers.cookie", "req.headers.authorization", "*.senha", "*.password", "*.token"],
    censor: "[REDACTED]",
  },
  ...(env.NODE_ENV === "development" ? { transport: { target: "pino-pretty" } } : {}),
});

export type Logger = typeof logger;
