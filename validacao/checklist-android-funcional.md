# Checklist de Validacao Android

## Objetivo

Usar a web para validar fluxo e regra de negocio e usar esta checklist para confirmar o comportamento real no Android, principalmente onde existe persistencia local, plugins nativos e sincronizacao.

## 1. Acesso e conta

- [ ] Abrir o app Android pela primeira vez sem erro de inicializacao
- [ ] Criar conta com email e senha
- [ ] Fazer login com email e senha
- [ ] Fazer login com GitHub, se esse fluxo for obrigatorio
- [ ] Fazer logout e voltar para a tela de login
- [ ] Fechar e reabrir o app mantendo a sessao autenticada

## 2. Onboarding e perfil

- [ ] Concluir onboarding completo
- [ ] Salvar nome, telefone e cidade
- [ ] Salvar duracao padrao e valor padrao
- [ ] Criar primeiro cliente a partir do onboarding
- [ ] Abrir Perfil e confirmar dados persistidos
- [ ] Alternar tema claro/escuro e validar persistencia ao reabrir o app

## 3. Clientes

- [ ] Criar cliente manualmente
- [ ] Editar cliente existente
- [ ] Excluir cliente
- [ ] Buscar cliente pelo nome
- [ ] Buscar cliente pelo telefone
- [ ] Abrir detalhes do cliente sem erro

## 4. Sessoes e agenda

- [ ] Criar sessao pela Home
- [ ] Criar sessao a partir do detalhe do cliente
- [ ] Confirmar pre-selecao do cliente na criacao da sessao
- [ ] Editar data, hora, tipo e valor da sessao
- [ ] Excluir sessao
- [ ] Ver sessao no dia correto da Agenda
- [ ] Finalizar sessao pela tela de inicio da sessao
- [ ] Alterar status para realizada, faltou e remarcado
- [ ] Alterar status de pagamento para pago e pendente

## 5. Financeiro

- [ ] Ver resumo do mes na Home
- [ ] Ver totais recebidos e pendentes na tela Financeiro
- [ ] Confirmar que sessoes pagas entram como recebidas
- [ ] Confirmar que sessoes pendentes entram como pendentes
- [ ] Validar lista de sessoes pendentes

## 6. Pacotes

- [ ] Criar pacote para um cliente elegivel
- [ ] Visualizar pacote no detalhe do cliente
- [ ] Vincular sessao a pacote
- [ ] Finalizar sessao vinculada e decrementar pacote
- [ ] Validar aviso quando restarem 2 sessoes ou menos
- [ ] Validar comportamento quando o pacote acabar

## 7. Persistencia local e reinicio

- [ ] Criar clientes e sessoes, fechar o app e confirmar que continuam salvos
- [ ] Reiniciar o celular ou emulador e confirmar que os dados continuam visiveis
- [ ] Editar dados apos reinicio e confirmar persistencia

## 8. Offline e sincronizacao

- [ ] Abrir o app com internet ligada e carregar dados
- [ ] Desligar internet e criar cliente
- [ ] Desligar internet e criar sessao
- [ ] Desligar internet e editar cliente
- [ ] Desligar internet e editar sessao
- [ ] Religar internet e confirmar sincronizacao
- [ ] Confirmar que nao houve duplicacao de registros
- [ ] Confirmar que alteracoes offline chegaram ao Firestore

## 9. Integracao Firebase

- [ ] Verificar se usuarios sao criados em users/{uid}
- [ ] Verificar se clients sao sincronizados corretamente
- [ ] Verificar se sessions sao sincronizadas corretamente
- [ ] Verificar se payments sao sincronizados corretamente
- [ ] Verificar se packages sao sincronizados corretamente

## 10. Estabilidade geral

- [ ] Navegar entre Home, Agenda, Clientes, Financeiro e Perfil sem travamentos
- [ ] Validar FABs e botoes principais
- [ ] Confirmar que nao ha mensagens de erro inesperadas
- [ ] Confirmar que nao ha regressao visual importante em Android

## Observacoes para registrar

- Modelo do aparelho:
- Versao do Android:
- Problemas encontrados:
- Passos para reproduzir:
- Resultado esperado:
- Resultado obtido:
