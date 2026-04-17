# Changelog - Correções e Melhorias

## [1.1.0] - 2026-04-16

### 🏗️ Refatoração Arquitetural (single-tenant, offline-first)

- **Barrel `app_services.dart`**: reescrito como barrel file que expõe serviços V2 (`ClientService`, `SessionService`, `PackageService`, `FinanceService`, `AuthService`). As 9 telas passaram a consumir V2 sem alteração de código.
- **`ProfileService` estendido** com `module` e `businessName`, gravando direto em `users/{uid}` (Firestore).
- **`BillingService` simplificado**: removida dependência de `BusinessService` e `AppModule`. Factory pluggable com `DisabledBillingService` como default em produção.
- **`PaywallScreen` reescrito**: usa `FutureBuilder<User>` lendo `users/{uid}.plan` (Gratuito / Profissional / Premium).
- **`OnboardingScreen` simplificado**: removida chamada a `BusinessService.createBusiness`; salva perfil via `ProfileService.saveProfile(module, businessName)`.
- **`SplashScreen` + auth gate** no `app_router.dart` com redirect reativo.
- **`DataChangeBus`**: substitui `Stream.periodic` por broadcast de eventos tipados.
- **Schema SQLite v3**: campos canônicos (`status`, `expirationDate`, `remainingSessions`, `price`).
- **Regras Firestore** reescritas para single-tenant (`users/{uid}/**`).

### 🧹 Limpeza

- **14 arquivos legacy deletados**: `mock_data_service.dart`, `mock_auth_service.dart`, `business_service.dart`, `mock_login_screen.dart`, `module_gate.dart`, `widgets/metadata/*` (pasta inteira), modelos órfãos (`business`, `appointment`, `appointment_metadata`, `service_item`, `transaction`) + 9 testes órfãos.
- Substituição de `print()` por `developer.log()` em `incremental_sync_service.dart`.
- `try/catch` em volta de chamadas ao `connectivity_plus` com fallback `isOnline = true`.
- `.withOpacity(x)` → `.withValues(alpha: x)` (Flutter 3.27+).
- `(_, __)` → `(_, _)` no `app_router.dart` (novo lint Dart).
- `const Uuid()` nos 4 serviços V2.
- `useMaterial3: true` movido para o construtor `ThemeData.light/dark`.
- `DropdownButtonFormField.value:` → `initialValue:`; `activeColor:` → `activeThumbColor:`.

### 📊 Qualidade

- `flutter analyze`: **56 issues → 7 infos** (0 erros, 0 warnings).
- `flutter test`: **94/94 passando** (antes 85).
- 9/9 telas migradas para V2.

### 📚 Documentação

- Criado [ARCHITECTURE.md](ARCHITECTURE.md) refletindo o estado atual.
- Removidos 12 arquivos `.md` históricos/redundantes: `ALTERACOES_IMPLEMENTADAS`, `ARQUITETURA_IMPLEMENTADA`, `CONFIGURACOES_PENDENTES`, `CORRECOES`, `IMPLEMENTACAO_COMPLETA`, `INDICE_DOCUMENTACAO`, `LIMPEZA_PROJETO`, `MUDANCAS_NECESSARIAS`, `PROFISSIONALIZACAO_COMPLETA`, `README_PROFISSIONALIZACAO`, `RELATORIO_SESSAO_19_01_2026`, `STATUS_ATUAL`.

### ⚠️ Ações Externas Pendentes

1. Rotacionar API key do Firebase.
2. `firebase deploy --only firestore:rules`.
3. Integração real Google Play / App Store (via RevenueCat).

---

## [1.0.1] - 2026-01-18

### ✅ Corrigido

#### 1. **Configuração do Firebase**
- ✅ Adicionados imports necessários no `main.dart`
- ✅ Preparada inicialização do Firebase com instruções claras
- ✅ Comentários detalhados sobre os passos de configuração

