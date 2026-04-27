# MASTER PROMPT — Theraflow App (Fase 1 focada em funções e UX)

Quero que você atue como **product engineer sênior em Flutter**, com foco em **arquitetura, UX, produto e implementação incremental**.

Você vai trabalhar em cima deste projeto Flutter existente, chamado **Theraflow**, respeitando a estrutura atual do código e evoluindo o produto com baixo retrabalho.

---

## 1. Contexto do projeto

Este app já possui base funcional e estrutura real de produto, incluindo:

- autenticação
- clientes
- agenda
- sessões
- pacotes
- financeiro
- perfil
- onboarding
- persistência local
- sincronização com backend/Firebase

### Estrutura principal identificada no projeto

#### Arquivos principais
- `lib/src/app_router.dart`
- `lib/src/config/app_config.dart`
- `lib/src/database/database_helper.dart`

#### Models
- `lib/src/models/client.dart`
- `lib/src/models/session.dart`
- `lib/src/models/package.dart`
- `lib/src/models/payment.dart`
- `lib/src/models/user.dart`

#### Screens
- `lib/src/screens/home/home_screen.dart`
- `lib/src/screens/agenda/agenda_screen.dart`
- `lib/src/screens/clients/clients_screen.dart`
- `lib/src/screens/clients/client_detail_screen.dart`
- `lib/src/screens/clients/package_create_screen.dart`
- `lib/src/screens/sessions/session_edit_screen.dart`
- `lib/src/screens/sessions/session_start_screen.dart`
- `lib/src/screens/finance/finance_screen.dart`
- `lib/src/screens/profile/profile_screen.dart`
- `lib/src/screens/onboarding/onboarding_screen.dart`

#### Services
- `lib/src/services/client_service.dart`
- `lib/src/services/session_service.dart`
- `lib/src/services/package_service.dart`
- `lib/src/services/finance_service.dart`
- `lib/src/services/profile_service.dart`
- `lib/src/services/data_change_bus.dart`
- `lib/src/services/incremental_sync_service.dart`
- `lib/src/services/app_services.dart`

#### Widgets
- `lib/src/widgets/home_dashboard.dart`
- `lib/src/widgets/primary_button.dart`
- `lib/src/widgets/section_title.dart`
- `lib/src/widgets/revenue_sparkline.dart`

---

## 2. Regra importante desta etapa

**Não implementar billing agora.**

Mesmo que existam estes arquivos:

- `lib/src/config/billing_config.dart`
- `lib/src/services/billing_service.dart`
- `lib/src/services/iap_billing_service.dart`
- `lib/src/services/subscription_service.dart`
- `lib/src/screens/billing/paywall_screen.dart`

eles **não são prioridade nesta fase**.

O foco agora é:

- validar interfaces
- melhorar facilidade de uso
- aumentar valor percebido
- melhorar retenção
- fortalecer os fluxos principais

---

## 3. Objetivo principal

Quero evoluir o app para que ele ajude o usuário a:

1. organizar melhor os clientes
2. agendar mais rápido
3. registrar atendimentos com facilidade
4. lembrar retornos, pendências e pacotes
5. entender rapidamente o que precisa fazer no dia

### Fluxo principal do produto
**Cliente → Agendamento → Sessão → Retorno → Pagamento → Recompra**

Toda melhoria deve fortalecer esse fluxo.

---

## 4. Como eu quero que você trabalhe

Quero que você siga esta ordem:

### Etapa A — Diagnóstico técnico curto
Analise a estrutura atual do projeto e diga:

- quais arquivos atuais são mais relevantes para a Fase 1
- quais pontos fortes da base atual podem ser reaproveitados
- quais limitações precisam ser corrigidas
- quais refactors simples valem a pena antes de implementar

### Etapa B — Plano técnico da Fase 1
Explique de forma objetiva:

- quais arquivos serão alterados
- quais novos arquivos serão criados
- quais models/services/helpers precisam evoluir
- qual estratégia de implementação será usada

### Etapa C — Implementação da Fase 1
Implemente a Fase 1 no código.

