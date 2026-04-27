# MASTER PROMPT — Theraflow App (Fase 3 focada em operação, pacotes e financeiro)

Quero que você atue como **product engineer sênior em Flutter**, com foco em **arquitetura, UX, produto e implementação incremental**.

Você vai continuar evoluindo o projeto Flutter **Theraflow**, respeitando a estrutura atual do código e tudo o que já foi implementado nas fases anteriores.

---

## 1. Contexto

As fases anteriores já devem ter melhorado:

- home
- agenda
- cliente como mini-CRM
- sessão
- alertas
- próxima ação
- listas de retenção

Agora quero avançar para a **Fase 3**, com foco em:

- comunicação rápida com o cliente
- pacotes mais integrados
- financeiro mais operacional
- visão mais clara de pendências e receita

---

## 2. Regra importante desta etapa

**Não implementar billing agora.**

Mesmo que existam estruturas relacionadas a assinatura, cobrança ou paywall, ignore isso nesta fase.

O foco é operação e retenção prática.

---

## 3. Objetivo principal da Fase 3

Quero que o app ajude o usuário a:

1. contatar clientes rapidamente
2. acompanhar melhor pacotes e vencimentos
3. entender pendências financeiras
4. enxergar melhor de onde vem a receita
5. agir com menos atrito no dia a dia

---

## 4. Como eu quero que você trabalhe

### Etapa A — Diagnóstico técnico curto
Analise a base atual após a Fase 2 e diga:

- quais arquivos são mais relevantes para a Fase 3
- o que já pode ser reaproveitado
- quais gaps ainda existem
- quais refactors simples valem a pena

### Etapa B — Plano técnico da Fase 3
Explique objetivamente:

- arquivos que serão alterados
- novos arquivos que serão criados
- models/services/helpers necessários
- estratégia de implementação

### Etapa C — Implementação da Fase 3
Implemente a Fase 3 no código.

### Etapa D — Resumo final
Mostre:

- o que foi implementado
- arquivos criados/editados
- decisões técnicas
- próximos passos

---

## 5. Regras de produto

- toda melhoria deve reduzir atrito
- contato com cliente deve ser rápido
- dados financeiros devem ser claros
- pacotes devem ajudar recompra e continuidade
- priorizar utilidade real antes de refinamentos excessivos
- manter linguagem simples e fluxo objetivo

---

## 6. Regras técnicas

- evitar lógica pesada em widgets
- centralizar helpers e services
- padronizar dados e status quando necessário
- preservar compatibilidade com a arquitetura atual
- preparar terreno para a Fase 4

---

## 7. Escopo da Fase 3

A Fase 3 deve focar em:

1. **WhatsApp / contato rápido**
2. **Pacotes mais integrados**
3. **Financeiro mais operacional**
4. **Ranking e visão útil de receita**

---

# 8. Implementações da Fase 3

## 8.1. WHATSAPP / CONTATO RÁPIDO

### Arquivos-alvo prováveis
- `lib/src/screens/clients/client_detail_screen.dart`
- `lib/src/screens/agenda/agenda_screen.dart`
- `lib/src/screens/sessions/session_start_screen.dart` (se fizer sentido)
- `lib/src/models/client.dart`

### Se necessário, criar
- helper de telefone
- helper/service de templates de mensagem
- config/local de mensagens prontas

### Objetivo
Permitir contato rápido com o cliente com o mínimo de atrito.

### Implementar
- botão de WhatsApp no cliente
- botão de WhatsApp em contexto de sessão quando fizer sentido
- mensagens prontas para:
  - confirmação
  - lembrete de amanhã
  - cobrança amigável
  - retorno após ausência
  - renovação de pacote
  - reagendamento

### Regras de negócio
- sanitizar telefone
- avisar claramente se telefone não estiver válido
- mensagem deve ser editável antes do envio
- textos devem ser simples e úteis

### Critérios de aceite
- usuário consegue iniciar contato rapidamente
- mensagens fazem sentido no contexto
- fluxo é rápido e prático

---

## 8.2. PACOTES MAIS INTEGRADOS

### Arquivos-alvo prováveis
- `lib/src/models/package.dart`
- `lib/src/screens/clients/client_detail_screen.dart`
- `lib/src/screens/clients/package_create_screen.dart`
- `lib/src/services/package_service.dart`
- `lib/src/services/client_insights_service.dart` ou equivalente

