# Implementation Tasks — Melhorias do App

## 1. Objetivo

Este documento detalha as tarefas de implementação para evoluir o app em termos de:

- utilidade no dia a dia
- facilidade de uso
- retenção
- clareza de fluxo
- valor percebido

O foco desta etapa não é billing.

---

## 2. Ordem de implementação

### Fase 1 — Melhorar os fluxos principais
- Home mais acionável
- Agenda semanal
- Conflito de horário
- Remarcação rápida
- Cliente com resumo mais rico

### Fase 2 — Tornar o app mais útil no acompanhamento
- Sessão com template
- Alertas básicos
- Próxima ação do cliente
- Listas de clientes sem retorno

### Fase 3 — Melhorar retenção e operação
- WhatsApp com mensagens prontas
- Pacotes mais visíveis
- Financeiro com filtros e ranking

### Fase 4 — Refinamento premium
- Status inteligente do cliente
- Metas
- Exportação

---

## 3. Tasks por módulo

# MÓDULO: HOME

## Objetivo
Transformar a home em central de ação do dia.

## Tasks de UI
- adicionar card “Sessões de hoje”
- adicionar card “Próxima sessão”
- adicionar card “Pagamentos pendentes”
- adicionar card “Recebimentos do dia”
- adicionar card “Clientes sem retorno”
- adicionar card “Pacotes acabando”
- adicionar área de ações rápidas
- reorganizar hierarquia visual para mostrar primeiro o que exige ação

## Tasks de lógica
- buscar sessões do dia
- buscar próxima sessão futura
- calcular total pendente
- calcular total recebido hoje
- identificar clientes sem retorno há X dias
- identificar pacotes com poucas sessões restantes
- identificar pacotes próximos do vencimento

## Tasks técnicas
- criar view model / controller da home
- centralizar agregações da home em service dedicado
- evitar lógica pesada diretamente na tela
- criar estados de loading, erro e vazio

## Critérios de aceite
- ao abrir o app, o usuário entende o que precisa fazer
- a home exibe pendências reais
- o usuário consegue navegar para ações principais com poucos toques

---

# MÓDULO: AGENDA

## Objetivo
Deixar agendamento e gestão de horários mais rápidos e menos manuais.

## Tasks de UI
- criar visão semanal
- manter visão diária/mensal se já existir
- adicionar filtro por status
- adicionar filtro por período
- adicionar ações rápidas ao tocar em sessão:
  - editar
  - remarcar
  - confirmar
  - cancelar
  - iniciar atendimento
- destacar visualmente sessões de hoje
- destacar conflitos

## Tasks de lógica
- validar conflito de horário ao criar/editar sessão
- implementar remarcação rápida
- implementar duplicação de sessão
- implementar recorrência
- implementar bloqueio de horários indisponíveis
- listar horários livres de acordo com janelas ocupadas

## Regras de negócio
- não permitir sessão sobreposta sem confirmação explícita
- remarcar deve preservar dados principais da sessão
- recorrência deve permitir frequência simples:
  - semanal
  - quinzenal
  - mensal
- horário bloqueado não pode aceitar sessão

## Tasks técnicas
- revisar model de sessão para suportar recorrência e bloqueio
- criar helper de comparação de intervalos
- criar função reutilizável para detectar conflito
- revisar queries por período
- revisar tratamento de timezone e bordas de horário

## Critérios de aceite
- usuário consegue ver semana com clareza
- usuário consegue remarcar rapidamente
- conflitos são detectados corretamente
- a agenda fica mais operacional

---

# MÓDULO: CLIENTES

## Objetivo
Transformar o cliente em mini-CRM.

## Tasks de UI
- adicionar card resumo no topo
- separar tela em abas:
  - Resumo
  - Sessões
  - Financeiro
  - Pacotes
  - Observações
- exibir status do cliente
- exibir tags
- exibir última sessão
- exibir próxima sessão
- exibir total gasto
- exibir faltas e remarcações

## Novos campos
- objetivo
- data de início
- frequência ideal
- status
- tags
- próxima ação
- data sugerida de retorno

## Tasks de lógica
- calcular última sessão
- calcular próxima sessão
- calcular total de sessões
- calcular total gasto
- calcular faltas
- calcular remarcações
- sugerir status com base em regras simples
- suportar atualização de próxima ação

## Regras de negócio
- cliente pode ter múltiplas tags
- status pode ser manual no início
- futuramente status poderá ser automático
- próxima ação deve ficar visível no resumo

## Tasks técnicas
- atualizar model de cliente
- criar migração local se necessário
- revisar serialização local/remota
- criar mapper para dados agregados do cliente
- desacoplar dados básicos do cliente de métricas agregadas

## Critérios de aceite
- perfil do cliente mostra contexto útil
- usuário entende rapidamente a situação do cliente
- a tela vai além de cadastro simples

---

# MÓDULO: SESSÕES

## Objetivo
Fazer a sessão virar a principal tela de trabalho.

