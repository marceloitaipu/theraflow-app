# MASTER PROMPT — Theraflow App (Fase 2 focada em acompanhamento e retenção)

Quero que você atue como **product engineer sênior em Flutter**, com foco em **arquitetura, UX, produto e implementação incremental**.

Você vai continuar evoluindo o projeto Flutter existente **Theraflow**, respeitando a estrutura atual do código e tudo o que já foi implementado na Fase 1.

---

## 1. Contexto

A Fase 1 já deveria ter fortalecido:

- home mais acionável
- agenda mais inteligente
- cliente como mini-CRM
- base mais sólida para o fluxo de sessão

Agora quero avançar para a **Fase 2**, com foco em:

- acompanhamento mais útil
- retenção
- alertas acionáveis
- próxima ação do cliente
- evolução prática da sessão

---

## 2. Regra importante desta etapa

**Não implementar billing agora.**

Mesmo que existam arquivos relacionados a billing, paywall, subscription ou IAP, ignore-os nesta fase.

O foco agora é:

- retenção
- acompanhamento prático
- organização do relacionamento com o cliente
- tornar o app mais útil entre uma sessão e outra

---

## 3. Objetivo principal da Fase 2

Quero que o app ajude o usuário a:

1. registrar melhor o atendimento
2. acompanhar evolução do cliente com rapidez
3. lembrar retornos e pendências
4. agir antes de perder o cliente
5. reduzir dependência da memória

---

## 4. Como eu quero que você trabalhe

### Etapa A — Diagnóstico técnico curto
Analise a base atual após a Fase 1 e diga:

- quais arquivos são os mais relevantes para a Fase 2
- o que já pode ser reaproveitado
- quais gaps ainda existem
- quais refactors pequenos ajudam a sustentar a Fase 2

### Etapa B — Plano técnico da Fase 2
Explique objetivamente:

- arquivos que serão alterados
- novos arquivos que serão criados
- models/services/helpers necessários
- estratégia de implementação

### Etapa C — Implementação da Fase 2
Implemente a Fase 2 no código.

### Etapa D — Resumo final
Mostre:

- o que foi implementado
- arquivos criados/editados
- decisões técnicas
- próximos passos recomendados

---

## 5. Regras de produto

- toda melhoria deve reduzir esforço manual do usuário
- toda informação importante deve aparecer no momento certo
- o app deve ajudar o usuário a lembrar do que precisa fazer
- o app deve incentivar continuidade do atendimento
- priorizar utilidade prática antes de sofisticação
- evitar telas pesadas e excesso de campos

---

## 6. Regras técnicas

- evitar lógica pesada em widgets
- criar serviços e helpers reutilizáveis
- separar dados básicos de dados derivados
- preservar compatibilidade com a arquitetura atual
- manter baixo retrabalho futuro
- preparar base para expansões da Fase 3 e Fase 4

---

## 7. Escopo da Fase 2

A Fase 2 deve focar em:

1. **Sessão mais forte como ferramenta de trabalho**
2. **Alertas e follow-up**
3. **Próxima ação do cliente**
4. **Listas de clientes sem retorno e sem próxima sessão**

---

# 8. Implementações da Fase 2

## 8.1. SESSÃO COM TEMPLATE E EVOLUÇÃO MAIS PRÁTICA

### Arquivos-alvo prováveis
- `lib/src/screens/sessions/session_edit_screen.dart`
- `lib/src/screens/sessions/session_start_screen.dart`
- `lib/src/models/session.dart`
- `lib/src/services/session_service.dart`

### Se necessário, criar
- helper/model para template de sessão
- estrutura para rascunho
- helper para copiar dados da sessão anterior

### Objetivo
Transformar a sessão em uma ferramenta útil para registrar e acompanhar evolução.

### Implementar
- template de anotação
- campo “como o cliente chegou hoje”
- campo “o que foi feito”
- campo “orientações”
- campo “próximos passos”
- campo “observações”
- checklist simples
- copiar sessão anterior
- salvar rascunho

### Regras de negócio
- rascunho não conta como sessão concluída
- sessão concluída entra nos indicadores
- copiar sessão anterior deve copiar só os campos apropriados
- o preenchimento precisa ser rápido e claro

### Critérios de aceite
- usuário consegue registrar sessão rapidamente
- histórico de evolução fica mais útil
- sessão deixa de ser só um cadastro simples

---

## 8.2. ALERTAS E FOLLOW-UP

### Arquivos-alvo prováveis
- `lib/src/screens/home/home_screen.dart`
- `lib/src/widgets/home_dashboard.dart`
- `lib/src/services/home_service.dart` ou equivalente
- `lib/src/services/client_service.dart`
- `lib/src/services/session_service.dart`
- `lib/src/services/package_service.dart`
- `lib/src/services/finance_service.dart`

