import type { ErrorRequestHandler } from "express";
import { ZodError, z } from "zod";
import { logger } from "./logger.js";

export class AppError extends Error {
  constructor(
    readonly status: number,
    readonly codigo: string,
    message: string,
  ) {
    super(message);
    this.name = "AppError";
  }
}

export const naoEncontrado = (recurso: string): AppError =>
  new AppError(404, "NAO_ENCONTRADO", `${recurso} nao encontrado`);

export const naoAutenticado = (): AppError =>
  new AppError(401, "NAO_AUTENTICADO", "Credenciais ausentes ou invalidas");

export const semPermissao = (): AppError =>
  new AppError(403, "SEM_PERMISSAO", "Sem permissao para esta operacao");

export const tratadorDeErros: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof ZodError) {
    res.status(400).json({ codigo: "ENTRADA_INVALIDA", detalhes: z.treeifyError(err) });
    return;
  }

  if (err instanceof AppError) {
    res.status(err.status).json({ codigo: err.codigo, mensagem: err.message });
    return;
  }

  logger.error({ err }, "Erro nao tratado");
  res.status(500).json({ codigo: "ERRO_INTERNO", mensagem: "Erro interno do servidor" });
};