## Tasks de UI
- criar layout de sessão mais prático
- adicionar template de evolução
- adicionar campo “como o cliente chegou hoje”
- adicionar campo “o que foi feito”
- adicionar campo “orientações”
- adicionar campo “próximos passos”
- adicionar campo “observações”
- adicionar checklist
- adicionar botão “copiar sessão anterior”
- adicionar opção “salvar rascunho”

## Tasks de lógica
- buscar última sessão do cliente
- copiar conteúdo da última sessão
- salvar sessão incompleta como rascunho
- finalizar sessão alterando status corretamente
- manter histórico cronológico

## Regras de negócio
- rascunho não deve contar como sessão finalizada
- sessão finalizada deve entrar nos indicadores
- copiar sessão anterior deve copiar apenas campos configurados
- status válidos:
  - agendada
  - confirmada
  - realizada
  - faltou
  - cancelada
  - remarcada

## Tasks técnicas
- revisar model de sessão
- separar “dados clínicos/anotações” de “dados operacionais”
- criar estrutura de template reutilizável
- preparar base para templates por tipo de atendimento

## Critérios de aceite
- usuário consegue registrar sessão rapidamente
- sessão fica útil para acompanhamento
- histórico fica mais rico

---

# MÓDULO: ALERTAS

## Objetivo
Reduzir dependência da memória do usuário.

## Tasks de UI
- criar seção de alertas na home
- criar lista de pendências
- criar marcadores visuais em clientes e pacotes
- criar empty states para quando não houver alertas

## Tipos de alerta
- sessão de amanhã
- cliente sem retorno há X dias
- cliente sem próxima sessão
- pagamento pendente
- pagamento atrasado
- pacote acabando
- pacote vencendo
- cliente com muitas faltas

## Tasks de lógica
- criar serviço de alertas
- criar regras configuráveis por dias
- calcular alertas localmente
- retornar alertas ordenados por prioridade

## Regras de negócio
- alertas devem ser explicáveis
- prioridade sugerida:
  - alta: atraso, pacote vencendo, cliente em risco
  - média: sem próxima sessão, sessão amanhã
  - baixa: acompanhamento geral

## Tasks técnicas
- criar `AlertItem` model
- criar `AlertService`
- evitar lógica espalhada em múltiplas telas
- preparar estrutura para futura notificação push/local

## Critérios de aceite
- usuário enxerga pendências importantes
- alertas ajudam a agir
- sistema não gera ruído excessivo

---

# MÓDULO: WHATSAPP / CONTATO

## Objetivo
Facilitar comunicação com o cliente.

## Tasks de UI
- adicionar botão de WhatsApp na tela do cliente
- adicionar botão de WhatsApp na sessão agendada
- criar menu de mensagens prontas

## Mensagens prontas
- confirmação de sessão
- lembrete de amanhã
- cobrança amigável
- retorno após ausência
- renovação de pacote
- reagendamento

## Tasks de lógica
- montar URL com telefone formatado
- montar texto da mensagem com variáveis
- preencher nome, data, horário e contexto

## Regras de negócio
- telefone deve ser sanitizado
- se não houver telefone válido, exibir aviso
- mensagens devem ser editáveis antes do envio

## Tasks técnicas
- criar helper de formatação de telefone
- criar helper de templates de mensagem
- centralizar mensagens em service/config

## Critérios de aceite
- usuário consegue iniciar contato em 1 toque
- mensagens fazem sentido no contexto
- recurso é rápido e útil

---

# MÓDULO: PACOTES

## Objetivo
Integrar pacotes ao fluxo diário.

## Tasks de UI
- exibir saldo de sessões no perfil do cliente
- exibir progresso visual do pacote
- exibir vencimento
- destacar pacote acabando
- permitir renovação rápida
- exibir histórico de pacotes

## Tasks de lógica
- calcular sessões restantes
- calcular percentual consumido
- detectar pacotes perto do fim
- detectar pacotes perto do vencimento
- associar consumo de sessão ao pacote correto

## Regras de negócio
- pacote pode ter status:
  - ativo
  - concluído
  - vencido
  - cancelado
- renovação deve poder reaproveitar dados do pacote anterior
- consumo de pacote deve ser transparente na sessão

## Tasks técnicas
- revisar model de pacote
- revisar relação entre pacote e sessão
- criar agregações reutilizáveis
- evitar cálculos duplicados em múltiplas telas

## Critérios de aceite
- saldo e vencimento ficam visíveis
- pacote deixa de ser isolado
- renovação fica simples

---

# MÓDULO: FINANCEIRO

## Objetivo
Tornar o financeiro mais útil para decisão.

## Tasks de UI
- adicionar filtros por período
- adicionar filtros por cliente
- adicionar filtros por status
- adicionar filtros por forma de pagamento
- criar cards:
  - recebido hoje
  - pendente
  - atrasado
  - ticket médio
- criar lista/ranking de clientes

## Tasks de lógica
- calcular total por período
- calcular pendências
- calcular atrasos
- calcular ticket médio
- calcular faturamento por cliente
- ordenar ranking de clientes

