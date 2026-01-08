# TheraFlow — Wireframes (texto) e Fluxos

## Mapa de navegação (MVP)
Bottom tabs:
1) Home (Hoje)  2) Agenda  3) Clientes  4) Financeiro  5) Perfil

Fluxos principais:
- Onboarding -> Home
- Clientes -> Cliente Detalhe -> Nova Sessão/Agendar
- Agenda -> Detalhe da sessão -> Registrar anotação e pagamento
- Financeiro -> Relatório do mês -> Detalhe de pendências

---

## Tela: Onboarding (Wizard 3 passos)
[Logo TheraFlow]
Passo 1: Dados do terapeuta (nome, telefone, cidade)
Passo 2: Preferências (duração padrão sessão, valor padrão, horário de atendimento)
Passo 3: Criar primeiro cliente (opcional) + tutorial rápido (30s)

CTA: “Começar”

---

## Tela: Login
[Email] [Senha]
( ) Manter conectado
[Entrar]
[Esqueci a senha]
[Criar conta]

---

## Tela: Home (Hoje)
Topo: “Hoje, 07 Jan”
Card: Próxima sessão (hora, cliente, tipo)
Lista: Sessões do dia (status)
CTA: [+ Agendar]

---

## Tela: Agenda (Semanal/Mensal)
Calendário com dots
Lista por dia
Filtro: Status / Tipo / Cliente
CTA: [+ Agendar]

---

## Tela: Clientes
Busca
Lista com: Nome, última sessão, próximos agendamentos
CTA: [+ Novo Cliente]

---

## Tela: Cliente Detalhe
Topo: Nome + telefone (botão WhatsApp)
Abas:
- Histórico (sessões)
- Observações (livre)
- Pacotes (opcional fase 2)
CTA: [+ Nova Sessão] [+ Agendar]

---

## Tela: Sessão (Detalhe)
Campos:
- Data/hora
- Tipo de terapia
- Status (confirmado/faltou/remarcado)
- Valor
- Anotações (texto)
- Pagamento (pago/pendente + método)
Botões: [Salvar] [Marcar como Pago]

---

## Tela: Financeiro
Cards:
- Recebido no mês
- Pendente
- Próximos 7 dias
Lista: Pendências
CTA: “Gerar Relatório (PDF)” (fase 2)

---

## Tela: Perfil/Plano
Dados do terapeuta
Configurações:
- Duração padrão
- Valor padrão
- Lembretes (on/off)
- Backup (fase 2)
Plano:
- Free/Pro/Premium
CTA: “Assinar Pro”
