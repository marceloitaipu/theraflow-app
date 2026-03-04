# 💳 Guia de Implementação In-App Purchase

## 📋 Visão Geral

Este guia detalha como integrar compras dentro do app (In-App Purchase) para Android e iOS no TheraFlow.

---

## 📦 1. Instalação

### Adicionar Dependência

```yaml
# pubspec.yaml
dependencies:
  in_app_purchase: ^3.1.11
  in_app_purchase_android: ^0.3.0
  in_app_purchase_storekit: ^0.3.6
```

```bash
flutter pub get
```

---

## 🤖 2. Configuração Android (Google Play)

### 2.1. Configurar Google Play Console

1. Acesse [Google Play Console](https://play.google.com/console)
2. Selecione seu app
3. Vá em **Monetização → Produtos → Assinaturas**
4. Crie as assinaturas:

| ID do Produto | Nome | Preço | Período |
|---------------|------|-------|---------|
| `theraflow_professional_monthly` | Professional (Mensal) | R$ 29,90 | 1 mês |
| `theraflow_professional_yearly` | Professional (Anual) | R$ 299,00 | 1 ano |
| `theraflow_premium_monthly` | Premium (Mensal) | R$ 49,90 | 1 mês |
| `theraflow_premium_yearly` | Premium (Anual) | R$ 499,00 | 1 ano |

5. Salve e ative os produtos

### 2.2. Configurar Permissões

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <uses-permission android:name="com.android.vending.BILLING" />
</manifest>
```

### 2.3. Habilitar Google Play Developer API

1. Acesse [Google Cloud Console](https://console.cloud.google.com)
2. Selecione projeto Firebase
3. Vá em **APIs & Services → Library**
4. Busque "Google Play Developer API"
5. Clique em **Enable**

### 2.4. Criar Service Account

1. No Google Cloud Console: **IAM & Admin → Service Accounts**
2. Clique **Create Service Account**
3. Nome: `theraflow-billing-validator`
4. Role: **Service Account User**
5. Clique **Create Key** → JSON
6. Salve o arquivo `service-account-key.json`

### 2.5. Vincular Service Account ao Google Play

1. Google Play Console → **Configurações → Acesso à API**
2. Clique **Criar nova conta de serviço**
3. Siga instruções para vincular
4. Dê permissão de **Visualizar dados financeiros**

---

## 🍎 3. Configuração iOS (App Store)

### 3.1. Configurar App Store Connect

1. Acesse [App Store Connect](https://appstoreconnect.apple.com)
2. Selecione seu app
3. Vá em **In-App Purchases**
4. Crie assinaturas auto-renováveis:

| ID do Produto | Nome | Preço | Duração |
|---------------|------|-------|---------|
| `theraflow_professional_monthly` | Professional Mensal | R$ 29,90 | 1 mês |
| `theraflow_professional_yearly` | Professional Anual | R$ 299,00 | 1 ano |
| `theraflow_premium_monthly` | Premium Mensal | R$ 49,90 | 1 mês |
| `theraflow_premium_yearly` | Premium Anual | R$ 499,00 | 1 ano |

5. Crie grupo de assinaturas (Subscription Group)
6. Configure preços e descrições

### 3.2. Obter Shared Secret

1. App Store Connect → App → **In-App Purchases**
2. Vá em **App-Specific Shared Secret**
3. Clique **Generate**
4. Copie o código (ex: `1234567890abcdef1234567890abcdef`)

### 3.3. Configurar StoreKit (Testes)

```xml
<!-- ios/Runner/StoreKitConfiguration.storekit -->
{
  "identifier" : "1234567890",
  "nonRenewingSubscriptions" : [],
  "products" : [],
  "settings" : {
    "_failTransactionsEnabled" : false,
    "_locale" : "pt_BR",
    "_storefront" : "BRA",
    "_storeKitErrors" : []
  },
  "subscriptionGroups" : [
    {
      "id" : "theraflow_subscriptions",
      "localizations" : [],
      "name" : "TheraFlow Subscriptions",
      "subscriptions" : [
        {
          "adHocOffers" : [],
          "codeOffers" : [],
          "displayPrice" : "29.90",
          "familyShareable" : false,
          "groupNumber" : 1,
          "internalID" : "1",
          "introductoryOffer" : null,
          "localizations" : [
            {
              "description" : "Plano Professional",
              "displayName" : "Professional Mensal",
              "locale" : "pt_BR"
            }
          ],
          "productID" : "theraflow_professional_monthly",
          "recurringSubscriptionPeriod" : "P1M",
          "referenceName" : "Professional Monthly",
          "subscriptionGroupID" : "theraflow_subscriptions",
          "type" : "RecurringSubscription"
        }
      ]
    }
  ],
  "version" : {
    "major" : 1,
    "minor" : 0
  }
}
```

---

## 💻 4. Implementação no Flutter

### 4.1. Criar InAppPurchaseService

```dart
// lib/src/services/in_app_purchase_service.dart
import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'subscription_service.dart';
import 'incremental_sync_service.dart';

class InAppPurchaseService {
  InAppPurchaseService._();
  static final instance = InAppPurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionService _subscription = SubscriptionService.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // IDs dos produtos
  static const Set<String> _kProductIds = {
    'theraflow_professional_monthly',
    'theraflow_professional_yearly',
    'theraflow_premium_monthly',
    'theraflow_premium_yearly',
  };

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  /// Inicializar serviço de compras
  Future<void> initialize() async {
    AppLogger.info('Inicializando In-App Purchase', 'InAppPurchaseService');

    // Verificar disponibilidade
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      AppLogger.warning('In-App Purchase não disponível', 'InAppPurchaseService');
      return;
    }

    // Configuração específica para Android
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      await androidAddition.enablePendingPurchases();
    }

    // Escutar stream de compras
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        AppLogger.error('Erro no stream de compras', error, null, 'InAppPurchaseService');
      },
    );

    // Carregar produtos
    await loadProducts();

    // Restaurar compras pendentes
    await _iap.restorePurchases();

    AppLogger.info('In-App Purchase inicializado', 'InAppPurchaseService');
  }

  /// Carregar produtos disponíveis
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    try {
      final ProductDetailsResponse response = 
          await _iap.queryProductDetails(_kProductIds);

      if (response.error != null) {
        AppLogger.error('Erro ao carregar produtos', response.error, null, 'InAppPurchaseService');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.warning('Produtos não encontrados: ${response.notFoundIDs}', 'InAppPurchaseService');
      }

      _products = response.productDetails;
      AppLogger.info('${_products.length} produtos carregados', 'InAppPurchaseService');

    } catch (e, stack) {
      AppLogger.error('Erro ao carregar produtos', e, stack, 'InAppPurchaseService');
    }
  }

  /// Comprar produto
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      AppLogger.warning('In-App Purchase não disponível', 'InAppPurchaseService');
      return false;
    }

    try {
      AppLogger.info('Iniciando compra: ${product.id}', 'InAppPurchaseService');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      bool success;
      
      if (product.id.contains('monthly') || product.id.contains('yearly')) {
        // Assinatura
        success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Produto consumível (se houver no futuro)
        success = await _iap.buyConsumable(purchaseParam: purchaseParam);
      }

      return success;

    } catch (e, stack) {
      AppLogger.error('Erro ao comprar produto', e, stack, 'InAppPurchaseService');
      return false;
    }
  }

  /// Restaurar compras
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      AppLogger.info('Restaurando compras', 'InAppPurchaseService');
      await _iap.restorePurchases();
    } catch (e, stack) {
      AppLogger.error('Erro ao restaurar compras', e, stack, 'InAppPurchaseService');
    }
  }

  /// Callback de atualização de compras
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      AppLogger.info(
        'Compra atualizada: ${purchaseDetails.productID} - ${purchaseDetails.status}',
        'InAppPurchaseService'
      );

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Compra pendente (aguardando confirmação)
        AppLogger.info('Compra pendente', 'InAppPurchaseService');
        
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Erro na compra
        AppLogger.error(
          'Erro na compra',
          purchaseDetails.error,
          null,
          'InAppPurchaseService'
        );
        
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        
        // Compra bem-sucedida - validar com servidor
        final bool valid = await _verifyPurchase(purchaseDetails);
        
        if (valid) {
          AppLogger.info('Compra verificada com sucesso', 'InAppPurchaseService');
        } else {
          AppLogger.error('Falha na verificação da compra', null, null, 'InAppPurchaseService');
        }
      }

      // Completar transação
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
        AppLogger.info('Transação completada', 'InAppPurchaseService');
      }
    }
  }

  /// Verificar compra com Cloud Function
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final purchaseToken = purchaseDetails.verificationData.serverVerificationData;
      final productId = purchaseDetails.productID;

      // Chamar Cloud Function para validar
      final success = await _subscription.validatePurchase(
        platform: platform,
        purchaseToken: purchaseToken,
        productId: productId,
      );

      if (success) {
        // Recarregar status da assinatura
        await _subscription.loadSubscriptionStatus();
      }

      return success;

    } catch (e, stack) {
      AppLogger.error('Erro ao verificar compra', e, stack, 'InAppPurchaseService');
      return false;
    }
  }

  /// Obter detalhes de um produto por ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Finalizar serviço
  void dispose() {
    _subscription?.cancel();
    AppLogger.info('In-App Purchase finalizado', 'InAppPurchaseService');
  }
}
```

### 4.2. Atualizar PaywallScreen

```dart
// lib/src/screens/paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/in_app_purchase_service.dart';
import '../services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final InAppPurchaseService _iap = InAppPurchaseService.instance;
  final SubscriptionService _subscription = SubscriptionService.instance;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await _iap.loadProducts();
    setState(() => _isLoading = false);
  }

  Future<void> _buyProduct(ProductDetails product) async {
    setState(() => _isLoading = true);
    
    final success = await _iap.buyProduct(product);
    
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra iniciada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar compra')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final products = _iap.products;

    return Scaffold(
      appBar: AppBar(title: Text('Escolha seu Plano')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Plano atual
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Plano Atual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(_subscription.getPlanName(), style: TextStyle(fontSize: 24)),
                  SizedBox(height: 8),
                  Text(_subscription.getStatusMessage()),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Produtos disponíveis
          ...products.map((product) => _buildProductCard(product)).toList(),
          
          SizedBox(height: 16),
          
          // Botão restaurar compras
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await _iap.restorePurchases();
              setState(() => _isLoading = false);
            },
            child: Text('Restaurar Compras'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    final isProfessional = product.id.contains('professional');
    final isYearly = product.id.contains('yearly');

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          isProfessional ? 'Professional' : 'Premium',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(isYearly ? 'Plano Anual' : 'Plano Mensal'),
            SizedBox(height: 8),
            Text(product.price, style: TextStyle(fontSize: 24, color: Colors.green)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _buyProduct(product),
          child: Text('Assinar'),
        ),
      ),
    );
  }
}
```

---

## 🧪 5. Testes

### 5.1. Testar no Android

1. Publicar app em **Internal Testing** no Google Play Console
2. Adicionar testers
3. Instalar via link de teste
4. Testar compra (não cobra em ambiente de teste)

### 5.2. Testar no iOS

1. Criar Sandbox Tester Account no App Store Connect
2. No device iOS: Settings → App Store → Sandbox Account
3. Login com conta sandbox
4. Testar compra (não cobra em ambiente sandbox)

### 5.3. Testar Validação

1. Fazer compra de teste
2. Verificar logs no Firebase Functions:
   ```bash
   firebase functions:log --only validateSubscription
   ```
3. Verificar Firestore:
   - `users/{uid}` deve ter `subscriptionStatus: 'active'`
   - `planId` deve estar correto

---

## 🔒 6. Segurança

### ⚠️ NUNCA faça validação apenas no cliente

❌ **Errado**:
```dart
// NÃO FAÇA ISSO!
if (purchase.status == PurchaseStatus.purchased) {
  // Liberar funcionalidades
}
```

✅ **Correto**:
```dart
// Sempre validar no servidor
final success = await _subscription.validatePurchase(...);
if (success) {
  // Funcionalidades são liberadas com base no Firestore
  // que só pode ser alterado por Cloud Functions
}
```

---

## 📊 7. Monitoramento

### Ver compras no Firebase Console

```bash
firebase firestore:query users --where subscriptionStatus==active
```

### Ver logs de validação

```bash
firebase functions:log --only validateSubscription --limit 50
```

### Verificar erros

```bash
firebase functions:log --only validateSubscription --severity ERROR
```

---

## 🐛 8. Troubleshooting

### Produtos não aparecem

1. Verificar IDs dos produtos no código
2. Verificar status dos produtos no console (devem estar ativos)
3. Android: Verificar Google Play Developer API habilitada
4. iOS: Aguardar até 24h após criar produtos

### Compra não valida

1. Verificar logs da Cloud Function
2. Verificar se Service Account tem permissões
3. Verificar Shared Secret (iOS)
4. Verificar token de compra no Firestore

### Assinatura não renova

1. Verificar `autoRenewing: true` no Firestore
2. Verificar se `checkExpiredSubscriptions` está rodando
3. Ver logs do cron job

---

## 📚 Recursos

- [In-App Purchase Flutter Plugin](https://pub.dev/packages/in_app_purchase)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [App Store In-App Purchase](https://developer.apple.com/in-app-purchase/)
- [Firebase Functions](https://firebase.google.com/docs/functions)

---

**Implementação de In-App Purchase concluída!** 💳✅
