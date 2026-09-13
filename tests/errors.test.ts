import { describe, it, expect, vi } from "vitest";
import { z, ZodError } from "zod";
import type { Request, Response, NextFunction } from "express";
import {
  AppError,
  naoEncontrado,
  naoAutenticado,
  semPermissao,
  tratadorDeErros,
} from "../src/infra/errors.js";

function respostaFalsa() {
  const json = vi.fn();
  const status = vi.fn(() => ({ json }));
  return { resposta: { status } as unknown as Response, status, json };
}

function tratar(erro: unknown) {
  const { resposta, status, json } = respostaFalsa();
  const proximo: NextFunction = vi.fn();
  tratadorDeErros(erro, {} as Request, resposta, proximo);
  return { status, json };
}

describe("erros nomeados", () => {
  it("naoEncontrado responde 404 com o nome do recurso na mensagem", () => {
    const erro = naoEncontrado("Startup");

    expect(erro).toBeInstanceOf(AppError);
    expect(erro.status).toBe(404);
    expect(erro.codigo).toBe("NAO_ENCONTRADO");
    expect(erro.message).toContain("Startup");
  });

  it("naoAutenticado responde 401", () => {
    expect(naoAutenticado().status).toBe(401);
    expect(naoAutenticado().codigo).toBe("NAO_AUTENTICADO");
  });

  it("semPermissao responde 403", () => {
    expect(semPermissao().status).toBe(403);
    expect(semPermissao().codigo).toBe("SEM_PERMISSAO");
  });
});

describe("tratador de erros", () => {
  it("traduz erro de validacao do Zod em 400 com os detalhes do campo", () => {
    const schema = z.object({ pauta: z.string().min(1) });
    const resultado = schema.safeParse({});

    expect(resultado.success).toBe(false);
    const { status, json } = tratar(resultado.error);

    expect(status).toHaveBeenCalledWith(400);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({ codigo: "ENTRADA_INVALIDA", detalhes: expect.anything() }),
    );
  });

  it("usa o status e o codigo do AppError quando o erro e da aplicacao", () => {
    const { status, json } = tratar(new AppError(409, "COTA_ESGOTADA", "Cota esgotada"));

    expect(status).toHaveBeenCalledWith(409);
    expect(json).toHaveBeenCalledWith({ codigo: "COTA_ESGOTADA", mensagem: "Cota esgotada" });
  });

  it("responde 500 generico quando o erro nao e reconhecido", () => {
    const { status, json } = tratar(new Error("falha inesperada"));

    expect(status).toHaveBeenCalledWith(500);
    expect(json).toHaveBeenCalledWith({
      codigo: "ERRO_INTERNO",
      mensagem: "Erro interno do servidor",
    });
  });

  it("nao vaza a mensagem original do erro nao tratado para o cliente", () => {
    const { json } = tratar(new Error("connect ECONNREFUSED 127.0.0.1:5432"));

    expect(JSON.stringify(json.mock.calls)).not.toContain("ECONNREFUSED");
  });

  it("aceita ZodError construido diretamente", () => {
    const { status } = tratar(new ZodError([]));

    expect(status).toHaveBeenCalledWith(400);
  });
});
