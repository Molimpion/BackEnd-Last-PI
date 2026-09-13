import { createServer } from "node:http";
import { criarApp } from "./app.js";
import { env } from "./infra/env.js";
import { logger } from "./infra/logger.js";
import { desconectarBanco } from "./infra/db.js";
import { desconectarRedis } from "./infra/redis.js";

const servidor = createServer(criarApp());

servidor.listen(env.PORT, () => {
  logger.info({ porta: env.PORT }, "API iniciada");
});

async function encerrar(sinal: string): Promise<void> {
  logger.info({ sinal }, "Encerrando API");
  servidor.close();
  await desconectarBanco();
  await desconectarRedis();
  process.exit(0);
}

process.on("SIGTERM", () => void encerrar("SIGTERM"));
process.on("SIGINT", () => void encerrar("SIGINT"));
