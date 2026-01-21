# 🔄 Mudanças Necessárias no Código Existente

Este documento lista as mudanças que precisam ser feitas no código existente para integrar as novas implementações.

---

## 1. Atualizar main.dart

### Adicionar inicialização dos novos serviços

```dart
// lib/main.dart

import 'src/services/incremental_sync_service.dart';
import 'src/services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar banco de dados
  await DatabaseHelper.instance.database;
  
  // Inicializar sincronização (NOVO)
  await IncrementalSyncService.instance.initialize();
  
  // Inicializar serviço de assinaturas (NOVO)
  await SubscriptionService.instance.initialize();
  
  runApp(MyApp());
}
```

---

## 2. Atualizar client_service_v2.dart

### Usar updatedAt em vez de lastModified

**Arquivo**: `lib/src/services/client_service_v2.dart`

```dart
// ANTES
final clientData = {
  'id': id,
  'userId': userId,
  'name': name,
  'phone': phone,
  'notes': notes ?? '',
  'createdAt': now.toIso8601String(),
  'status': 'active',
  'synced': _sync.isOnline ? 1 : 0,
  'lastModified': now.toIso8601String(), // ❌ Remover
  'deleted': 0,
};

// DEPOIS
final clientData = {
  'id': id,
  'userId': userId,
  'name': name,
  'phone': phone,
  'notes': notes ?? '',
  'createdAt': now.toIso8601String(),
  'updatedAt': now.toIso8601String(), // ✅ Novo campo
  'deletedAt': null,
  'status': 'active',
  'synced': _sync.isOnline ? 1 : 0,
  'deleted': 0,
};
```

### Substituir SyncService por IncrementalSyncService

```dart
// ANTES
import 'sync_service.dart';
final SyncService _sync = SyncService.instance;

// DEPOIS
import 'incremental_sync_service.dart';
final IncrementalSyncService _sync = IncrementalSyncService.instance;
```

### Atualizar método de update

```dart
Future<void> updateClient(String id, {
  String? name,
  String? phone,
  String? notes,
  String? status,
}) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado.');

  final now = DateTime.now();
  final updates = <String, dynamic>{
    'updatedAt': now.toIso8601String(), // ✅ Adicionar
    'synced': 0,
  };
  
  if (name != null) updates['name'] = name;
  if (phone != null) updates['phone'] = phone;
  if (notes != null) updates['notes'] = notes;
  if (status != null) updates['status'] = status;

  await _db.updateClient(id, updates);

  if (_sync.isOnline) {
    _sync.syncAll();
  }
}
```

### Implementar soft delete

```dart
Future<void> deleteClient(String id) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado.');

  final now = DateTime.now();
  
  // Soft delete: marcar deletedAt
  await _db.updateClient(id, {
    'deletedAt': now.toIso8601String(), // ✅ Soft delete
    'updatedAt': now.toIso8601String(),
    'deleted': 1,
    'synced': 0,
  });

  if (_sync.isOnline) {
    _sync.syncAll();
  }
}
```

---

## 3. Aplicar mesmas mudanças em outros serviços

### session_service_v2.dart

- ✅ Adicionar `updatedAt` e `deletedAt`
- ✅ Usar `IncrementalSyncService`
- ✅ Implementar soft delete

### finance_service_v2.dart

- ✅ Adicionar `updatedAt` e `deletedAt`
- ✅ Usar `IncrementalSyncService`
- ✅ Implementar soft delete

### package_service.dart

- ✅ Adicionar `updatedAt` e `deletedAt`
- ✅ Usar `IncrementalSyncService`
- ✅ Implementar soft delete

---

## 4. Atualizar DatabaseHelper

### Já implementado ✅

Os métodos de database já foram atualizados:
- ✅ Tabelas com `updatedAt` e `deletedAt`
- ✅ Métodos `setLastSyncTimestamp` e `getLastSyncTimestamp`
- ✅ Migração automática para versão 2

Nenhuma mudança adicional necessária.

---

## 5. Integrar SubscriptionService nas telas

### Verificar antes de criar cliente

```dart
// Exemplo: client_list_screen.dart ou similar

import '../services/subscription_service.dart';

class ClientListScreen extends StatelessWidget {
  final SubscriptionService _subscription = SubscriptionService.instance;

  Future<void> _createClient() async {
    // Verificar se pode criar
    if (!await _subscription.canCreateClient()) {
      _showUpgradeDialog();
      return;
    }

    // Criar cliente normalmente
    // ...
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limite Atingido'),
        content: Text(
          'Você atingiu o limite de ${_subscription.getClientLimit()} clientes do plano ${_subscription.getPlanName()}. '
          'Faça upgrade para continuar!'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _subscription.showUpgradeScreen();
            },
            child: Text('Fazer Upgrade'),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Atualizar PaywallScreen

### Integrar com SubscriptionService

```dart
// lib/src/screens/paywall_screen.dart

