# PRD Enxuto — Melhorias de Produto do App

## 1. Contexto

O app já possui uma base funcional com módulos de clientes, agenda, sessões, pacotes, financeiro, autenticação e persistência local/sincronização.

Nesta etapa, o foco não é billing.  
O objetivo é validar:

- utilidade real do app
- facilidade de uso
- valor percebido
- retenção de uso
- clareza dos fluxos principais

O app deve evoluir de:

**“app de cadastro e agenda”**

para:

**“app que ajuda o profissional a organizar a rotina, acompanhar clientes, reduzir perdas e aumentar retenção”**

---

## 2. Objetivo desta fase

Melhorar o produto para que ele ajude o usuário a:

1. organizar melhor os clientes
2. agendar mais rápido
3. registrar atendimentos com facilidade
4. lembrar retornos, pendências e pacotes
5. entender rapidamente o que precisa fazer no dia

---

## 3. Fluxo principal do produto

O fluxo principal que deve ser fortalecido é:

**Cliente → Agendamento → Sessão → Retorno → Pagamento → Recompra**

Toda melhoria deve fortalecer esse fluxo.

---

## 4. Problemas atuais do produto

Hoje o app já funciona, mas ainda apresenta limitações importantes em valor percebido:

- agenda ainda muito manual
- cliente ainda funciona mais como cadastro do que como CRM
- sessão ainda não é uma ferramenta forte de trabalho
- poucos alertas acionáveis
- home ainda pode ser mais útil
- pacotes ainda parecem isolados
- financeiro ainda está mais resumido do que operacional
- pouca ajuda prática para follow-up e retenção

---

## 5. Pilares prioritários

Os 4 pilares desta fase são:

### 5.1. Agenda inteligente
A agenda deve ficar mais rápida, visual e útil.

### 5.2. Cliente como mini-CRM
A ficha do cliente deve mostrar situação, histórico e próxima ação.

### 5.3. Sessão como centro do trabalho
A sessão deve virar uma tela prática de evolução e acompanhamento.

### 5.4. Alertas, retorno e recompra
O app deve ajudar o profissional a lembrar o que precisa fazer.

---

## 6. Melhorias prioritárias

# PRIORIDADE 1 — Maior ganho de valor imediato

---

### Funcionalidade 1 — Home mais acionável

#### Problema
A home ainda não concentra bem o que o usuário precisa ver e fazer no dia.

#### Solução
Transformar a home em uma central de ação com resumo operacional real.

#### Itens da home
- sessões de hoje
- próxima sessão
- pagamentos pendentes
- recebimentos do dia
- clientes sem retorno
- pacotes acabando
- ações rápidas

#### Ações rápidas
- novo cliente
- nova sessão
- registrar pagamento
- abrir agenda
- abrir clientes em risco

#### Critérios de aceite
- ao abrir o app, o usuário entende rapidamente o que precisa fazer
- a home mostra pendências reais
- a home reduz navegação desnecessária

#### Impacto esperado
Aumenta muito a percepção de utilidade no dia a dia.

---

### Funcionalidade 2 — Agenda mais inteligente

#### Problema
A agenda atual resolve o básico, mas ainda depende de muito esforço manual.

#### Solução
Adicionar recursos para tornar o agendamento mais rápido e operacional.

#### Melhorias
- visão semanal
- filtro por status
- filtro por período
- conflito de horário
- remarcação rápida
- duplicar sessão
- recorrência
- bloqueio de horário indisponível
- exibição de horários livres

#### Ações rápidas ao tocar na sessão
- editar
- remarcar
- confirmar
- cancelar
- iniciar atendimento

#### Critérios de aceite
- usuário consegue remarcar em poucos toques
- usuário consegue ver a semana com clareza
- app alerta conflito de horário
- agenda fica mais visual e prática

#### Impacto esperado
Melhora bastante a rotina operacional.

---

### Funcionalidade 3 — Cliente como mini-CRM

#### Problema
A tela de cliente ainda é mais um cadastro do que uma visão de relacionamento.

