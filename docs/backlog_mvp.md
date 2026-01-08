# TheraFlow — Backlog Técnico Detalhado (MVP)

## Épico A — Fundação do App
A1. Criar projeto Flutter + estrutura de pastas (lib/)
A2. Configurar roteamento com go_router
A3. Definir tema (Typography, spacing, cores neutras)
A4. Camada de serviços (AuthService, FirestoreService)
A5. Tratamento global de erros e loading states

Critério de aceite:
- App abre e navega entre telas sem crashes
- Estrutura organizada por feature

---

## Épico B — Autenticação e Conta
B1. UI Login/Cadastro/Reset
B2. Implementar FirebaseAuth (email/senha)
B3. Persistir sessão (auto-login)
B4. Logout
B5. Regras básicas de segurança (Firestore Rules) — doc inicial

Aceite:
- Usuário cria conta, entra, sai, recupera senha

---

## Épico C — Onboarding
C1. Detectar primeiro acesso (flag em user profile)
C2. Wizard 3 passos (dados, preferências, primeiro cliente opcional)
C3. Salvar preferências do terapeuta em `users/{uid}`

Aceite:
- No primeiro login, wizard aparece e depois some

---

## Épico D — Clientes (CRUD)
D1. Model `Client`
D2. Lista de clientes com busca
D3. Tela Novo/Editar cliente
D4. Tela Cliente Detalhe com histórico (sessions do client)
D5. Persistência no Firestore: `users/{uid}/clients`

Aceite:
- Criar/editar/excluir cliente e listar corretamente

---

## Épico E — Sessões / Agenda
E1. Model `Session`
E2. Criar sessão a partir de:
  - Home (+Agendar)
  - Cliente Detalhe (+Agendar)
E3. Agenda por dia/semana (lista + agrupamento)
E4. Atualizar status (confirmado/faltou/remarcado)
E5. Persistência: `users/{uid}/sessions`

Aceite:
- Sessões aparecem em Home (Hoje) e Agenda

---

## Épico F — Anotações e Evolução
F1. Campo anotação livre por sessão
F2. Histórico cronológico no cliente
F3. (Opcional MVP+) Tag simples do tipo de terapia (enum)

Aceite:
- Anotações ficam salvas e acessíveis no histórico

---

## Épico G — Financeiro
G1. Model `Payment` (ou campos em Session)
G2. Marcar pago/pendente
G3. Tela Financeiro: total recebido/pending no mês (agregado)
G4. Lista de pendências com quick actions

Aceite:
- Totais batem com sessões do período

---

## Épico H — Notificações (MVP leve)
H1. Preferência de lembrete (ex.: 2h antes)
H2. (MVP) Notificação local simples (se optar por pacote local)
H3. (Fase 2) FCM + Cloud Functions agendadas

Aceite:
- Lembrete dispara conforme preferência (mínimo viável)

---

## Definição de pronto (DoD)
- Telas principais funcionais
- Persistência de dados básica
- Sem recursos “clínicos”
- UX aceitável (loading, empty states, validação)
