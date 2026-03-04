# ⚡ Guia Rápido - TheraFlow Profissionalizado

## 🚀 Quick Start

### Deploy Imediato (5 comandos)

```bash
# 1. Deploy Firestore Rules
firebase deploy --only firestore:rules

# 2. Instalar dependências Cloud Functions
cd functions && npm install && cd ..

# 3. Deploy Cloud Functions
firebase deploy --only functions

# 4. Testar app
flutter run

# 5. Verificar no Firebase Console
open https://console.firebase.google.com
```

---

## 📁 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `firestore.rules` | Rules profissionais ✅ |
| `functions/index.js` | Cloud Functions ✅ |
| `lib/src/services/incremental_sync_service.dart` | Sync profissional ✅ |
| `lib/src/services/subscription_service.dart` | Gestão assinaturas ✅ |
| `.gitignore` | Atualizado ✅ |

---

## 📚 Documentação

| Guia | Link | Tempo |
|------|------|-------|
| **Relatório Completo** | [PROFISSIONALIZACAO_COMPLETA.md](PROFISSIONALIZACAO_COMPLETA.md) | 15 min |
| **In-App Purchase** | [IN_APP_PURCHASE_SETUP.md](IN_APP_PURCHASE_SETUP.md) | 30 min |
| **Limpeza de Código** | [LIMPEZA_PROJETO.md](LIMPEZA_PROJETO.md) | 10 min |
| **Cloud Functions** | [functions/README.md](functions/README.md) | 10 min |
| **Resumo Executivo** | [README_PROFISSIONALIZACAO.md](README_PROFISSIONALIZACAO.md) | 5 min |

---

## ✅ O que foi Feito

### 1. Firestore Rules
- ✅ Separação de permissões (read/create/update/delete)
- ✅ Proteção de campos críticos (subscriptionStatus, planId)
- ✅ Removido .size() (não funciona)
- ✅ Validação de userId

### 2. Sincronização
- ✅ Pull incremental (where updatedAt > lastSync)
- ✅ Campos updatedAt/deletedAt em todos modelos
- ✅ Tabela sync_metadata no SQLite
- ✅ Resolução de conflitos (last-write-wins)
- ✅ Trigger por conectividade (removido periodic)

### 3. Assinatura
- ✅ Cloud Functions (validateSubscription, checkClientLimit, etc)
- ✅ SubscriptionService no app
- ✅ Validação server-side obrigatória
- ✅ Cron job para expiração

### 4. Logging
- ✅ AppLogger estruturado
- ✅ Níveis (info, warning, error, debug)
- ✅ Contexto e stack traces

### 5. Limpeza
- ✅ .gitignore atualizado
- ✅ Documentação de limpeza
- ✅ Script clean_for_dist.sh

---

## ⚠️ Pendente

### Antes de Vender

1. **In-App Purchase** (2-4h)
   - Adicionar `in_app_purchase` ao pubspec.yaml
   - Configurar Google Play Console
   - Configurar App Store Connect
   - Implementar InAppPurchaseService
   - Ver: [IN_APP_PURCHASE_SETUP.md](IN_APP_PURCHASE_SETUP.md)

2. **Consolidar Código** (1h)
   - Remover `*_service.dart` duplicados
   - Manter apenas `*_service_v2.dart`
   - Atualizar imports
   - Ver: [LIMPEZA_PROJETO.md](LIMPEZA_PROJETO.md)

3. **Testes Finais** (2h)
   - Sync online/offline
   - Limites de planos
   - Compra/validação
   - Build produção

---

## 🔥 Comandos Úteis

### Firebase

```bash
# Ver logs
firebase functions:log

# Ver logs específicos
firebase functions:log --only validateSubscription

# Ver erros
firebase functions:log --only validateSubscription --severity ERROR

# Testar localmente
firebase emulators:start --only functions,firestore
```

### Flutter

```bash
# Limpar build
flutter clean && flutter pub get

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Rodar testes
flutter test

# Analisar código
flutter analyze
```

### Git

```bash
# Limpar arquivos ignorados
git clean -fdx

# Ver status
git status

# Commit profissionalização
git add .
git commit -m "feat: profissionalização completa - sync incremental, cloud functions, rules seguras"
```

---

## 🐛 Troubleshooting

### Functions não fazem deploy

```bash
cd functions
npm install
firebase deploy --only functions --debug
```

### Rules não aplicam

```bash
firebase deploy --only firestore:rules --debug
```

### Sync não funciona

1. Verificar `IncrementalSyncService.instance.initialize()` no main.dart
2. Ver logs: `AppLogger.info/error`
3. Verificar conectividade
4. Verificar Firestore Rules

### Assinatura não valida

1. Ver logs: `firebase functions:log --only validateSubscription`
2. Verificar purchaseToken
3. Verificar Service Account (Android)
4. Verificar Shared Secret (iOS)

---

## 📊 Limites por Plano

| Plano | Clientes | Sessões | Relatórios | Preço |
|-------|----------|---------|------------|-------|
| **Free** | 5 | Básico | Não | R$ 0 |
| **Professional** | 50 | Ilimitado | Básico | R$ 29,90/mês |
| **Premium** | ∞ | Ilimitado | Avançado | R$ 49,90/mês |

---

## 📞 Links Úteis

- [Firebase Console](https://console.firebase.google.com)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Flutter Pub](https://pub.dev)

---

## 🎯 Checklist de Venda

```
PRÉ-VENDA
[ ] Deploy Cloud Functions
[ ] Deploy Firestore Rules
[ ] Implementar In-App Purchase
[ ] Configurar Google Play Billing
[ ] Configurar App Store
[ ] Consolidar código
[ ] Remover mocks
[ ] Limpeza geral
[ ] Testar fluxo completo
[ ] Build produção

ENTREGA
[ ] Código fonte (ZIP/Git)
[ ] Documentação
[ ] Credenciais Firebase
[ ] Builds (APK/IPA)
[ ] Acessos (Play/AppStore)
[ ] Demo/Apresentação
```

---

## 💡 Dicas

1. **Sempre validar no servidor** - Nunca confiar apenas no cliente
2. **Usar logging estruturado** - AppLogger em vez de print()
3. **Sync incremental** - Economiza reads e melhora performance
4. **Soft delete** - Usar deletedAt em vez de deletar fisicamente
5. **Testar com sandbox** - Google Play e App Store têm ambientes de teste

---

## 🚀 Próxima Evolução

Após venda, considerar:

- [ ] Migrar para Drift (em vez de sqflite)
- [ ] Adicionar testes automatizados
- [ ] Integrar Firebase Crashlytics
- [ ] Adicionar notificações push
- [ ] Implementar analytics
- [ ] Criar dashboard web (admin)
- [ ] Adicionar webhooks para renovações

---

**TheraFlow - Profissional. Escalável. Seguro.** ✨

**Última atualização**: 21/01/2026
