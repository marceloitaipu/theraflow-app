# MASTER PROMPT — Theraflow App (Fase 4 focada em inteligência de base, metas e exportação)

Quero que você atue como **product engineer sênior em Flutter**, com foco em **arquitetura, UX, produto e implementação incremental**.

Você vai continuar evoluindo o projeto Flutter **Theraflow**, respeitando a estrutura atual do código e tudo o que já foi implementado nas fases anteriores.

---

## 1. Contexto

As fases anteriores já devem ter fortalecido:

- home
- agenda
- cliente como mini-CRM
- sessão
- alertas
- próxima ação
- listas de retenção
- WhatsApp rápido
- pacotes integrados
- financeiro mais operacional

Agora quero avançar para a **Fase 4**, com foco em:

- inteligência simples sobre a base de clientes
- metas e desempenho
- listas mais úteis
- exportação de dados
- percepção premium do produto

---

## 2. Regra importante desta etapa

**Não implementar billing agora.**

Billing continua fora do escopo.

---

## 3. Objetivo principal da Fase 4

Quero que o app ajude o usuário a:

1. entender melhor a situação da base de clientes
2. agir sobre clientes em risco
3. acompanhar metas simples do negócio
4. enxergar desempenho com clareza
5. exportar dados úteis quando necessário

---

## 4. Como eu quero que você trabalhe

### Etapa A — Diagnóstico técnico curto
Analise a base atual após a Fase 3 e diga:

- quais arquivos são os mais relevantes para a Fase 4
- o que já pode ser reaproveitado
- quais gaps ainda existem
- quais refactors pequenos valem a pena

### Etapa B — Plano técnico da Fase 4
Explique objetivamente:

- arquivos a alterar
- novos arquivos
- models/services/helpers necessários
- estratégia de implementação

### Etapa C — Implementação da Fase 4
Implemente a Fase 4 no código.

### Etapa D — Resumo final
Mostre:

- o que foi implementado
- arquivos criados/editados
- decisões técnicas
- próximos passos

---

## 5. Regras de produto

- inteligência deve ser simples e útil
- não complicar a experiência
- listas devem levar a ação
- metas devem ser fáceis de entender
- exportação deve ser prática
- priorizar clareza sobre sofisticação

---

## 6. Regras técnicas

- evitar lógica pesada em widgets
- criar serviços/classificadores reutilizáveis
- manter regras configuráveis quando possível
- preservar compatibilidade com arquitetura atual
- evitar espalhar regras de classificação pela UI

---

## 7. Escopo da Fase 4

A Fase 4 deve focar em:

1. **Status inteligente do cliente**
2. **Listas inteligentes**
3. **Metas e desempenho**
4. **Exportação simples**

---

# 8. Implementações da Fase 4

## 8.1. STATUS INTELIGENTE DO CLIENTE

### Arquivos-alvo prováveis
- `lib/src/models/client.dart`
- `lib/src/screens/clients/clients_screen.dart`
- `lib/src/screens/clients/client_detail_screen.dart`
- `lib/src/services/client_service.dart`
- `lib/src/services/client_insights_service.dart`
- `lib/src/services/alert_service.dart`

### Se necessário, criar
- classificador de status
- helper de regras
- enum padronizado de status do cliente

### Objetivo
Fazer o app interpretar a base de clientes de forma simples e útil.

### Classificações possíveis
- novo
- ativo
- em risco
- inativo
- inadimplente
- pacote acabando

### Regras iniciais sugeridas
- novo: cadastro recente
- ativo: teve sessão recente e/ou possui próxima sessão
- em risco: sem retorno há X dias
- inativo: sem sessão há Y dias
- inadimplente: possui pagamento vencido
- pacote acabando: poucas sessões restantes

### Critérios de aceite
- classificação faz sentido
- ajuda o usuário a agir
- melhora percepção de inteligência do app

---

## 8.2. LISTAS INTELIGENTES

### Arquivos-alvo prováveis
- `lib/src/screens/clients/clients_screen.dart`
- `lib/src/screens/home/home_screen.dart`
- `lib/src/services/client_insights_service.dart`
- `lib/src/services/alert_service.dart`