#### Solução
Adicionar indicadores, contexto e histórico útil ao perfil do cliente.

#### Novos campos e indicadores
- objetivo do cliente
- data de início
- frequência ideal
- última sessão
- próxima sessão
- total de sessões
- total gasto
- número de faltas
- número de remarcações
- status do cliente
- tags

#### Status sugeridos
- novo
- ativo
- pausado
- em risco
- inativo

#### Tags sugeridas
- VIP
- retorno
- pacote
- inadimplente
- novo

#### Estrutura ideal da tela
- Resumo
- Sessões
- Financeiro
- Pacotes
- Observações

#### Critérios de aceite
- usuário entende rapidamente a situação do cliente
- perfil do cliente mostra contexto útil
- histórico fica mais fácil de consultar

#### Impacto esperado
Aumenta retenção e valor percebido do produto.

---

### Funcionalidade 4 — Sessão como centro do trabalho

#### Problema
A sessão ainda parece mais um registro final do que uma ferramenta de trabalho.

#### Solução
Transformar a sessão em uma tela prática para evolução e acompanhamento.

#### Melhorias
- template de anotação
- campo “como o cliente chegou hoje”
- campo “o que foi feito”
- campo “orientações”
- campo “próximos passos”
- campo “observações”
- copiar sessão anterior
- checklist
- salvar rascunho

#### Status da sessão
- agendada
- confirmada
- realizada
- faltou
- cancelada
- remarcada

#### Critérios de aceite
- usuário consegue registrar atendimento rapidamente
- histórico da evolução fica útil
- tela de sessão passa a ser central no fluxo

#### Impacto esperado
Melhora muito a experiência de uso contínuo.

---

# PRIORIDADE 2 — Retenção e operação

---

### Funcionalidade 5 — Alertas e follow-up

#### Problema
O app ainda depende demais da memória do usuário.

#### Solução
Criar alertas práticos sobre o que precisa de atenção.

#### Alertas desejados
- sessão de amanhã
- cliente sem retorno há X dias
- cliente sem próxima sessão
- pagamento pendente
- pagamento atrasado
- pacote acabando
- pacote vencendo
- cliente com muitas faltas

#### Critérios de aceite
- o usuário consegue identificar pendências sem procurar
- a home e listas mostram itens acionáveis
- alertas ajudam na retenção

#### Impacto esperado
Reduz perda de clientes e esquecimentos.

---

### Funcionalidade 6 — WhatsApp / contato rápido

#### Problema
O contato com o cliente ainda pode gerar atrito.

#### Solução
Permitir iniciar conversas rapidamente com mensagens prontas.

#### Melhorias
- abrir WhatsApp do cliente com 1 toque
- mensagens prontas para:
  - confirmação
  - lembrete
  - cobrança
  - retorno
  - renovação de pacote
  - reagendamento

#### Critérios de aceite
- usuário consegue entrar em contato sem copiar número
- envio de mensagem fica rápido
- o recurso ajuda em confirmação e retorno

#### Impacto esperado
Aumenta praticidade e retenção.

---

### Funcionalidade 7 — Pacotes mais integrados

#### Problema
Pacotes existem, mas ainda não parecem conectados ao uso diário.

#### Solução
Tornar o pacote mais visível e útil na operação.

#### Melhorias
- mostrar saldo de sessões
- mostrar progresso do pacote
- alerta de poucas sessões restantes
- alerta de vencimento
- renovação rápida
- histórico de pacotes

#### Critérios de aceite
- usuário vê facilmente saldo e vencimento
- pacote aparece integrado ao cliente
- renovação fica simples

#### Impacto esperado
Melhora recompra e continuidade do atendimento.

---

### Funcionalidade 8 — Financeiro mais operacional

#### Problema
O financeiro atual é útil, mas ainda pouco acionável.

#### Solução
Adicionar filtros e indicadores que ajudem a tomar decisão.

