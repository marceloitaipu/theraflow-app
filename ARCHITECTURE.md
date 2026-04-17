# Arquitetura — TheraFlow

Aplicativo **single-tenant**, **offline-first**, com Firebase como nuvem.

---

## Visão Geral

```
┌─────────────────────────────────────────────┐
│              Flutter UI (telas)             │
├─────────────────────────────────────────────┤
│    Services V2 (lógica de negócio)          │
│    - AuthService                            │
│    - ClientService, SessionService          │
│    - PackageService, FinanceService         │
│    - ProfileService, BillingService         │
├──────────────┬──────────────────────────────┤
│              │                              │
│   SQLite     │   Firestore + Auth           │
│   (local)    │   (nuvem)                    │
│   schema v3  │   users/{uid}/{collection}   │
│              │                              │
└──────────────┴──────────────────────────────┘
         ▲              ▲
         └─ DataChangeBus ─┘ (broadcast reativo)
         └─ IncrementalSyncService ─┘
```

### Princípios

- **Single-tenant**: cada usuário autenticado tem seu próprio subespaço (`users/{uid}/...`). Não há conceito de “business” compartilhado.
- **Offline-first**: SQLite é fonte primária de leitura/escrita; sync sobe para Firestore quando online.
- **Reativo**: `DataChangeBus` emite eventos tipados; telas reagem via `StreamBuilder`.
- **Billing desacoplado**: `BillingService` abstrato com implementação `Disabled` por padrão (produção), `Mock` (dev) e `RevenueCat` (stub).

---

## Estrutura de Dados

### Firestore
```
users/{uid}                   // perfil + plano (User)
users/{uid}/clients/{id}      // Client
users/{uid}/sessions/{id}     // Session
users/{uid}/packages/{id}     // Package
users/{uid}/payments/{id}     // Payment
```

### SQLite (schema v3)
Tabelas espelham as coleções Firestore com campos canônicos:
- `clients`, `sessions`, `packages`, `payments`
- Campos de sync: `synced`, `lastModified`, `deleted`
- Nomes canônicos: `status`, `expirationDate`, `remainingSessions`, `price`

---

## Camadas Principais

### `lib/src/services/`
- **`auth_service.dart`** — Firebase Auth (email/senha, GitHub OAuth).
- **`client_service_v2.dart`**, **`session_service_v2.dart`**, **`package_service.dart`**, **`finance_service_v2.dart`** — CRUD offline-first com Firestore sync.
- **`profile_service.dart`** — leitura/escrita de `users/{uid}` (nome, plano, módulo, businessName).
- **`billing_service.dart`** — factory pluggable (`DisabledBillingService` é o default).
- **`data_change_bus.dart`** — broadcast `Stream<DataChangeEvent>` para invalidar UI.
- **`incremental_sync_service.dart`** — sync em background; usa `connectivity_plus` com fallback seguro.
- **`app_services.dart`** — barrel file; telas importam daqui e recebem V2 automaticamente.

### `lib/src/app_router.dart`
`go_router` 14.x com `SplashScreen` como gate: decide `/onboarding`, `/login` ou `/` com base em `AuthService.currentUser` + perfil em Firestore.

### `lib/src/models/`
Modelos imutáveis: `User`, `Client`, `Session`, `Package`, `Payment`, `AppModule`.

---

## Estado da Qualidade

| Métrica | Valor |
|---|---|
| `flutter analyze` | 7 infos (0 erros, 0 warnings) |
| `flutter test` | 94/94 passando |
| Telas migradas para V2 | 9/9 |

---

## Ações Externas (Operacionais)

Requerem ação humana — **não executadas pelo agente**:

1. **Rotacionar a API key do Firebase** (exposta em commit anterior).
2. **Publicar regras**: `firebase deploy --only firestore:rules`.
3. **Integrar billing real** (Google Play / App Store) via RevenueCat quando for publicar — vide [IN_APP_PURCHASE_SETUP.md](IN_APP_PURCHASE_SETUP.md).

---

## Documentos de Setup

- [QUICK_START.md](QUICK_START.md) — fluxo rápido de dev.
- [SETUP.md](SETUP.md) — instalação completa.
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) — projeto Firebase + Firestore.
- [GITHUB_OAUTH_SETUP.md](GITHUB_OAUTH_SETUP.md) — login GitHub.
- [IN_APP_PURCHASE_SETUP.md](IN_APP_PURCHASE_SETUP.md) — integração de assinatura.
- [CHANGELOG.md](CHANGELOG.md) — histórico de versões.