### Etapa D — Resumo final
Ao terminar, mostre:

- o que foi implementado
- quais arquivos foram criados/editados
- decisões técnicas tomadas
- próximos passos recomendados

---

## 5. Regras de produto

- toda melhoria deve reduzir esforço manual do usuário
- toda tela principal deve mostrar algo acionável, não apenas informativo
- toda informação importante deve estar próxima da ação correspondente
- o app deve sempre responder à pergunta: **“o que eu preciso fazer agora?”**
- o fluxo deve exigir poucos toques
- priorizar utilidade real no dia a dia
- evitar complexidade desnecessária

---

## 6. Regras técnicas

- evitar lógica pesada diretamente em widgets/screens
- preferir services, helpers e estruturas reutilizáveis
- separar dados básicos de dados agregados/insights
- padronizar enums/status quando necessário
- manter compatibilidade com a arquitetura atual
- evitar duplicação de lógica entre telas
- fazer refactors pequenos quando melhorarem clareza e manutenção
- manter nomes claros e consistentes
- preservar o que já funciona

---

## 7. Fase 1 — Escopo exato

A Fase 1 deve focar em:

1. **Home mais acionável**
2. **Agenda mais inteligente**
3. **Cliente como mini-CRM**
4. **Base para fluxo mais útil do atendimento**

---

# 8. Implementações da Fase 1

## 8.1. HOME MAIS ACIONÁVEL

### Arquivos-alvo prováveis
- `lib/src/screens/home/home_screen.dart`
- `lib/src/widgets/home_dashboard.dart`
- `lib/src/services/app_services.dart`

### Se necessário, criar
- `lib/src/services/home_service.dart`
- `lib/src/models/home_summary.dart` ou equivalente

### Objetivo
Transformar a home em uma central de ação do dia.

### A home deve mostrar
- sessões de hoje
- próxima sessão
- pagamentos pendentes
- recebimentos do dia
- clientes sem retorno
- pacotes acabando
- ações rápidas

### Ações rápidas
- novo cliente
- nova sessão
- registrar pagamento
- abrir agenda
- abrir clientes em risco

### Requisitos técnicos
- cálculos e agregações fora da UI
- estado de loading
- estado vazio
- estado de erro
- baixo acoplamento com widget

### Critérios de aceite
- ao abrir o app, o usuário entende rapidamente o que precisa fazer
- a home fica mais acionável
- a home reduz navegação desnecessária

---

## 8.2. AGENDA MAIS INTELIGENTE

### Arquivos-alvo prováveis
- `lib/src/screens/agenda/agenda_screen.dart`
- `lib/src/models/session.dart`
- `lib/src/services/session_service.dart`

### Se necessário, criar
- helper para conflito de horários
- estrutura simples para recorrência
- enum padronizado de status de sessão

### Objetivo
Melhorar agendamento e gestão de horários.

### Melhorias
- visão semanal
- filtro por status
- remarcação rápida
- conflito de horário
- destaque visual para sessões do dia
- ações rápidas ao tocar na sessão:
  - editar
  - remarcar
  - confirmar
  - cancelar
  - iniciar atendimento

### Regras de negócio
- não permitir sobreposição sem alerta claro
- remarcação deve preservar dados principais
- suportar pelo menos recorrência simples preparada para expansão futura
- horários bloqueados podem ser planejados depois, mas a estrutura pode ficar preparada

### Critérios de aceite
- usuário consegue ver a semana com clareza
- usuário consegue remarcar com poucos toques
- conflitos são detectados corretamente

---

## 8.3. CLIENTE COMO MINI-CRM

### Arquivos-alvo prováveis
- `lib/src/models/client.dart`
- `lib/src/screens/clients/clients_screen.dart`
- `lib/src/screens/clients/client_detail_screen.dart`
- `lib/src/services/client_service.dart`
- `lib/src/services/profile_service.dart` (apenas se necessário em alguma relação de perfil)

### Se necessário, criar
- `lib/src/services/client_insights_service.dart`
- model/DTO de resumo do cliente