### Objetivo
Dar ao usuário listas claras sobre onde agir primeiro.

### Implementar
- clientes sem retorno
- clientes em risco
- clientes sem próxima sessão
- clientes com pendência
- clientes com pacote acabando

### Regras de negócio
- listas precisam ser objetivas
- precisam abrir a ação correspondente rapidamente
- não devem ser excessivamente complexas

### Critérios de aceite
- listas ajudam o usuário a decidir onde agir
- o fluxo é rápido
- a informação é clara

---

## 8.3. METAS E DESEMPENHO

### Arquivos-alvo prováveis
- `lib/src/screens/home/home_screen.dart`
- `lib/src/screens/finance/finance_screen.dart`
- `lib/src/services/finance_insights_service.dart`
- `lib/src/services/home_service.dart`

### Se necessário, criar
- DTO/model de métricas de desempenho
- estrutura simples de meta mensal

### Objetivo
Adicionar visão simples de gestão do negócio.

### Implementar
- meta mensal
- quantidade de atendimentos
- ocupação da agenda
- média semanal
- melhor dia da semana
- clientes mais frequentes

### Regras de negócio
- mostrar números simples
- evitar poluir a UI
- priorizar leitura rápida

### Critérios de aceite
- o usuário entende facilmente os indicadores
- recurso agrega percepção de gestão
- não deixa o app pesado

---

## 8.4. EXPORTAÇÃO SIMPLES

### Arquivos-alvo prováveis
- `lib/src/screens/profile/profile_screen.dart` ou outra área apropriada
- `lib/src/screens/finance/finance_screen.dart`
- `lib/src/services/client_service.dart`
- `lib/src/services/session_service.dart`
- `lib/src/services/finance_service.dart`

### Se necessário, criar
- service/export helper
- builders de CSV
- estrutura simples de compartilhamento/exportação

### Objetivo
Permitir que o usuário leve dados para fora do app com facilidade.

### Implementar
- exportar clientes
- exportar sessões
- exportar financeiro
- resumo mensal simples

### Regras de negócio
- começar por CSV ou formato simples
- nomes de coluna claros
- permitir filtro por período quando fizer sentido

### Critérios de aceite
- exportação funciona com poucos toques
- arquivos são úteis fora do app
- recurso aumenta profissionalismo percebido

---

# 9. Refactors recomendados na Fase 4

## Refactors desejados
- criar classificador de status isolado
- centralizar regras de classificação
- criar camada de métricas de desempenho
- evitar cálculo espalhado pela UI
- padronizar dados usados em listas inteligentes

## Services sugeridos
- `ClientStatusClassifier`
- `PerformanceMetricsService`
- `ExportService`

Se a arquitetura atual já tiver equivalentes, adapte em vez de duplicar.

---

# 10. Melhorias transversais de UX

Também quero ajustes gerais:

- tornar listas inteligentes fáceis de acessar
- destacar melhor clientes em risco
- apresentar metas com clareza
- deixar exportação em lugar previsível
- melhorar legibilidade dos indicadores

---

# 11. Ordem obrigatória de trabalho

### Passo 1
Analisar os arquivos atuais ligados à Fase 4

### Passo 2
Propor plano técnico curto

### Passo 3
Implementar:
- status inteligente do cliente
- listas inteligentes
- metas e desempenho
- exportação simples

### Passo 4
Entregar resumo final

---

# 12. Formato de resposta que eu quero

## A. Diagnóstico inicial
- arquivos relevantes
- pontos fortes
- limitações atuais
- riscos técnicos

## B. Plano técnico da Fase 4
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

# 13. Definição de sucesso da Fase 4

A Fase 4 estará boa se o usuário conseguir:

- entender melhor a situação da base de clientes
- identificar rapidamente clientes em risco
- acompanhar metas simples
- enxergar desempenho com clareza
- exportar dados úteis com facilidade

---

# 14. Instrução final

Comece analisando a base atual do Theraflow após a Fase 3 e implemente a **Fase 4** com foco em:

- inteligência simples
- clareza
- utilidade real
- percepção premium
- arquitetura limpa

Se precisar decidir entre “mais complexidade” e “mais clareza”, escolha **mais clareza**.