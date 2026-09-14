-- CreateEnum
CREATE TYPE "TipoDeConta" AS ENUM ('STARTUP', 'PESSOA', 'ADMINISTRADOR');

-- CreateEnum
CREATE TYPE "StatusDaConta" AS ENUM ('ATIVA', 'INATIVA', 'SUSPENSA');

-- CreateEnum
CREATE TYPE "Papel" AS ENUM ('INVESTIDOR', 'MENTOR');

-- CreateEnum
CREATE TYPE "Segmento" AS ENUM ('FINTECH', 'HEALTHTECH', 'EDTECH', 'AGROTECH', 'HRTECH', 'LEGALTECH', 'MARTECH', 'LOGTECH', 'GOVTECH', 'CONSTRUTECH', 'ECONOMIA_CRIATIVA', 'RETAILTECH');

-- CreateEnum
CREATE TYPE "AreaDeExpertise" AS ENUM ('PRODUTO', 'TECNOLOGIA', 'DESIGN_E_UX', 'MARKETING', 'FINANCAS', 'VENDAS_E_GO_TO_MARKET', 'PESSOAS_E_CULTURA', 'JURIDICO_E_SOCIETARIO', 'CAPTACAO_E_INVESTIMENTO');

-- CreateEnum
CREATE TYPE "EstagioDaStartup" AS ENUM ('IDEACAO', 'VALIDACAO', 'TRACAO', 'ESCALA');

-- CreateEnum
CREATE TYPE "NaturezaDaBusca" AS ENUM ('CAPITAL', 'MENTORIA', 'AMBOS');

-- CreateEnum
CREATE TYPE "ModeloDeNegocio" AS ENUM ('B2B', 'B2C', 'AMBOS');

-- CreateEnum
CREATE TYPE "StatusDeModeracao" AS ENUM ('PENDENTE', 'APROVADO', 'REPROVADO');

-- CreateEnum
CREATE TYPE "StatusDaSolicitacao" AS ENUM ('PENDENTE', 'ACEITA', 'RECUSADA', 'EXPIRADA');

-- CreateEnum
CREATE TYPE "StatusDaReuniao" AS ENUM ('PROPOSTA', 'CONFIRMADA', 'RECUSADA', 'REALIZADA', 'NAO_REALIZADA');

-- CreateEnum
CREATE TYPE "VisibilidadeDoFeedback" AS ENUM ('PUBLICA', 'STARTUP_APOS_TERCEIRA', 'SOMENTE_ADMINISTRADOR');

-- CreateEnum
CREATE TYPE "StatusDaAutorizacao" AS ENUM ('PENDENTE', 'APROVADA', 'NEGADA');

-- CreateEnum
CREATE TYPE "PublicoDoPlano" AS ENUM ('STARTUP', 'INVESTIDOR', 'MENTOR');

-- CreateEnum
CREATE TYPE "NivelDoPlano" AS ENUM ('GRATUITO', 'PRO', 'PREMIUM');

-- CreateEnum
CREATE TYPE "StatusDaAssinatura" AS ENUM ('SEM_PLANO', 'ATIVA', 'CANCELADA_VIGENTE', 'INADIMPLENTE_EM_TOLERANCIA', 'ENCERRADA');

-- CreateEnum
CREATE TYPE "StatusDaCobranca" AS ENUM ('PENDENTE', 'PAGA', 'FALHOU', 'ESTORNADA');

-- CreateEnum
CREATE TYPE "OrigemDoEvento" AS ENUM ('WEBHOOK', 'RECONCILIACAO');

-- CreateEnum
CREATE TYPE "AcaoDeAuditoria" AS ENUM ('MODERACAO_APROVADA', 'MODERACAO_REPROVADA', 'ACESSO_CONCEDIDO', 'ACESSO_NEGADO', 'ACESSO_REVOGADO', 'DADO_PROTEGIDO_ACESSADO', 'ASSINATURA_ALTERADA', 'PAGAMENTO_REGISTRADO', 'PAPEL_ADICIONADO', 'PAPEL_REMOVIDO', 'LOGIN_FALHOU', 'AUDITORIA_CONSULTADA', 'CONTA_EXCLUIDA', 'ADMINISTRADOR_CRIADO', 'CONTA_SUSPENSA', 'CONTA_REATIVADA', 'SENHA_ALTERADA');