import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subscription = SubscriptionService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escolha seu Plano')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
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
            
            // Planos disponíveis
            _buildPlanCard('Professional', 'R\$ 29,90/mês', [
              '✓ Até 50 clientes',
              '✓ Agendamento ilimitado',
              '✓ Relatórios básicos',
              '✓ Backup na nuvem',
            ]),
            
            SizedBox(height: 16),
            
            _buildPlanCard('Premium', 'R\$ 49,90/mês', [
              '✓ Clientes ilimitados',
              '✓ Agendamento ilimitado',
              '✓ Relatórios avançados',
              '✓ Backup na nuvem',
              '✓ Suporte prioritário',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> features) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(price, style: TextStyle(fontSize: 20, color: Colors.green)),
            SizedBox(height: 16),
            ...features.map((f) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(f),
            )),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar compra após adicionar in_app_purchase
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('In-App Purchase será implementado em breve')),
                  );
                },
                child: Text('Assinar $name'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Substituir print() por AppLogger

### Em todos os arquivos de serviços

```dart
// ANTES
print('Erro ao sincronizar: $e');
print('Sincronização completa');

// DEPOIS
import 'incremental_sync_service.dart'; // AppLogger está aqui

AppLogger.error('Erro ao sincronizar', e, stack, 'ClientService');
AppLogger.info('Sincronização completa', 'ClientService');
```

### Exemplo completo

```dart
try {
  await _db.insertClient(clientData);
  AppLogger.info('Cliente criado: $id', 'ClientService');
} catch (e, stack) {
  AppLogger.error('Erro ao criar cliente', e, stack, 'ClientService');
  rethrow;
}
```

---

## 8. Remover sync_service.dart antigo

### Após atualizar todos os imports

```bash
# Verificar se não há mais referências
grep -r "sync_service.dart" lib/

# Se não houver, remover
rm lib/src/services/sync_service.dart
```

---

## 9. Consolidar serviços duplicados

### Remover versões antigas

```bash
# Remover versões antigas (Firestore-only)
rm lib/src/services/client_service.dart
rm lib/src/services/session_service.dart
rm lib/src/services/finance_service.dart

# Renomear v2 para versão final (opcional)
mv lib/src/services/client_service_v2.dart lib/src/services/client_service.dart
mv lib/src/services/session_service_v2.dart lib/src/services/session_service.dart
mv lib/src/services/finance_service_v2.dart lib/src/services/finance_service.dart
```

### Atualizar imports em todo o código

```bash
# Buscar e substituir
# client_service_v2 → client_service
# session_service_v2 → session_service
# finance_service_v2 → finance_service
```

---

## 10. Adicionar validação de assinatura no AuthService

### Carregar status após login

```dart
// lib/src/services/auth_service.dart

import 'subscription_service.dart';

class AuthService {
  final SubscriptionService _subscription = SubscriptionService.instance;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Login normal
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Carregar status da assinatura
    if (credential.user != null) {
      await _subscription.loadSubscriptionStatus();
      AppLogger.info('Status de assinatura carregado', 'AuthService');
    }
  }
}
```

---

## 📋 Checklist de Implementação

### Arquivos para Modificar

- [ ] `lib/main.dart` - Adicionar inicialização dos serviços
- [ ] `lib/src/services/client_service_v2.dart` - Usar updatedAt, IncrementalSyncService
- [ ] `lib/src/services/session_service_v2.dart` - Usar updatedAt, IncrementalSyncService
- [ ] `lib/src/services/finance_service_v2.dart` - Usar updatedAt, IncrementalSyncService
- [ ] `lib/src/services/package_service.dart` - Usar updatedAt, IncrementalSyncService
- [ ] `lib/src/services/auth_service.dart` - Carregar status de assinatura
- [ ] `lib/src/screens/paywall_screen.dart` - Integrar SubscriptionService
- [ ] Telas de listagem - Adicionar verificação de limite

### Arquivos para Remover (Após consolidação)

- [ ] `lib/src/services/sync_service.dart` (versão antiga)
- [ ] `lib/src/services/client_service.dart` (versão antiga)
- [ ] `lib/src/services/session_service.dart` (versão antiga)
- [ ] `lib/src/services/finance_service.dart` (versão antiga)
- [ ] Arquivos mock (`mock_*.dart`)

### Executar

- [ ] `flutter pub get` - Atualizar dependências
- [ ] `flutter clean` - Limpar build
- [ ] `flutter analyze` - Verificar erros
- [ ] `flutter run` - Testar app
- [ ] Verificar sincronização online/offline
- [ ] Verificar limites de plano
- [ ] Deploy Firebase Rules e Functions

---

## ⚡ Script de Atualização Rápida

```bash
#!/bin/bash

echo "Atualizando dependências..."
flutter pub get

echo "Limpando build..."
flutter clean

echo "Analisando código..."
flutter analyze

echo "Verificando estrutura..."
flutter test

echo "Pronto para desenvolvimento!"
echo "Próximo passo: Atualizar imports e implementar mudanças"
```

---

## 🎯 Ordem de Implementação Recomendada

1. ✅ **Atualizar main.dart** (5 min)
2. ✅ **Atualizar client_service_v2.dart** (15 min)
3. ✅ **Atualizar session_service_v2.dart** (15 min)
4. ✅ **Atualizar finance_service_v2.dart** (15 min)
5. ✅ **Atualizar PaywallScreen** (10 min)
6. ✅ **Adicionar verificações de limite nas telas** (20 min)
7. ✅ **Substituir print() por AppLogger** (30 min)
8. ✅ **Consolidar serviços duplicados** (30 min)
9. ✅ **Testar fluxo completo** (30 min)
10. ✅ **Deploy Firebase** (10 min)

**Total estimado**: 3 horas

---

**Após implementar estas mudanças, o projeto estará completamente profissionalizado!** ✨