### Se necessário, criar
- `lib/src/models/alert_item.dart`
- `lib/src/services/alert_service.dart`

### Objetivo
Criar alertas que ajudem o usuário a agir sem depender da memória.

### Alertas desejados
- sessão de amanhã
- cliente sem retorno há X dias
- cliente sem próxima sessão
- pagamento pendente
- pagamento atrasado
- pacote acabando
- pacote vencendo
- cliente com muitas faltas

### Regras de negócio
- alertas devem ser claros e acionáveis
- devem ser priorizados
- não gerar ruído excessivo
- devem ter texto simples e útil

### Critérios de aceite
- usuário identifica pendências sem procurar
- alertas ajudam a agir
- alertas melhoram retenção e rotina

---

## 8.3. PRÓXIMA AÇÃO DO CLIENTE

### Arquivos-alvo prováveis
- `lib/src/models/client.dart`
- `lib/src/screens/clients/client_detail_screen.dart`
- `lib/src/services/client_service.dart`

### Objetivo
Dar ao usuário um jeito simples de registrar qual é o próximo passo com cada cliente.

### Adicionar ao cliente
- próxima ação
- data sugerida de retorno
- observação curta de acompanhamento

### Exemplos de próxima ação
- confirmar retorno na próxima semana
- cobrar pendência
- oferecer renovação de pacote
- remarcar sessão
- revisar evolução

### Regras de negócio
- próxima ação deve ficar visível na tela do cliente
- deve ser fácil editar
- deve servir como base para alertas e listas

### Critérios de aceite
- usuário consegue definir o próximo passo do cliente
- informação fica destacada
- recurso melhora acompanhamento

---

## 8.4. LISTAS DE CLIENTES SEM RETORNO E SEM PRÓXIMA SESSÃO

### Arquivos-alvo prováveis
- `lib/src/screens/clients/clients_screen.dart`
- `lib/src/services/client_service.dart`
- `lib/src/services/client_insights_service.dart` ou equivalente

### Objetivo
Ajudar o usuário a encontrar rapidamente clientes que exigem ação.

### Implementar
- lista de clientes sem retorno há X dias
- lista de clientes sem próxima sessão
- filtros ou seções específicas
- contagem simples desses grupos

### Regras de negócio
- listas precisam ser leves e claras
- filtros devem ser objetivos
- devem abrir o cliente em poucos toques

### Critérios de aceite
- usuário encontra facilmente clientes em risco
- a tela de clientes fica mais útil para retenção
- o app ajuda a agir sobre a base

---

# 9. Refactors recomendados na Fase 2

## Refactors desejados
- separar regras de alerta em serviço específico
- separar preenchimento de sessão de dados operacionais
- preparar base de rascunho
- evitar lógica de alerta espalhada pela UI

## Services sugeridos
- `AlertService`
- `SessionTemplateService` ou helper equivalente
- reforço do `ClientInsightsService`

---

# 10. Melhorias transversais de UX

Também quero ajustes gerais:

- campos de sessão mais claros
- hierarquia visual melhor
- textos de alerta simples
- empty states úteis
- menos atrito para editar próxima ação
- menos toques para chegar em clientes que exigem atenção

---

# 11. Ordem obrigatória de trabalho

### Passo 1
Analisar os arquivos atuais ligados à Fase 2

### Passo 2
Propor plano técnico curto

### Passo 3
Implementar:
- sessão com template
- salvar rascunho
- copiar sessão anterior
- alertas básicos
- próxima ação do cliente
- listas sem retorno / sem próxima sessão

### Passo 4
Entregar resumo final

---

# 12. Formato de resposta que eu quero

## A. Diagnóstico inicial
- arquivos relevantes
- pontos fortes
- limitações atuais
- riscos técnicos

## B. Plano técnico da Fase 2
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

# 13. Definição de sucesso da Fase 2

A Fase 2 estará boa se o usuário conseguir:

- registrar sessão de forma rápida e útil
- acompanhar evolução com menos esforço
- ver quem precisa de retorno
- ver quem está sem próxima sessão
- lembrar pendências importantes
- agir mais rápido sobre retenção

---

# 14. Instrução final

Comece analisando a base atual do Theraflow após a Fase 1 e implemente a **Fase 2** com foco em:

- acompanhamento prático
- retenção
- alertas úteis
- pouco atrito
- arquitetura limpa

Se precisar decidir entre “mais sofisticação” e “mais utilidade”, escolha **mais utilidade**.