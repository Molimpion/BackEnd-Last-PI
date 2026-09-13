import { describe, it, expect } from "vitest";
import request from "supertest";
import { criarApp } from "../src/app.js";

describe("GET /health", () => {
  it("responde 200 com status ok", async () => {
    const resposta = await request(criarApp()).get("/health");

    expect(resposta.status).toBe(200);
    expect(resposta.body).toEqual({ status: "ok" });
  });
});
