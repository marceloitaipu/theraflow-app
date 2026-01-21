# Arquitetura Implementada - TheraFlow

**Data**: 21/01/2026  
**Status**: Base da arquitetura híbrida implementada

---

## 📐 Arquitetura Atual

O TheraFlow implementa uma **arquitetura híbrida Firebase + SQLite** seguindo as recomendações para apps multi-tenant:

### ✅ Componentes Implementados

#### 1. **Firebase Auth**
- UID como identificador único do terapeuta
- Suporte a e-mail/senha e GitHub OAuth
- Gerenciamento de sessão automático

#### 2. **Firestore (Cloud)**
- Fonte de verdade na nuvem
- Estrutura multi-tenant: `/users/{userId}/clients`, `/users/{userId}/sessions`
- Regras de segurança prontas (necessitam publicação manual)
- Sincronização automática com cache local

#### 3. **SQLite + Drift (Local)**  
**Status**: Dependências instaladas, schema definido

**Tabelas criadas**:
- `clients` - Clientes do terapeuta
- `sessions` - Sessões de terapia
- `payments` - Registros de pagamento
- `packages` - Pacotes de sessões
- `sync_queue` - Fila de sincronização offline

**Campos de sincronização em cada tabela**:
- `synced` - Se o registro está sincronizado com Firestore
- `lastModified` - Timestamp da última modificação
- `deleted` - Soft delete para sincronizar exclusões

**Nota**: O gerador de código do Drift apresentou erros de compilação. Existem duas opções:
1. **Opção A (Recomendada)**: Usar `sqflite` diretamente (mais simples, amplamente testado)
2. **Opção B**: Depurar e corrigir os erros do Drift (requer ajustes no schema)

#### 4. **Connectivity Plus**
- Instalado para detectar status de conexão
- Pronto para implementar lógica offline-first

---

## 🔄 Estratégia de Sincronização

### Modelo Híbrido
1. **Operações locais primeiro** (quando implementado):
   - Gravações vão para SQLite
   - Adicionadas à fila de sincronização
   - UI responde imediatamente

2. **Sincronização em background**:
   - Quando online: fila processa pendências
   - Upload para Firestore
   - Marca registros como `synced`

3. **Firestore como verdade**:
   - Snapshots em tempo real atualizam cache local
   - Resolve conflitos (última gravação vence)

---

## 📦 Dependências Instaladas

```yaml
# Local Database
drift: ^2.30.1
drift_flutter: ^0.2.8
sqlite3_flutter_libs: ^0.5.41
path_provider: ^2.1.5
path: ^1.9.1

# Connectivity
connectivity_plus: ^6.1.5

# Code Generation
build_runner: ^2.10.5
drift_dev: ^2.30.1
```

---

## 🚧 Próximos Passos

### Curto Prazo (Crítico)
1. **Decidir abordagem de banco local**:
   - [ ] Opção A: Migrar para `sqflite` (mais estável)
   - [ ] Opção B: Corrigir erros do Drift

2. **Implementar sincronização básica**:
   - [ ] Criar `SyncService` para gerenciar fila
   - [ ] Detectar conexão com `connectivity_plus`
   - [ ] Processar operações pendentes

3. **Refatorar services**:
   - [ ] `ClientService` usa SQLite + Firestore
   - [ ] `SessionService` usa SQLite + Firestore
   - [ ] `FinanceService` usa SQLite + Firestore

### Médio Prazo (Importante)
4. **Operação offline completa**:
   - [ ] Queue persistente de operações
   - [ ] Retry com backoff exponencial
   - [ ] Indicador visual de sincronização

5. **Cloud Functions** (opcional):
   - [ ] Validar assinatura do usuário
   - [ ] Manter status de plano atualizado
   - [ ] Webhooks para pagamentos

6. **In-App Purchase** (opcional):
   - [ ] Integração com Google Play / App Store
   - [ ] Gerenciamento de assinaturas
   - [ ] Restauração de compras

---

## 💡 Recomendação Pragmática

### Para MVP Rápido:
**Usar apenas Firestore com cache nativo ativado** e adiar SQLite:

```dart
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true, // Cache local automático
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**Vantagens**:
- Zero configuração de sync manual
- Funciona offline automaticamente
- Menos código para manter
- Firestore já resolve conflitos

**Quando adicionar SQLite**:
- App precisa de queries complexas locais
- Relatórios offline detalhados
- Performance crítica em listas grandes
- Controle total sobre cache

---

## 🎯 Arquitetura Recomendada Final

```
┌─────────────────────────────────────┐
│         Flutter UI Layer            │
├─────────────────────────────────────┤
│                                     │
│    Services (Business Logic)       │
│   - ClientService                   │
│   - SessionService                  │
│   - FinanceService                  │
│                                     │
├──────────────┬──────────────────────┤
│              │                      │
│   Firebase   │    SQLite (Drift)   │ <- Opcional para MVP
│   (Cloud)    │    (Local Cache)     │
│              │                      │
│  - Auth      │    - Clients         │
│  - Firestore │    - Sessions        │
│              │    - Payments        │
│              │    - SyncQueue       │
│              │                      │
└──────────────┴──────────────────────┘
         ▲              ▲
         │              │
         └──SyncService─┘
```

---

## 📝 Decisão Necessária

**Você precisa escolher:**

**A)** 🚀 **MVP Rápido** - Usar só Firestore com cache nativo
   - Remove Drift do pubspec
   - Ativa persistence no Firestore
   - Implementa em 1-2 dias

**B)** 🎯 **Arquitetura Completa** - SQLite + Firestore
   - Corrige Drift ou migra para sqflite
   - Implementa SyncService
   - Implementa em 1-2 semanas

**Qual caminho você quer seguir?**