-- CreateEnum
CREATE TYPE "TipoDeConsentimento" AS ENUM ('TERMOS_DE_USO', 'TRATAMENTO_DE_DADOS', 'COMUNICACOES_DE_MARKETING');

-- CreateEnum
CREATE TYPE "TipoDeNotificacao" AS ENUM ('SOLICITACAO_RECEBIDA', 'SOLICITACAO_ACEITA', 'SOLICITACAO_RECUSADA', 'SOLICITACAO_PRESTES_A_EXPIRAR', 'MENSAGEM_RECEBIDA', 'REUNIAO_PROPOSTA', 'REUNIAO_CONFIRMADA', 'REUNIAO_RECUSADA', 'CADASTRO_APROVADO', 'CADASTRO_REPROVADO', 'COBRANCA_APROVADA', 'COBRANCA_FALHOU', 'ASSINATURA_PRESTES_A_VENCER', 'ASSINATURA_REBAIXADA', 'LOGIN_NOVO', 'SENHA_ALTERADA', 'MFA_ALTERADO');

-- CreateTable
CREATE TABLE "Conta" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "senhaHash" TEXT NOT NULL,
    "tipo" "TipoDeConta" NOT NULL,
    "status" "StatusDaConta" NOT NULL DEFAULT 'ATIVA',
    "emailVerificadoEm" TIMESTAMP(3),
    "mfaSegredo" TEXT,
    "mfaAtivadoEm" TIMESTAMP(3),
    "anonimizadaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Conta_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CodigoDeRecuperacaoMfa" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "codigoHash" TEXT NOT NULL,
    "usadoEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CodigoDeRecuperacaoMfa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pessoa" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "cidade" TEXT NOT NULL,
    "linkedin" TEXT NOT NULL,
    "empresaOuAtuacao" TEXT NOT NULL,
    "statusDeModeracao" "StatusDeModeracao" NOT NULL DEFAULT 'PENDENTE',
    "motivoDaModeracao" TEXT,
    "moderadaEm" TIMESTAMP(3),
    "verificadaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pessoa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PerfilInvestidor" (
    "id" TEXT NOT NULL,
    "pessoaId" TEXT NOT NULL,
    "tese" TEXT,
    "segmentosDeInteresse" "Segmento"[],
    "estagiosDeInteresse" "EstagioDaStartup"[],
    "ticketMinimo" INTEGER NOT NULL,
    "ticketMaximo" INTEGER NOT NULL,
    "modeloDeNegocio" "ModeloDeNegocio" NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PerfilInvestidor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PerfilMentor" (
    "id" TEXT NOT NULL,
    "pessoaId" TEXT NOT NULL,
    "horasPorMes" INTEGER NOT NULL,
    "avaliacoesRecebidas" INTEGER NOT NULL DEFAULT 0,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PerfilMentor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AreaDeMentoria" (
    "id" TEXT NOT NULL,
    "perfilMentorId" TEXT NOT NULL,
    "area" "AreaDeExpertise" NOT NULL,
    "anosDeExperiencia" INTEGER NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AreaDeMentoria_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Startup" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "segmentos" "Segmento"[],
    "estagio" "EstagioDaStartup" NOT NULL,
    "cidade" TEXT NOT NULL,
    "descricaoCurta" TEXT NOT NULL,
    "capitalMinimo" INTEGER NOT NULL,
    "capitalMaximo" INTEGER NOT NULL,
    "naturezaDaBusca" "NaturezaDaBusca" NOT NULL,
    "cnpj" TEXT,
    "site" TEXT,
    "logotipoUrl" TEXT,
    "vinculoPortoDigital" TEXT,
    "statusDeModeracao" "StatusDeModeracao" NOT NULL DEFAULT 'PENDENTE',
    "motivoDaModeracao" TEXT,
    "moderadaEm" TIMESTAMP(3),
    "verificadaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Startup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Canvas" (
    "id" TEXT NOT NULL,
    "startupId" TEXT NOT NULL,
    "problema" TEXT NOT NULL,
    "solucao" TEXT NOT NULL,
    "propostaDeValor" TEXT NOT NULL,
    "tamanhoDeMercado" TEXT NOT NULL,
    "tracao" TEXT NOT NULL,
    "modeloDeReceita" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Canvas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Solicitacao" (
    "id" TEXT NOT NULL,
    "startupId" TEXT NOT NULL,
    "pessoaId" TEXT NOT NULL,
    "papelDoDestinatario" "Papel" NOT NULL,
    "pauta" TEXT NOT NULL,
    "status" "StatusDaSolicitacao" NOT NULL DEFAULT 'PENDENTE',
    "enviadaEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiraEm" TIMESTAMP(3) NOT NULL,
    "respondidaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Solicitacao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Conversa" (
    "id" TEXT NOT NULL,
    "solicitacaoId" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Conversa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Mensagem" (
    "id" TEXT NOT NULL,
    "conversaId" TEXT NOT NULL,
    "autorContaId" TEXT NOT NULL,
    "conteudo" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Mensagem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reuniao" (
    "id" TEXT NOT NULL,
    "solicitacaoId" TEXT NOT NULL,
    "pauta" TEXT NOT NULL,
    "status" "StatusDaReuniao" NOT NULL DEFAULT 'PROPOSTA',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Reuniao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PropostaDeHorario" (
    "id" TEXT NOT NULL,
    "reuniaoId" TEXT NOT NULL,
    "autorContaId" TEXT NOT NULL,
    "inicioEm" TIMESTAMP(3) NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PropostaDeHorario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Feedback" (
    "id" TEXT NOT NULL,
    "reuniaoId" TEXT NOT NULL,
    "avaliadorContaId" TEXT NOT NULL,
    "avaliadoContaId" TEXT NOT NULL,
    "qualidadeDaConversa" INTEGER,
    "utilidadeDaOrientacao" INTEGER,
    "preparacaoDaStartup" INTEGER,
    "aderenciaATese" INTEGER,
    "aberturaAOrientacao" INTEGER,
    "comentario" TEXT,
    "visibilidade" "VisibilidadeDoFeedback" NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Feedback_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VisualizacaoDePerfil" (
    "id" TEXT NOT NULL,
    "startupId" TEXT NOT NULL,
    "pessoaId" TEXT NOT NULL,
    "papel" "Papel" NOT NULL,
    "visualizadaEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VisualizacaoDePerfil_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AutorizacaoDeAcesso" (
    "id" TEXT NOT NULL,
    "startupId" TEXT NOT NULL,
    "pessoaId" TEXT NOT NULL,
    "papelDoSolicitante" "Papel" NOT NULL,
    "status" "StatusDaAutorizacao" NOT NULL DEFAULT 'PENDENTE',
    "solicitadaEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "respondidaEm" TIMESTAMP(3),
    "revogadaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AutorizacaoDeAcesso_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Plano" (
    "id" TEXT NOT NULL,
    "publico" "PublicoDoPlano" NOT NULL,
    "nivel" "NivelDoPlano" NOT NULL,
    "precoEmCentavos" INTEGER NOT NULL,
    "cotaMensalDeSolicitacoes" INTEGER,
    "limiteDeMatchesVisiveis" INTEGER,
    "limiteMensalDeAceites" INTEGER,
    "feedbackDetalhado" BOOLEAN NOT NULL,
    "destaqueNaBusca" BOOLEAN NOT NULL,
    "buscaAvancada" BOOLEAN NOT NULL,
    "metricasDeVisualizacao" BOOLEAN NOT NULL,
    "exportacaoDeRelatorios" BOOLEAN NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Plano_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Assinatura" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "publico" "PublicoDoPlano" NOT NULL,
    "planoId" TEXT NOT NULL,
    "status" "StatusDaAssinatura" NOT NULL DEFAULT 'SEM_PLANO',
    "idNoGateway" TEXT,
    "periodoAtualInicio" TIMESTAMP(3),
    "periodoAtualFim" TIMESTAMP(3),
    "canceladaEm" TIMESTAMP(3),
    "toleranciaAte" TIMESTAMP(3),
    "encerradaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Assinatura_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Cobranca" (
    "id" TEXT NOT NULL,
    "assinaturaId" TEXT NOT NULL,
    "valorEmCentavos" INTEGER NOT NULL,
    "status" "StatusDaCobranca" NOT NULL DEFAULT 'PENDENTE',
    "idNoGateway" TEXT NOT NULL,
    "vencimentoEm" TIMESTAMP(3),
    "pagaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Cobranca_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventoDoGateway" (
    "id" TEXT NOT NULL,
    "origem" "OrigemDoEvento" NOT NULL,
    "idDoEventoNoGateway" TEXT,
    "idDaCobrancaNoGateway" TEXT,
    "tipo" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "processadoEm" TIMESTAMP(3),
    "erro" TEXT,
    "recebidoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EventoDoGateway_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TrabalhoPendente" (
    "id" TEXT NOT NULL,
    "tipo" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "enfileiradoEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TrabalhoPendente_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Consentimento" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "tipo" "TipoDeConsentimento" NOT NULL,
    "versaoDoDocumento" TEXT NOT NULL,
    "ip" TEXT NOT NULL,
    "aceitoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revogadoEm" TIMESTAMP(3),
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Consentimento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RegistroDeAuditoria" (
    "id" TEXT NOT NULL,
    "atorContaId" TEXT,
    "acao" "AcaoDeAuditoria" NOT NULL,
    "alvoTipo" TEXT,
    "alvoId" TEXT,
    "ip" TEXT,
    "metadados" JSONB,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RegistroDeAuditoria_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notificacao" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "tipo" "TipoDeNotificacao" NOT NULL,
    "mensagem" TEXT NOT NULL,
    "lidaEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Notificacao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PreferenciaDeNotificacao" (
    "id" TEXT NOT NULL,
    "contaId" TEXT NOT NULL,
    "tipo" "TipoDeNotificacao" NOT NULL,
    "receberPorEmail" BOOLEAN NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PreferenciaDeNotificacao_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Conta_email_key" ON "Conta"("email");

-- CreateIndex
CREATE INDEX "CodigoDeRecuperacaoMfa_contaId_idx" ON "CodigoDeRecuperacaoMfa"("contaId");

-- CreateIndex
CREATE UNIQUE INDEX "Pessoa_contaId_key" ON "Pessoa"("contaId");

-- CreateIndex
CREATE INDEX "Pessoa_statusDeModeracao_idx" ON "Pessoa"("statusDeModeracao");

-- CreateIndex
CREATE UNIQUE INDEX "PerfilInvestidor_pessoaId_key" ON "PerfilInvestidor"("pessoaId");

-- CreateIndex
CREATE INDEX "PerfilInvestidor_segmentosDeInteresse_idx" ON "PerfilInvestidor" USING GIN ("segmentosDeInteresse");

-- CreateIndex
CREATE INDEX "PerfilInvestidor_estagiosDeInteresse_idx" ON "PerfilInvestidor" USING GIN ("estagiosDeInteresse");

-- CreateIndex
CREATE UNIQUE INDEX "PerfilMentor_pessoaId_key" ON "PerfilMentor"("pessoaId");

-- CreateIndex
CREATE INDEX "AreaDeMentoria_area_idx" ON "AreaDeMentoria"("area");

-- CreateIndex
CREATE UNIQUE INDEX "AreaDeMentoria_perfilMentorId_area_key" ON "AreaDeMentoria"("perfilMentorId", "area");

-- CreateIndex
CREATE UNIQUE INDEX "Startup_contaId_key" ON "Startup"("contaId");

-- CreateIndex
CREATE INDEX "Startup_statusDeModeracao_estagio_idx" ON "Startup"("statusDeModeracao", "estagio");

-- CreateIndex
CREATE INDEX "Startup_segmentos_idx" ON "Startup" USING GIN ("segmentos");

-- CreateIndex
CREATE INDEX "Startup_criadoEm_idx" ON "Startup"("criadoEm");

-- CreateIndex
CREATE INDEX "Startup_cnpj_idx" ON "Startup"("cnpj");

-- CreateIndex
CREATE UNIQUE INDEX "Canvas_startupId_key" ON "Canvas"("startupId");

-- CreateIndex
CREATE INDEX "Solicitacao_status_expiraEm_idx" ON "Solicitacao"("status", "expiraEm");

-- CreateIndex
CREATE INDEX "Solicitacao_startupId_enviadaEm_idx" ON "Solicitacao"("startupId", "enviadaEm");

-- CreateIndex
CREATE INDEX "Solicitacao_pessoaId_status_idx" ON "Solicitacao"("pessoaId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Conversa_solicitacaoId_key" ON "Conversa"("solicitacaoId");

-- CreateIndex
CREATE INDEX "Mensagem_conversaId_criadoEm_idx" ON "Mensagem"("conversaId", "criadoEm");

-- CreateIndex
CREATE INDEX "Reuniao_solicitacaoId_idx" ON "Reuniao"("solicitacaoId");

-- CreateIndex
CREATE INDEX "Reuniao_status_idx" ON "Reuniao"("status");

-- CreateIndex
CREATE INDEX "PropostaDeHorario_reuniaoId_criadoEm_idx" ON "PropostaDeHorario"("reuniaoId", "criadoEm");

-- CreateIndex
CREATE INDEX "Feedback_avaliadoContaId_visibilidade_idx" ON "Feedback"("avaliadoContaId", "visibilidade");

-- CreateIndex
CREATE UNIQUE INDEX "Feedback_reuniaoId_avaliadorContaId_key" ON "Feedback"("reuniaoId", "avaliadorContaId");

-- CreateIndex
CREATE INDEX "VisualizacaoDePerfil_startupId_visualizadaEm_idx" ON "VisualizacaoDePerfil"("startupId", "visualizadaEm");

-- CreateIndex
CREATE INDEX "AutorizacaoDeAcesso_startupId_status_idx" ON "AutorizacaoDeAcesso"("startupId", "status");

-- CreateIndex
CREATE INDEX "AutorizacaoDeAcesso_pessoaId_startupId_idx" ON "AutorizacaoDeAcesso"("pessoaId", "startupId");

-- CreateIndex
CREATE UNIQUE INDEX "Plano_publico_nivel_key" ON "Plano"("publico", "nivel");

-- CreateIndex
CREATE UNIQUE INDEX "Assinatura_idNoGateway_key" ON "Assinatura"("idNoGateway");

-- CreateIndex
CREATE INDEX "Assinatura_status_periodoAtualFim_idx" ON "Assinatura"("status", "periodoAtualFim");

-- CreateIndex
CREATE INDEX "Assinatura_status_toleranciaAte_idx" ON "Assinatura"("status", "toleranciaAte");

-- CreateIndex
CREATE UNIQUE INDEX "Assinatura_contaId_publico_key" ON "Assinatura"("contaId", "publico");

-- CreateIndex
CREATE UNIQUE INDEX "Cobranca_idNoGateway_key" ON "Cobranca"("idNoGateway");

-- CreateIndex
CREATE INDEX "Cobranca_assinaturaId_criadoEm_idx" ON "Cobranca"("assinaturaId", "criadoEm");

-- CreateIndex
CREATE UNIQUE INDEX "EventoDoGateway_idDoEventoNoGateway_key" ON "EventoDoGateway"("idDoEventoNoGateway");

-- CreateIndex
CREATE INDEX "EventoDoGateway_processadoEm_recebidoEm_idx" ON "EventoDoGateway"("processadoEm", "recebidoEm");

-- CreateIndex
CREATE INDEX "EventoDoGateway_idDaCobrancaNoGateway_idx" ON "EventoDoGateway"("idDaCobrancaNoGateway");

-- CreateIndex
CREATE INDEX "TrabalhoPendente_enfileiradoEm_idx" ON "TrabalhoPendente"("enfileiradoEm");

-- CreateIndex
CREATE INDEX "Consentimento_contaId_tipo_idx" ON "Consentimento"("contaId", "tipo");

-- CreateIndex
CREATE INDEX "RegistroDeAuditoria_atorContaId_criadoEm_idx" ON "RegistroDeAuditoria"("atorContaId", "criadoEm");

-- CreateIndex
CREATE INDEX "RegistroDeAuditoria_criadoEm_idx" ON "RegistroDeAuditoria"("criadoEm");

-- CreateIndex
CREATE INDEX "Notificacao_contaId_criadoEm_idx" ON "Notificacao"("contaId", "criadoEm");

-- CreateIndex
CREATE UNIQUE INDEX "PreferenciaDeNotificacao_contaId_tipo_key" ON "PreferenciaDeNotificacao"("contaId", "tipo");

-- AddForeignKey
ALTER TABLE "CodigoDeRecuperacaoMfa" ADD CONSTRAINT "CodigoDeRecuperacaoMfa_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Pessoa" ADD CONSTRAINT "Pessoa_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PerfilInvestidor" ADD CONSTRAINT "PerfilInvestidor_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "Pessoa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PerfilMentor" ADD CONSTRAINT "PerfilMentor_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "Pessoa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AreaDeMentoria" ADD CONSTRAINT "AreaDeMentoria_perfilMentorId_fkey" FOREIGN KEY ("perfilMentorId") REFERENCES "PerfilMentor"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Startup" ADD CONSTRAINT "Startup_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Canvas" ADD CONSTRAINT "Canvas_startupId_fkey" FOREIGN KEY ("startupId") REFERENCES "Startup"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Solicitacao" ADD CONSTRAINT "Solicitacao_startupId_fkey" FOREIGN KEY ("startupId") REFERENCES "Startup"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Solicitacao" ADD CONSTRAINT "Solicitacao_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "Pessoa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Conversa" ADD CONSTRAINT "Conversa_solicitacaoId_fkey" FOREIGN KEY ("solicitacaoId") REFERENCES "Solicitacao"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Mensagem" ADD CONSTRAINT "Mensagem_conversaId_fkey" FOREIGN KEY ("conversaId") REFERENCES "Conversa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Mensagem" ADD CONSTRAINT "Mensagem_autorContaId_fkey" FOREIGN KEY ("autorContaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reuniao" ADD CONSTRAINT "Reuniao_solicitacaoId_fkey" FOREIGN KEY ("solicitacaoId") REFERENCES "Solicitacao"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PropostaDeHorario" ADD CONSTRAINT "PropostaDeHorario_reuniaoId_fkey" FOREIGN KEY ("reuniaoId") REFERENCES "Reuniao"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PropostaDeHorario" ADD CONSTRAINT "PropostaDeHorario_autorContaId_fkey" FOREIGN KEY ("autorContaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Feedback" ADD CONSTRAINT "Feedback_reuniaoId_fkey" FOREIGN KEY ("reuniaoId") REFERENCES "Reuniao"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Feedback" ADD CONSTRAINT "Feedback_avaliadorContaId_fkey" FOREIGN KEY ("avaliadorContaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Feedback" ADD CONSTRAINT "Feedback_avaliadoContaId_fkey" FOREIGN KEY ("avaliadoContaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VisualizacaoDePerfil" ADD CONSTRAINT "VisualizacaoDePerfil_startupId_fkey" FOREIGN KEY ("startupId") REFERENCES "Startup"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VisualizacaoDePerfil" ADD CONSTRAINT "VisualizacaoDePerfil_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "Pessoa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AutorizacaoDeAcesso" ADD CONSTRAINT "AutorizacaoDeAcesso_startupId_fkey" FOREIGN KEY ("startupId") REFERENCES "Startup"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AutorizacaoDeAcesso" ADD CONSTRAINT "AutorizacaoDeAcesso_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "Pessoa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assinatura" ADD CONSTRAINT "Assinatura_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assinatura" ADD CONSTRAINT "Assinatura_planoId_fkey" FOREIGN KEY ("planoId") REFERENCES "Plano"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Cobranca" ADD CONSTRAINT "Cobranca_assinaturaId_fkey" FOREIGN KEY ("assinaturaId") REFERENCES "Assinatura"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Consentimento" ADD CONSTRAINT "Consentimento_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RegistroDeAuditoria" ADD CONSTRAINT "RegistroDeAuditoria_atorContaId_fkey" FOREIGN KEY ("atorContaId") REFERENCES "Conta"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notificacao" ADD CONSTRAINT "Notificacao_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PreferenciaDeNotificacao" ADD CONSTRAINT "PreferenciaDeNotificacao_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "Conta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE UNIQUE INDEX "Solicitacao_pendente_unica" ON "Solicitacao"("startupId", "pessoaId", "papelDoDestinatario") WHERE "status" = 'PENDENTE';

CREATE UNIQUE INDEX "AutorizacaoDeAcesso_pendente_unica" ON "AutorizacaoDeAcesso"("startupId", "pessoaId", "papelDoSolicitante") WHERE "status" = 'PENDENTE';

CREATE UNIQUE INDEX "Reuniao_ativa_unica" ON "Reuniao"("solicitacaoId") WHERE "status" IN ('PROPOSTA', 'CONFIRMADA');
