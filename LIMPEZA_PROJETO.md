# 🧹 Guia de Limpeza e Preparação para Distribuição

## ✅ Arquivos para REMOVER antes de distribuir/vender

### 1. Pastas de Build e Cache
```bash
# Remover via terminal
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
```

### 2. Arquivos Mock e Teste
Buscar e remover:
- `lib/src/services/mock_*.dart`
- `lib/src/screens/*_test_*.dart`
- Qualquer arquivo com `mock` ou `test` no nome (exceto pasta `test/`)

### 3. Serviços Duplicados (Consolidar)
O projeto atualmente tem duplicação:
- ✅ **MANTER**: `client_service_v2.dart` (versão com SQLite)
- ❌ **REMOVER**: `client_service.dart` (versão antiga Firestore-only)
- ✅ **MANTER**: `session_service_v2.dart`
- ❌ **REMOVER**: `session_service.dart`
- ✅ **MANTER**: `finance_service_v2.dart`
- ❌ **REMOVER**: `finance_service.dart`

**OU** renomear os `_v2` para versão final sem sufixo.

### 4. Documentos Temporários
Avaliar necessidade de manter:
- `ALTERACOES_IMPLEMENTADAS.md`
- `CORRECOES.md`
- `RELATORIO_SESSAO_19_01_2026.md`
- `STATUS_ATUAL.md`
- `CONFIGURACOES_PENDENTES.md`

**Sugestão**: Mover para pasta `docs/internal/` ou remover completamente.

### 5. Pastas de Demonstração
Se não forem necessárias:
- `demo/`
- `demo-web/`
- `landing-page/`

Manter apenas se fizerem parte da entrega ao cliente.

## 🔄 Ações de Consolidação

### Renomear Serviços _v2 para Versão Final

```bash
# Exemplo (ajustar conforme estrutura)
cd lib/src/services/

# Remover versões antigas
rm client_service.dart
rm session_service.dart
rm finance_service.dart

# Renomear v2 para versão final (ou apenas atualizar imports)
mv client_service_v2.dart client_service.dart
mv session_service_v2.dart session_service.dart
mv finance_service_v2.dart finance_service.dart
```

**IMPORTANTE**: Após renomear, atualizar TODOS os imports no código:
```dart
// Antes
import 'package:theraflow/src/services/client_service_v2.dart';

// Depois
import 'package:theraflow/src/services/client_service.dart';
```

### Substituir sync_service.dart por incremental_sync_service.dart

1. Atualizar imports em todo o projeto:
   ```dart
   // Antes
   import 'package:theraflow/src/services/sync_service.dart';
   
   // Depois
   import 'package:theraflow/src/services/incremental_sync_service.dart';
   ```

2. Atualizar instâncias:
   ```dart
   // Antes
   SyncService.instance
   
   // Depois
   IncrementalSyncService.instance
   ```

3. Remover `lib/src/services/sync_service.dart`

## 📦 Preparar para Distribuição

### Checklist Final

- [ ] Remover `build/` e `.dart_tool/`
- [ ] Remover arquivos mock (`mock_*.dart`)
- [ ] Consolidar serviços (remover duplicados)
- [ ] Atualizar todos os imports
- [ ] Executar `flutter clean`
- [ ] Executar `flutter pub get`
- [ ] Compilar para garantir que não há erros:
  ```bash
  flutter build apk --release  # Android
  flutter build ios --release  # iOS
  ```
- [ ] Verificar que `.gitignore` está correto
- [ ] Remover documentos temporários
- [ ] Criar arquivo `INSTALL.md` com instruções de setup
- [ ] Verificar que credenciais Firebase estão OK
- [ ] Testar sincronização e assinatura em produção

### Estrutura Final Limpa

```
theraflow-app-starter/
├── android/              ✅ Manter
├── ios/                  ✅ Manter
├── lib/                  ✅ Manter (limpo)
│   ├── src/
│   │   ├── models/
│   │   ├── services/     ⚠️ Sem duplicados
│   │   ├── screens/      ⚠️ Sem mocks
│   │   ├── widgets/
│   │   └── database/
│   ├── firebase_options.dart
│   └── main.dart
├── functions/            ✅ Cloud Functions
├── test/                 ✅ Manter
├── assets/               ✅ Manter
├── docs/                 ✅ Manter documentação necessária
├── pubspec.yaml          ✅ Manter
├── README.md             ✅ Manter e atualizar
├── .gitignore            ✅ Atualizado
└── firestore.rules       ✅ Manter (corrigido)
```

## 🚫 O que NÃO incluir no ZIP/repositório vendido

1. **Pastas de build**:
   - `build/`
   - `.dart_tool/`
   - `node_modules/` (se houver)

2. **Configurações pessoais**:
   - `.vscode/`
   - `.idea/`
   - `*.code-workspace`

3. **Arquivos temporários**:
   - `*.log`
   - `*.tmp`
   - Relatórios internos de desenvolvimento

4. **Credenciais** (o cliente deve configurar as suas):
   - Se compartilhar Firebase, fornecer instruções para criar novo projeto
   - Nunca incluir `*.jks`, `*.keystore`, `*.key`

## 📝 Documentação Adicional Necessária

Criar/atualizar:
1. `README.md` - Visão geral do projeto
2. `SETUP.md` - Instruções de configuração
3. `FIREBASE_SETUP.md` - Como configurar Firebase
4. `functions/README.md` - Como fazer deploy das Cloud Functions
5. `ARCHITECTURE.md` - Arquitetura da aplicação (opcional mas recomendado)

## ⚡ Script de Limpeza Rápida

Criar arquivo `clean_for_dist.sh`:
```bash
#!/bin/bash

echo "Limpando projeto para distribuição..."

# Remover builds
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Remover node_modules se existir
rm -rf node_modules/
rm -rf functions/node_modules/

# Remover logs
find . -name "*.log" -delete

# Flutter clean
flutter clean

echo "Limpeza concluída!"
echo "Próximos passos:"
echo "1. Remover arquivos mock manualmente"
echo "2. Consolidar serviços duplicados"
echo "3. Atualizar imports"
echo "4. Executar 'flutter pub get'"
echo "5. Testar build: 'flutter build apk --release'"
```

Executar:
```bash
chmod +x clean_for_dist.sh
./clean_for_dist.sh
```

## 🎯 Próximos Passos

Após limpeza:
1. Testar aplicação completamente
2. Garantir que sincronização funciona
3. Validar regras do Firestore
4. Testar fluxo de assinatura
5. Criar documentação de handoff para cliente
6. Preparar apresentação/demo
