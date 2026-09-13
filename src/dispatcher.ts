import { logger } from "./infra/logger.js";
import { desconectarBanco } from "./infra/db.js";
import { desconectarRedis } from "./infra/redis.js";

logger.info("Dispatcher iniciado");

async function encerrar(sinal: string): Promise<void> {
  logger.info({ sinal }, "Encerrando dispatcher");
  await desconectarBanco();
  await desconectarRedis();
  process.exit(0);
}

process.on("SIGTERM", () => void encerrar("SIGTERM"));
process.on("SIGINT", () => void encerrar("SIGINT"));
