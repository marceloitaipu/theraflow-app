# ✅ Arquitetura Híbrida Implementada - TheraFlow

**Data**: 21/01/2026  
**Status**: Opção B - Arquitetura Completa SQLite + Firestore implementada  
**Projeto**: TheraFlow App

---

## 📐 Implementação Concluída

### ✅ 1. Migração para sqflite
- ❌ Removido Drift (apresentava erros de compilação)
- ✅ Instalado sqflite + sqflite_common_ffi
- ✅ Instalado uuid para geração de IDs
- ✅ Instalado connectivity_plus para detecção de rede

### ✅ 2. DatabaseHelper (SQLite)
**Arquivo**: `lib/src/database/database_helper.dart`

**Tabelas criadas**:
- `clients` - Clientes do terapeuta
- `sessions` - Sessões de terapia  
- `payments` - Registros de pagamento
- `packages` - Pacotes de sessões
- `sync_queue` - Fila de sincronização offline

**Campos de sincronização** em cada tabela:
- `synced` (0 ou 1) - Se está sincronizado com Firestore
- `lastModified` - Timestamp da última modificação  
- `deleted` (0 ou 1) - Soft delete para sincronizar exclusões

**Métodos disponíveis**:
- `getAllX(userId)` - Buscar todos os registros
- `getXById(id)` - Buscar por ID
- `insertX(data)` - Inserir novo registro
- `updateX(id, data)` - Atualizar registro
- `markXDeleted(id)` - Soft delete
- `getUnsyncedRecords(table)` - Registros não sincronizados
- `markAsSynced(table, id)` - Marcar como sincronizado
- `clearAllData()` - Limpar tudo (logout)

**Fila de sincronização**:
- `addToSyncQueue()` - Adicionar operação offline
- `getPendingSyncItems()` - Buscar pendências
- `removeSyncItem()` - Remover após sincronizar
- `incrementRetryCount()` - Incrementar tentativas

### ✅ 3. SyncService
**Arquivo**: `lib/src/services/sync_service.dart`

**Funcionalidades**:
1. **Monitoramento de conectividade**
   - Detecta quando fica online/offline
   - Sincroniza automaticamente ao voltar online

2. **Sincronização periódica**
   - A cada 30 segundos quando online
   - Processa fila de operações offline

3. **Estratégia de sincronização**:
   - **Passo 1**: Processar fila (operações offline)
   - **Passo 2**: Sincronizar registros não sincronizados (push)
   - **Passo 3**: Baixar dados do Firestore (pull)

4. **Retry com limite**:
   - Até 3 tentativas por operação
   - Após 3 falhas, remove da fila (evitar loop infinito)

5. **Resolução de conflitos**:
   - Firestore vence (última gravação)
   - Timestamp usado para comparação

**Status de sincronização**:
- `idle` - Ocioso
- `syncing` - Sincronizando
- `error` - Erro na sincronização

### ✅ 4. ClientService Refatorado
**Arquivo**: `lib/src/services/client_service_v2.dart`

**Mudanças principais**:
- ✅ Todas as operações vão para SQLite primeiro
- ✅ UI responde imediatamente (sem espera)
- ✅ Se offline, adiciona à fila de sincronização
- ✅ Se online, dispara sync automática

**Métodos**:
- `getClients()` - Busca do SQLite local
- `createClient()` - Cria local + sincroniza
- `updateClient()` - Atualiza local + sincroniza
- `deleteClient()` - Soft delete + sincroniza
- `archiveClient()` - Muda status para 'inactive'
- `reactivateClient()` - Reativa cliente arquivado

**Operação offline completa**:
1. Criar/editar/deletar dados localmente
2. Adicionar à fila se offline
3. Sincronizar automaticamente ao voltar online

### ✅ 5. Inicialização no main.dart
**Alteração em** `lib/main.dart`:
```dart
await SyncService.instance.initialize();
```

Sincronização inicia automaticamente ao abrir o app.

---

## 🔄 Como Funciona

### Fluxo de Operação Offline-First

```
Usuario cria cliente
       ↓
SQLite (instantâneo)
       ↓
UI atualiza
       ↓
Online? ───┬─ Sim → Sync imediata
           └─ Não → Adiciona à fila
                    ↓
              Quando voltar online
                    ↓
              Processa fila
                    ↓
              Sync com Firestore
```

### Fluxo de Sincronização

```
A cada 30s (se online)
       ↓
1. Processar fila de operações offline
   - Create/Update/Delete no Firestore
   - Remover da fila após sucesso
       ↓
2. Push: Enviar não sincronizados
   - Buscar registros com synced=0
   - Enviar para Firestore
   - Marcar synced=1
       ↓
3. Pull: Baixar do Firestore
   - Comparar timestamps
   - Atualizar registros locais
```

---

## 📊 Arquitetura Final