### Objetivo
Transformar a tela do cliente em uma visão útil de relacionamento.

### Adicionar no cliente
- objetivo
- data de início
- frequência ideal
- última sessão
- próxima sessão
- total de sessões
- total gasto
- faltas
- remarcações
- status do cliente
- tags
- próxima ação
- data sugerida de retorno

### Estrutura ideal da tela
- Resumo
- Sessões
- Financeiro
- Pacotes
- Observações

### Status sugeridos
- novo
- ativo
- pausado
- em risco
- inativo

### Tags sugeridas
- VIP
- retorno
- pacote
- inadimplente
- novo

### Regras de negócio
- status pode começar manual
- estrutura deve permitir automatização futura
- próxima ação deve aparecer em destaque

### Critérios de aceite
- usuário entende rapidamente a situação do cliente
- o perfil do cliente mostra contexto útil
- a tela deixa de ser apenas cadastro simples

---

## 8.4. PREPARAR MELHOR O FLUXO DE SESSÃO

### Arquivos-alvo prováveis
- `lib/src/screens/sessions/session_edit_screen.dart`
- `lib/src/screens/sessions/session_start_screen.dart`
- `lib/src/models/session.dart`
- `lib/src/services/session_service.dart`

### Objetivo
Melhorar a utilidade prática do fluxo de sessão sem tentar fazer tudo da Fase 2 ainda.

### Nesta Fase 1, eu quero ao menos preparar:
- estrutura mais clara de status
- base para observações úteis
- base para sessão ser rapidamente iniciada/continuada
- integração melhor entre agenda e sessão

### Importante
Se for melhor, você pode deixar recursos mais completos de evolução/rascunho/cópia de sessão anterior para a Fase 2, mas já organize o código para isso.

---

# 9. Refactors recomendados na Fase 1

Faça refactors pequenos e úteis, especialmente se ajudarem a sustentar as melhorias.

## Refactors desejados
- criar camada de agregações para home
- separar métricas agregadas de models básicos
- padronizar status de sessão
- centralizar lógica de conflito de horário
- evitar cálculo espalhado diretamente nas telas

## Services sugeridos
- `HomeService`
- `ClientInsightsService`

Se já houver estrutura equivalente, adapte em vez de duplicar.

---

# 10. Melhorias transversais de UX

Também quero ajustes gerais nestas telas principais:

- padronizar textos de botões
- melhorar estados vazios
- melhorar feedback visual
- reduzir excesso de toques
- destacar próxima ação
- melhorar hierarquia visual
- evitar telas “informativas demais e acionáveis de menos”

---

# 11. Ordem obrigatória de trabalho

Implemente nesta ordem:

### Passo 1
Analisar os arquivos atuais do projeto ligados à Fase 1

### Passo 2
Propor plano técnico curto

### Passo 3
Implementar:
- home mais acionável
- agenda mais inteligente
- cliente como mini-CRM
- ajustes estruturais no fluxo de sessão

### Passo 4
Entregar resumo do que mudou

---

# 12. Formato de resposta que eu quero

## A. Diagnóstico inicial
- arquivos relevantes
- pontos fortes
- limitações atuais
- riscos técnicos

## B. Plano técnico da Fase 1
- arquivos a alterar
- novos arquivos
- estratégia

## C. Implementação
- faça as mudanças no código

## D. Resumo final
- o que foi implementado
- arquivos alterados/criados
- próximos passos

---

# 13. Definição de sucesso da Fase 1

A Fase 1 estará boa se o usuário conseguir:

- entender o dia ao abrir o app
- ver rapidamente sessões e pendências
- agendar e remarcar com menos esforço
- perceber melhor a situação do cliente
- usar o app com menos navegação desnecessária

---

# 14. Instrução final

Comece agora analisando a base atual do projeto Theraflow e implemente a **Fase 1** com foco em:

- valor real para o usuário
- clareza de interface
- rapidez de fluxo
- arquitetura limpa
- baixo retrabalho futuro

Se precisar escolher entre “mais complexidade” e “mais utilidade”, escolha **mais utilidade**.