### Se necessário, criar
- service de insights de pacote
- DTO/resumo de pacote
- helper para progresso e vencimento

### Objetivo
Fazer pacotes deixarem de ser recurso isolado e virarem parte clara do dia a dia.

### Implementar
- saldo de sessões visível
- progresso visual do pacote
- vencimento visível
- alerta de poucas sessões restantes
- alerta de vencimento próximo
- renovação rápida
- histórico de pacotes

### Regras de negócio
- pacote pode ter status:
  - ativo
  - concluído
  - vencido
  - cancelado
- consumo de pacote deve ficar claro nas sessões
- renovação pode reaproveitar dados do pacote anterior

### Critérios de aceite
- usuário vê saldo e vencimento facilmente
- pacote aparece integrado ao cliente
- renovação fica simples

---

## 8.3. FINANCEIRO MAIS OPERACIONAL

### Arquivos-alvo prováveis
- `lib/src/screens/finance/finance_screen.dart`
- `lib/src/models/payment.dart`
- `lib/src/services/finance_service.dart`

### Se necessário, criar
- `lib/src/services/finance_insights_service.dart`
- model/DTO de resumo financeiro

### Objetivo
Transformar o financeiro em ferramenta de decisão, não apenas consulta.

### Implementar
- filtro por período
- filtro por cliente
- filtro por status
- filtro por forma de pagamento
- cards:
  - recebido hoje
  - pendente
  - atrasado
  - ticket médio
- faturamento por cliente
- ranking de clientes

### Regras de negócio
- cancelado/faltou não entra como receita recebida
- pendente e recebido devem ser separados claramente
- filtros devem funcionar juntos quando aplicável

### Critérios de aceite
- usuário entende pendências rapidamente
- usuário enxerga melhor a origem da receita
- o financeiro ajuda decisão prática

---

## 8.4. RANKING E VISÃO MAIS ÚTIL DA RECEITA

### Arquivos-alvo prováveis
- `lib/src/screens/finance/finance_screen.dart`
- `lib/src/services/finance_service.dart`
- `lib/src/services/finance_insights_service.dart`

### Objetivo
Dar visão simples de desempenho financeiro por cliente.

### Implementar
- ranking de clientes por faturamento
- ticket médio
- valor total por período
- visão resumida por cliente
- destaque para pendências

### Critérios de aceite
- informação é clara
- não polui a tela
- ajuda a priorizar ações do usuário

---

# 9. Refactors recomendados na Fase 3

## Refactors desejados
- centralizar templates de mensagem
- criar camada de insights financeiros
- criar camada de insights de pacote
- evitar cálculos financeiros espalhados na UI
- padronizar status relacionados a pacote e pagamento

## Services sugeridos
- `FinanceInsightsService`
- `PackageInsightsService`
- `MessageTemplateService` ou helper equivalente

---

# 10. Melhorias transversais de UX

Também quero ajustes gerais:

- feedback claro em filtros
- cards financeiros simples
- menos atrito na renovação de pacote
- CTAs melhores em cliente e financeiro
- uso consistente de ícones, botões e labels

---

# 11. Ordem obrigatória de trabalho

### Passo 1
Analisar os arquivos atuais ligados à Fase 3

### Passo 2
Propor plano técnico curto

### Passo 3
Implementar:
- WhatsApp rápido
- mensagens prontas
- pacotes integrados
- financeiro com filtros
- ranking de clientes
- ticket médio

### Passo 4
Entregar resumo final

---

# 12. Formato de resposta que eu quero

## A. Diagnóstico inicial
- arquivos relevantes
- pontos fortes
- limitações atuais
- riscos técnicos

## B. Plano técnico da Fase 3
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

# 13. Definição de sucesso da Fase 3

A Fase 3 estará boa se o usuário conseguir:

- contatar clientes com rapidez
- acompanhar saldo e vencimento de pacotes
- entender o que está pendente
- visualizar melhor a receita
- usar o financeiro para decidir, e não só consultar

---

# 14. Instrução final

Comece analisando a base atual do Theraflow após a Fase 2 e implemente a **Fase 3** com foco em:

- rapidez
- clareza
- retenção
- operação prática
- arquitetura limpa

Se precisar decidir entre “mais detalhe visual” e “mais utilidade real”, escolha **mais utilidade real**.