#### Melhorias
- filtro por período
- filtro por cliente
- filtro por status
- filtro por forma de pagamento
- recebidos hoje
- pendentes
- atrasados
- ticket médio
- faturamento por cliente
- ranking de clientes

#### Critérios de aceite
- usuário consegue enxergar pendências com facilidade
- usuário entende melhor de onde vem a receita
- financeiro passa a apoiar decisão

#### Impacto esperado
Aumenta percepção de profissionalismo.

---

# PRIORIDADE 3 — Diferenciais premium

---

### Funcionalidade 9 — Status inteligente do cliente

#### Problema
O app ainda não interpreta a base de clientes automaticamente.

#### Solução
Classificar clientes por regras simples de comportamento.

#### Classificações possíveis
- novo
- ativo
- em risco
- inativo
- inadimplente
- pacote acabando

#### Listas inteligentes
- clientes sem retorno
- clientes em risco
- clientes sem próxima sessão
- clientes com pendência
- clientes com pacote acabando

#### Critérios de aceite
- usuário consegue agir sobre listas úteis
- o app parece mais inteligente
- o recurso ajuda retenção

#### Impacto esperado
Cria sensação de produto premium.

---

### Funcionalidade 10 — Metas e desempenho

#### Problema
O usuário ainda tem pouca visibilidade de desempenho do negócio.

#### Solução
Adicionar indicadores simples de desempenho.

#### Melhorias
- meta mensal
- número de atendimentos
- ocupação da agenda
- média semanal
- melhor dia da semana
- clientes mais frequentes

#### Critérios de aceite
- usuário acompanha evolução do negócio
- dados são simples de entender
- não sobrecarrega a interface

#### Impacto esperado
Aumenta engajamento e valor percebido.

---

### Funcionalidade 11 — Exportação simples

#### Problema
Falta uma forma de levar os dados para fora do app.

#### Solução
Criar exportações básicas.

#### Melhorias
- exportar clientes
- exportar sessões
- exportar financeiro
- resumo mensal simples

#### Critérios de aceite
- usuário consegue exportar com poucos toques
- dados exportados fazem sentido
- recurso agrega profissionalismo

#### Impacto esperado
Melhora utilidade para gestão.

---

## 7. Ordem recomendada de implementação

### Fase 1
- home mais acionável
- agenda semanal
- remarcação rápida
- conflito de horário
- resumo mais rico do cliente

### Fase 2
- sessão com template
- alertas básicos
- próxima ação do cliente
- cliente sem retorno
- cliente sem próxima sessão

### Fase 3
- WhatsApp com mensagens prontas
- pacotes mais visíveis
- financeiro com filtros e ranking

### Fase 4
- status inteligente
- metas
- exportação

---

## 8. Regras de produto

### Regra 1
Toda melhoria deve reduzir esforço manual do usuário.

### Regra 2
Toda tela principal deve mostrar algo acionável, não só informativo.

### Regra 3
Toda informação importante deve estar próxima da ação correspondente.

### Regra 4
O app deve sempre responder à pergunta:
**“o que eu preciso fazer agora?”**

### Regra 5
O fluxo do usuário deve ser rápido e simples, com poucos toques.

---

## 9. Critérios gerais de sucesso desta fase

Esta fase será considerada bem-sucedida se o usuário conseguir dizer:

- “consigo organizar meus atendimentos sem esforço”
- “consigo ver quem precisa de retorno”
- “consigo lembrar pagamentos e pacotes”
- “consigo registrar a sessão rapidamente”
- “consigo entender meu dia ao abrir o app”
- “o app me ajuda a não perder cliente”

---

## 10. O que não priorizar agora

Não priorizar nesta fase:

- billing
- IA avançada
- integrações complexas
- automações pesadas
- excesso de configurações
- recursos administrativos secundários

---

## 11. Resumo executivo

O foco desta etapa deve ser fortalecer:

1. agenda inteligente
2. cliente como CRM
3. sessão prática
4. alertas e follow-up
5. pacotes e financeiro mais conectados

A missão desta fase é:

**provar valor real do produto antes de monetizar**