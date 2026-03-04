# 🔗 GitHub + Firebase: Como Funcionam Juntos

## 📦 Estrutura do Projeto

```
┌─────────────────────────────────────────────┐
│  GitHub (Código-fonte)                      │
│  https://github.com/seu-usuario/theraflow  │
│                                             │
│  ├── lib/                                   │
│  │   ├── main.dart                          │
│  │   ├── firebase_options.dart ←────────┐  │
│  │   └── src/                            │  │
│  ├── pubspec.yaml                         │  │
│  └── README.md                            │  │
└─────────────────────────────────────────────┘
                                              │
                                              │ Conecta via API
                                              │
┌─────────────────────────────────────────────┘
│
│  🔥 Firebase (Backend - Google Cloud)
│  https://console.firebase.google.com
│
│  ├── 🔐 Authentication (Usuários)
│  ├── 💾 Firestore (Banco de Dados)
│  ├── 📦 Storage (Arquivos)
│  └── 📊 Analytics (Opcional)
└─────────────────────────────────────────────┘
```

---

## 🤔 Diferenças Importantes

### GitHub (Seu Código)
- **O que é:** Repositório do código-fonte
- **Onde fica:** https://github.com
- **Contém:** 
  - Código Dart/Flutter
  - Arquivos de configuração
  - Documentação
  - Assets (imagens, ícones)
- **Gratuito:** Sim (repositórios públicos e privados)
- **Quem gerencia:** Você (via Git)

### Firebase (Seu Backend)
- **O que é:** Plataforma de backend (BaaS - Backend as a Service)
- **Onde fica:** https://console.firebase.google.com
- **Contém:**
  - Banco de dados (Firestore)
  - Sistema de autenticação
  - Storage de arquivos
  - Funções serverless
- **Gratuito:** Sim (plano Spark tem limites)
- **Quem gerencia:** Google Cloud

---

## 🔗 Como se Conectam

### 1. Configuração (Uma vez)

```dart
// lib/firebase_options.dart
// Este arquivo conecta seu app ao Firebase
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIza...', // ← Chaves do seu projeto Firebase
  projectId: 'theraflow-mvp', // ← Nome do projeto no Firebase
  // ...
);
```

### 2. No Código (Sempre que o app roda)

```dart
// lib/main.dart
void main() async {
  // Inicializa conexão com Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

### 3. Fluxo Completo

```
Usuário abre app (GitHub) 
    ↓
App conecta ao Firebase (API Keys)
    ↓
Usuário faz login
    ↓
Firebase autentica
    ↓
App busca dados do Firestore
    ↓
Dados exibidos na tela
```

---

## 🔐 Segurança das Chaves

### firebase_options.dart

**❓ Posso commitar no Git?**
- ✅ **SIM** - Por padrão é seguro
- As chaves são restritas por domínio/bundle ID
- Não funcionam fora do seu app

**🔒 Quando NÃO commitar:**
- Se tiver chaves de serviços sensíveis
- Se quiser ambientes diferentes (dev/prod)
- Se trabalhar com clientes que exigem

**📝 Como NÃO commitar:**
```bash
# .gitignore
lib/firebase_options.dart
```

---

## 🌍 Ambientes (Dev/Prod)

### Estratégia Recomendada

```
GitHub:
├── main branch → Firebase Produção
│   └── firebase_options.dart (chaves prod)
│
└── develop branch → Firebase Desenvolvimento  
    └── firebase_options.dart (chaves dev)
```

### Criar 2 Projetos Firebase:

1. **theraflow-dev** - Para desenvolvimento
2. **theraflow-prod** - Para produção

---

## 📊 Custos

### GitHub
- **Gratuito:** Repositórios públicos e privados ilimitados
- **Pago:** GitHub Actions (CI/CD) tem limites no plano free

### Firebase

#### Plano Spark (Gratuito)
- ✅ Firestore: 50.000 leituras/dia
- ✅ Auth: Ilimitado
- ✅ Storage: 1 GB
- ✅ Hosting: 10 GB/mês

#### Plano Blaze (Paga conforme uso)
- 💰 Firestore: $0.06 por 100k leituras
- 💰 Storage: $0.026 por GB
- 🎁 Inclui cota gratuita do Spark

**💡 Para MVP:** Plano Spark é mais que suficiente!

---

## 🚀 Workflow Recomendado

### 1. Desenvolvimento Local
```bash
git checkout develop
# Código usa firebase_options.dart com projeto DEV
flutter run
```

### 2. Commit e Push
```bash
git add .
git commit -m "feat: adiciona tela de clientes"
git push origin develop
```

### 3. Deploy para Produção
```bash
git checkout main
git merge develop

# Atualizar firebase_options.dart com chaves PROD
git commit -m "chore: update to production firebase"
git push origin main

# Build e publicar na store
flutter build apk --release
```

---

## 🛠️ Comandos Úteis

### Git (Código)
```bash
# Status do repositório
git status

# Ver mudanças
git diff

# Commitar
git add .
git commit -m "mensagem"
git push
```

### Firebase (Backend)
```bash
# Ver logs do Firestore
# No console: Firestore → Dados

# Exportar backup
# No console: Firestore → Import/Export

# Ver usuários
# No console: Authentication → Users
```

---

## 📝 Checklist de Integração

- [ ] Código no GitHub (repositório criado)
- [ ] Projeto Firebase criado (console.firebase.google.com)
- [ ] firebase_options.dart configurado
- [ ] Firebase inicializado em main.dart
- [ ] Regras de segurança publicadas no Firestore
- [ ] .gitignore configurado
- [ ] README.md atualizado com instruções
- [ ] Primeiro commit realizado
- [ ] App testado localmente

---

## 🆘 Problemas Comuns

### "Firebase não conecta"
- ✅ Verifique se as chaves em firebase_options.dart estão corretas
- ✅ Confirme que Firebase.initializeApp() está no main.dart
- ✅ Check internet e firewall

### "Permission denied no Firestore"
- ✅ Verifique se as regras de segurança foram publicadas
- ✅ Confirme que o usuário está autenticado
- ✅ Veja os logs no console do Firebase

### "Git ignorando arquivo"
- ✅ Veja o .gitignore
- ✅ Use `git add -f arquivo` para forçar
- ✅ Remova do .gitignore se quiser versionar

---

## 📚 Documentação Oficial

- **Firebase:** https://firebase.google.com/docs
- **FlutterFire:** https://firebase.flutter.dev
- **Git:** https://git-scm.com/doc
- **GitHub:** https://docs.github.com

---

**Resumo:** 
- 📦 **GitHub** = Código (versionamento)
- 🔥 **Firebase** = Backend (banco de dados + auth)
- 🔗 **Conexão** = firebase_options.dart + inicialização

Ambos são necessários e complementares! 🚀