## Regras de negócio
- sessão faltada/cancelada não deve entrar como receita recebida
- receita pendente e recebida devem ser separadas claramente
- filtros devem ser cumulativos quando aplicável

## Tasks técnicas
- criar service de agregações financeiras
- revisar model de pagamento
- revisar vínculo entre pagamento, sessão e cliente
- manter consultas performáticas

## Critérios de aceite
- usuário consegue entender pendências
- usuário consegue ver origem da receita
- financeiro ajuda decisão, não só consulta

---

# MÓDULO: STATUS INTELIGENTE DO CLIENTE

## Objetivo
Dar leitura automática da base.

## Classificações
- novo
- ativo
- em risco
- inativo
- inadimplente
- pacote acabando

## Tasks de lógica
- definir regras objetivas para classificação
- rodar classificação automaticamente
- gerar listas úteis

## Regras iniciais sugeridas
- novo: cadastrado recentemente
- ativo: teve sessão recente e/ou possui próxima sessão
- em risco: sem retorno há X dias
- inativo: sem sessão há Y dias
- inadimplente: possui pagamento vencido
- pacote acabando: poucas sessões restantes

## Tasks técnicas
- criar classificador isolado
- não misturar regra de status com widget
- permitir ajuste futuro de regras

## Critérios de aceite
- listas fazem sentido
- classificação ajuda o usuário
- o app parece mais inteligente

---

# MÓDULO: METAS E DESEMPENHO

## Objetivo
Aumentar percepção de gestão do negócio.

## Tasks de UI
- criar card de meta mensal
- criar card de atendimentos do mês
- criar card de ocupação da agenda
- criar visão simples de desempenho semanal

## Tasks de lógica
- comparar realizado vs meta
- calcular ocupação
- calcular média semanal
- identificar melhor dia da semana
- identificar clientes mais frequentes

## Regras de negócio
- métricas devem ser simples
- não sobrecarregar a home
- priorizar clareza em vez de excesso de gráfico

## Critérios de aceite
- usuário entende facilmente os números
- recurso agrega sensação de gestão

---

# MÓDULO: EXPORTAÇÃO

## Objetivo
Permitir levar dados para fora do app.

## Tasks de UI
- criar tela ou menu de exportação
- permitir exportar:
  - clientes
  - sessões
  - financeiro
  - resumo mensal

## Tasks de lógica
- montar dataset exportável
- definir formato inicial simples
- filtrar por período quando aplicável

## Tasks técnicas
- começar por CSV ou formato simples
- preparar estrutura para PDF futuro
- garantir nomes de colunas claros

## Critérios de aceite
- exportação funciona com poucos toques
- arquivos fazem sentido para uso externo

---

## 4. Refactors recomendados

### Refactor 1
Criar camada de agregações para evitar cálculos em widgets.

### Refactor 2
Separar dados básicos de modelos de dados derivados/estatísticos.

### Refactor 3
Criar services específicos:
- HomeService
- AlertService
- ClientInsightsService
- FinanceInsightsService
- PackageInsightsService

### Refactor 4
Padronizar enums/status:
- status de sessão
- status de cliente
- status de pacote
- status de pagamento

### Refactor 5
Centralizar regras de negócio que hoje possam estar espalhadas em tela, widget e service.

---

## 5. Melhorias de UX transversais

## Tasks gerais
- padronizar textos de botões
- padronizar labels
- padronizar feedback visual
- melhorar estados vazios
- melhorar loaders
- confirmar exclusões importantes
- reduzir campos obrigatórios em formulários
- revisar excesso de toques
- destacar sempre a próxima ação

## Critérios de aceite
- fluxo mais limpo
- menos atrito
- mais clareza

---

## 6. Checklist final por fase

### Fase 1
- [ ] home mais acionável
- [ ] agenda semanal
- [ ] conflito de horário
- [ ] remarcação rápida
- [ ] cliente com resumo rico

### Fase 2
- [ ] sessão com template
- [ ] salvar rascunho
- [ ] copiar sessão anterior
- [ ] alertas básicos
- [ ] próxima ação do cliente

### Fase 3
- [ ] WhatsApp rápido
- [ ] mensagens prontas
- [ ] pacotes integrados
- [ ] financeiro com filtros
- [ ] ranking de clientes

### Fase 4
- [ ] status inteligente do cliente
- [ ] metas
- [ ] exportação

---

## 7. Definição de sucesso

A implementação desta etapa estará boa se o usuário conseguir:

- cadastrar cliente com facilidade
- agendar e remarcar sem esforço
- registrar sessão rapidamente
- visualizar pendências importantes
- acompanhar pacote e pagamento
- identificar clientes que precisam de retorno
- entender seu dia ao abrir o app

---

## 8. Instrução para implementação

Ao implementar, priorizar:

1. rapidez do fluxo
2. clareza visual
3. redução de esforço manual
4. regras simples e confiáveis
5. arquitetura reaproveitável