#### 2. **Localização pt_BR**
- ✅ Adicionada dependência `flutter_localizations`
- ✅ Configurados delegates de localização no MaterialApp
- ✅ Locale padrão definido como português brasileiro
- ✅ Inicialização de formatação de datas para pt_BR

#### 3. **Inconsistências de Imports**
- ✅ Corrigido `OnboardingScreen` para usar `app_services.dart`
- ✅ Imports organizados e consistentes em todas as telas
- ✅ Removidas importações diretas dos serviços em telas

### 🆕 Adicionado

#### 4. **Sistema de Validação**
- ✅ Criado `validators.dart` com validadores reutilizáveis:
  - Email, senha, nome, telefone
  - Valores monetários e inteiros
  - Combinação de múltiplos validadores
  
#### 5. **Sistema de Formatação**
- ✅ Criado `formatters.dart` com formatadores:
  - Moeda (R$), data e hora
  - Telefone brasileiro
  - Duração em minutos
  - Capitalização de nomes
  - CPF

#### 6. **Tratamento de Erros**
- ✅ Criado `error_handler.dart` com:
  - Métodos para exibir erros, sucessos, avisos
  - Conversão de erros técnicos em mensagens amigáveis
  - Widget de loading overlay
  - Diálogos de erro detalhados

#### 7. **Configuração do App**
- ✅ Criado `app_config.dart` com:
  - Flag para alternar entre mock e Firebase
  - Configurações centralizadas (limites, preços padrão)
  - Informações de contato e versão
  - Modo debug

#### 8. **Testes Unitários**
- ✅ Criado `validators_test.dart`
  - Testes para todos os validadores
  - Cobertura de casos válidos e inválidos
- ✅ Arquivo `user_test.dart` já existia com testes do modelo User

### 📚 Documentação

#### 9. **Melhorias na Estrutura**
- ✅ Arquivos organizados em `lib/src/utils/`
- ✅ Arquivos organizados em `lib/src/config/`
- ✅ Widgets reutilizáveis em `lib/src/widgets/`
- ✅ Testes organizados seguindo estrutura do projeto

---

## 📋 Como Usar as Melhorias

### Validação em Formulários
```dart
TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(labelText: 'E-mail'),
  validator: Validators.email,
)
```

### Formatação de Valores
```dart
import 'package:theraflow/src/utils/formatters.dart';

Text(Formatters.currency(150.00));  // R$ 150,00
Text(Formatters.date(DateTime.now()));  // 18/01/2026
Text(Formatters.phone('11999998888'));  // (11) 99999-8888
```

### Tratamento de Erros
```dart
try {
  // código que pode falhar
} catch (e) {
  ErrorHandler.showError(context, ErrorHandler.friendlyMessage(e));
}
```

### Alternar entre Mock e Firebase
Em `app_config.dart`, altere:
```dart
static const bool useMockServices = false;  // Para usar Firebase
```

---

## 🔜 Próximos Passos Recomendados

1. **Configurar Firebase**
   ```powershell
   flutterfire configure
   ```

2. **Descomentar inicialização** em `main.dart`

3. **Executar testes**
   ```powershell
   flutter test
   ```

4. **Testar o app**
   ```powershell
   flutter run
   ```

---

## 🐛 Bugs Corrigidos

- ❌ Firebase não inicializava corretamente
- ❌ Localização não estava em português
- ❌ OnboardingScreen com imports inconsistentes
- ❌ Faltavam validações nos formulários
- ❌ Mensagens de erro técnicas para o usuário
- ❌ Sem formatação padronizada de valores

## ✨ Melhorias de Código

- 📝 Comentários mais claros e detalhados
- 🏗️ Estrutura de pastas mais organizada
- 🔧 Utilitários reutilizáveis
- 🧪 Cobertura de testes aumentada
- 📚 Documentação melhorada

---

**Status:** ✅ Pronto para configuração do Firebase e testes finais
