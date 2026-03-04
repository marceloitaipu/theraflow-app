# Cloud Functions para TheraFlow

## 📝 Descrição

Este diretório contém as Cloud Functions do Firebase para validação server-side de assinaturas e regras de negócio.

## 🔧 Funções Implementadas

### 1. `validateSubscription` (Callable)
Valida compras de assinatura do Google Play ou App Store.

**Parâmetros:**
- `platform`: 'android' ou 'ios'
- `purchaseToken`: Token de compra (Android) ou receipt (iOS)
- `productId`: ID do produto/SKU

**Retorno:**
- `success`: Boolean
- `planId`: 'free', 'professional' ou 'premium'
- `expiryDate`: Timestamp de expiração
- `subscriptionStatus`: 'active'

### 2. `checkClientLimit` (Firestore Trigger)
Verifica limites de clientes por plano ao criar novo cliente.

**Limites:**
- Free: 5 clientes
- Professional: 50 clientes
- Premium: Ilimitado

### 3. `checkExpiredSubscriptions` (Scheduled)
Executa diariamente à meia-noite para verificar assinaturas expiradas.

### 4. `onSubscriptionChange` (Firestore Trigger)
Registra histórico de mudanças de assinatura.

## 🚀 Deploy

### Pré-requisitos
```bash
npm install -g firebase-tools
firebase login
```

### Instalação de Dependências
```bash
cd functions
npm install
```

### Deploy para Produção
```bash
firebase deploy --only functions
```

### Deploy de Função Específica
```bash
firebase deploy --only functions:validateSubscription
```

### Testar Localmente
```bash
npm run serve
```

## 🔒 Segurança

⚠️ **IMPORTANTE:**
- Campos `subscriptionStatus`, `currentPeriodEnd` e `planId` só podem ser alterados por Cloud Functions
- Firestore Rules protegem contra alteração manual desses campos
- Validação de compra deve ser implementada com APIs oficiais:
  - Android: Google Play Developer API
  - iOS: App Store Server API

## 📦 Integração com Google Play Billing

Para validação real de compras Android, você precisa:

1. Habilitar Google Play Developer API no Google Cloud Console
2. Criar Service Account e baixar chave JSON
3. Adicionar chave ao Firebase Functions:
   ```bash
   firebase functions:secrets:set GOOGLE_APPLICATION_CREDENTIALS
   ```
4. Instalar biblioteca:
   ```bash
   npm install googleapis
   ```
5. Implementar validação em `validateGooglePlaySubscription()`

## 📦 Integração com App Store

Para validação real de compras iOS:

1. Obter Shared Secret do App Store Connect
2. Adicionar ao Firebase:
   ```bash
   firebase functions:secrets:set APP_STORE_SHARED_SECRET
   ```
3. Instalar biblioteca:
   ```bash
   npm install in-app-purchase
   ```
4. Implementar validação em `validateAppStoreSubscription()`

## 🔄 Fluxo de Validação

```
1. App compra assinatura via in_app_purchase
2. App chama validateSubscription() com token/receipt
3. Cloud Function valida com Google/Apple
4. Cloud Function atualiza Firestore (subscriptionStatus, planId, etc)
5. App recebe confirmação e libera funcionalidades
```

## 📊 Monitoramento

Ver logs das functions:
```bash
firebase functions:log
```

Ver logs específicos:
```bash
firebase functions:log --only validateSubscription
```

## 🧪 Testes

Testar localmente com emuladores:
```bash
firebase emulators:start --only functions,firestore
```

Chamar função localmente:
```javascript
const functions = require('firebase-functions-test')();
const myFunctions = require('./index');

// Testar validateSubscription
const wrapped = functions.wrap(myFunctions.validateSubscription);
const data = {
  platform: 'android',
  purchaseToken: 'test_token',
  productId: 'theraflow_professional_monthly'
};
const context = { auth: { uid: 'test_user_id' } };

wrapped(data, context).then(result => {
  console.log(result);
});
```

## 🛠️ Manutenção

### Atualizar Limites de Plano
Editar objeto `limits` em `checkClientLimit`:
```javascript
const limits = {
  free: 5,
  professional: 50,
  premium: Infinity
};
```

### Alterar Frequência de Verificação
Editar schedule em `checkExpiredSubscriptions`:
```javascript
.schedule('0 0 * * *') // Cron expression
```

## ⚠️ TODO

- [ ] Implementar validação real Google Play Billing
- [ ] Implementar validação real App Store
- [ ] Adicionar notificações push em `onSubscriptionChange`
- [ ] Adicionar envio de email de notificação
- [ ] Implementar webhook para renovações automáticas
- [ ] Adicionar testes unitários
- [ ] Implementar rate limiting