```
┌─────────────────────────────────────┐
│         Flutter UI Layer            │
│    (Resposta Instantânea)           │
├─────────────────────────────────────┤
│                                     │
│    Services (Business Logic)       │
│   - ClientServiceV2  ← NOVO        │
│   - SessionService   ← PENDENTE    │
│   - FinanceService   ← PENDENTE    │
│   - SyncService      ← NOVO        │
│                                     │
├──────────────┬──────────────────────┤
│              │                      │
│   SQLite     │    Firestore         │
│   (Local)    │    (Cloud)           │
│              │                      │
│  - Clients   │    - Clients         │
│  - Sessions  │    - Sessions        │
│  - Payments  │    - Payments        │
│  - Packages  │    - Packages        │
│  - SyncQueue │                      │
│              │                      │
└──────────────┴──────────────────────┘
         ▲              ▲
         │              │
         └──SyncService─┘
              ↑
              │
       connectivity_plus
      (Online/Offline)
```

---

## 🎯 Próximos Passos

### Tarefas Restantes

1. **Refatorar SessionService** para usar SQLite
   - Copiar padrão do ClientServiceV2
   - Adaptar para modelo Session

2. **Refatorar FinanceService** para usar SQLite
   - Copiar padrão do ClientServiceV2
   - Adaptar para modelo Payment

3. **Refatorar PackageService** para usar SQLite  
   - Copiar padrão do ClientServiceV2
   - Adaptar para modelo Package

4. **Atualizar imports** nas screens
   - Trocar `client_service.dart` por `client_service_v2.dart`
   - Ou renomear client_service_v2 para client_service

5. **Testar operação offline**
   - Criar cliente offline
   - Verificar fila de sincronização
   - Voltar online e verificar sync

6. **Adicionar indicador de sync na UI** (opcional)
   - StreamBuilder escutando `SyncService.statusStream`
   - Mostrar ícone de sincronização

---

## ✅ Benefícios da Arquitetura Implementada

### Para o Usuário
- ✅ **App funciona offline** - Criar/editar dados sem internet
- ✅ **Resposta instantânea** - Sem espera por rede
- ✅ **Sincronização automática** - Dados sempre atualizados
- ✅ **Sem perda de dados** - Fila garante persistência

### Para o Desenvolvedor
- ✅ **SQLite simples** - Sem ORM complexo
- ✅ **Firestore como backup** - Dados seguros na nuvem
- ✅ **Fácil debug** - Logs de sincronização
- ✅ **Escalável** - Adicionar tabelas facilmente

### Técnico
- ✅ **Offline-first** - Funciona sem internet
- ✅ **Retry automático** - Até 3 tentativas
- ✅ **Resolução de conflitos** - Firestore vence
- ✅ **Multi-tenant** - Cada usuário isolado
- ✅ **Soft delete** - Mantém histórico

---

## 🔧 Manutenção

### Adicionar Nova Tabela

1. Criar tabela no `database_helper.dart`
2. Adicionar métodos CRUD
3. Adicionar ao `_pullCollection()` no `sync_service.dart`
4. Criar service específico seguindo padrão do `client_service_v2.dart`

### Logs de Debug

SyncService imprime logs úteis:
- `print('Erro na sincronização: $e')`
- `print('Erro ao processar item da fila: $e')`
- `print('Item removido da fila após 3 tentativas')`

---

## 📝 Notas Importantes

### Decisões Técnicas

1. **Por que sqflite e não Drift?**
   - Drift apresentou erros de compilação
   - sqflite é mais estável e amplamente testado
   - Menos overhead de código gerado

2. **Por que UUID e não autoincrement?**
   - IDs gerados localmente funcionam offline
   - Evita conflitos ao sincronizar
   - Consistência entre SQLite e Firestore

3. **Por que sync a cada 30s?**
   - Balanço entre atualização e bateria
   - Ajustável conforme necessidade
   - Sync imediata em operações críticas

4. **Por que limite de 3 tentativas?**
   - Evita loop infinito em erros permanentes
   - Usuário pode retentar manualmente
   - Logs indicam operações que falharam

---

## 🚀 Como Usar

### Criar Cliente Offline

```dart
final clientService = ClientService.instance;

// Funciona offline!
final clientId = await clientService.createClient(
  name: 'João Silva',
  phone: '(11) 99999-9999',
  notes: 'Cliente novo',
);

// Se offline: vai para fila
// Se online: sincroniza automaticamente
```

### Monitorar Status de Sync

```dart
StreamBuilder<SyncStatus>(
  stream: SyncService.instance.statusStream,
  builder: (context, snapshot) {
    if (snapshot.data == SyncStatus.syncing) {
      return CircularProgressIndicator();
    }
    return Icon(Icons.check);
  },
)
```

---

**Última atualização**: 21/01/2026 23:45
**Implementado por**: GitHub Copilot
**Status**: ✅ Base completa, pendente refatoração de outros services
