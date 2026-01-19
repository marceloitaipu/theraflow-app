# 🔥 Guia de Configuração do Firebase

## 🎯 Entenda a Estrutura

**📦 Seu Projeto (GitHub)** ← Código-fonte Flutter
- Repositório: https://github.com/seu-usuario/theraflow-app
- Contém: código, telas, lógica, widgets
- Local: `C:\Users\marce\OneDrive\Documents\Projetos\theraflow-app-starter`

**🔥 Firebase (Google Cloud)** ← Backend/Infraestrutura
- Console: https://console.firebase.google.com
- Contém: banco de dados, autenticação, storage
- **IMPORTANTE:** É um serviço separado do GitHub!

**🔗 O que faremos:**
Conectar seu código Flutter (GitHub) com o backend Firebase (Google)

---

## ✅ FlutterFire CLI Instalado

O FlutterFire CLI foi instalado com sucesso! Como o Node.js não está disponível, vamos configurar o Firebase manualmente através do Console.

---

## 📋 Passo a Passo

### 1️⃣ Criar Projeto no Firebase Console (Backend)

**⚠️ ATENÇÃO:** Você está criando um projeto no Firebase Console (Google), NÃO no GitHub!

1. Acesse: **https://console.firebase.google.com**
2. Clique em **"Adicionar projeto"** ou **"Create a project"**
3. Nome do projeto Firebase: **`TheraFlow`** (pode ser diferente do GitHub)
   - Sugestão: `theraflow-mvp` ou `theraflow-prod`
   - **NÃO** precisa ser igual ao nome do repositório GitHub
4. **Desative** o Google Analytics (opcional para MVP)
5. Clique em **"Criar projeto"**
6. Aguarde a criação (leva ~30 segundos)

---

### 2️⃣ Configurar Authentication (Autenticação)

1. No menu lateral esquerdo, clique em **"Authentication"**
2. Clique no botão **"Começar"** ou **"Get started"**
3. Na aba **"Sign-in method"**:
   - Clique em **"Email/Password"**
   - **Ative** a primeira opção (Email/Password)
   - Clique em **"Salvar"**

---

### 3️⃣ Configurar Firestore Database

1. No menu lateral, clique em **"Firestore Database"**
2. Clique em **"Criar banco de dados"** ou **"Create database"**
3. **Modo de segurança:**
   - Selecione **"Iniciar em modo de produção"** (Production mode)
4. **Localização:**
   - Escolha **`southamerica-east1 (São Paulo)`** para melhor performance
   - Ou **`us-central1`** se São Paulo não estiver disponível
5. Clique em **"Ativar"** ou **"Enable"**

---

### 4️⃣ Configurar Regras de Segurança do Firestore

1. Na página do Firestore Database, clique na aba **"Regras"** (Rules)
2. **Substitua todo o conteúdo** pelo seguinte:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Função auxiliar para verificar autenticação
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Função auxiliar para verificar se o usuário é dono do recurso
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Regras para coleção de usuários
    match /users/{userId} {
      // Usuário pode ler e escrever apenas seus próprios dados
      allow read, write: if isSignedIn() && isOwner(userId);
      
      // Regras para subcoleção de clientes
      match /clients/{clientId} {
        // Usuário pode ler e escrever apenas seus próprios clientes
        allow read, write: if isSignedIn() && isOwner(userId);
      }
      
      // Regras para subcoleção de sessões
      match /sessions/{sessionId} {
        // Usuário pode ler e escrever apenas suas próprias sessões
        allow read, write: if isSignedIn() && isOwner(userId);
      }
      
      // Regras para subcoleção de pagamentos
      match /payments/{paymentId} {
        // Usuário pode ler e escrever apenas seus próprios pagamentos
        allow read, write: if isSignedIn() && isOwner(userId);
      }
      
      // Regras para subcoleção de pacotes
      match /clients/{clientId}/packages/{packageId} {
        allow read, write: if isSignedIn() && isOwner(userId);
      }
    }
  }
}
```

3. Clique em **"Publicar"** ou **"Publish"**

---

### 5️⃣ Adicionar App Web ao Projeto

1. Na página inicial do projeto, clique no ícone **Web** (`</>`encontrado no centro ou abaixo de "Adicione um app para começar")
2. **Apelido do app**: `TheraFlow Web`
3. **NÃO** marque "Configure Firebase Hosting"
4. Clique em **"Registrar app"**
5. **IMPORTANTE:** Copie as configurações que aparecerem (vamos usar no próximo passo)

Você verá algo assim:
```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "theraflow-xxxxx.firebaseapp.com",
  projectId: "theraflow-xxxxx",
  storageBucket: "theraflow-xxxxx.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};
```

6. **Copie APENAS os valores** (você vai precisar deles)

---

### 6️⃣ Criar arquivo firebase_options.dart

**⚠️ IMPORTANTE - SEGURANÇA:**
- Este arquivo contém chaves de API do seu Firebase
- Por padrão, pode ser commitado no Git (chaves são restritas por domínio)
- Para maior segurança, adicione ao `.gitignore` se preferir

Agora vamos criar o arquivo de configuração do Flutter:

1. Abra o arquivo: **`lib/firebase_options.dart`**

2. **Substitua TODO o conteúdo** por:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // COLE AQUI OS VALORES DO SEU FIREBASE CONSOLE
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'COLE_SEU_API_KEY_AQUI',
    appId: 'COLE_SEU_APP_ID_AQUI',
    messagingSenderId: 'COLE_SEU_MESSAGING_SENDER_ID_AQUI',
    projectId: 'COLE_SEU_PROJECT_ID_AQUI',
    authDomain: 'COLE_SEU_AUTH_DOMAIN_AQUI',
    storageBucket: 'COLE_SEU_STORAGE_BUCKET_AQUI',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'COLE_SEU_API_KEY_AQUI',
    appId: 'COLE_SEU_APP_ID_AQUI',
    messagingSenderId: 'COLE_SEU_MESSAGING_SENDER_ID_AQUI',
    projectId: 'COLE_SEU_PROJECT_ID_AQUI',
    authDomain: 'COLE_SEU_AUTH_DOMAIN_AQUI',
    storageBucket: 'COLE_SEU_STORAGE_BUCKET_AQUI',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'COLE_SEU_API_KEY_AQUI',
    appId: 'COLE_SEU_APP_ID_AQUI',
    messagingSenderId: 'COLE_SEU_MESSAGING_SENDER_ID_AQUI',
    projectId: 'COLE_SEU_PROJECT_ID_AQUI',
    authDomain: 'COLE_SEU_AUTH_DOMAIN_AQUI',
    storageBucket: 'COLE_SEU_STORAGE_BUCKET_AQUI',
    iosBundleId: 'com.theraflow.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'COLE_SEU_API_KEY_AQUI',
    appId: 'COLE_SEU_APP_ID_AQUI',
    messagingSenderId: 'COLE_SEU_MESSAGING_SENDER_ID_AQUI',
    projectId: 'COLE_SEU_PROJECT_ID_AQUI',
    authDomain: 'COLE_SEU_AUTH_DOMAIN_AQUI',
    storageBucket: 'COLE_SEU_STORAGE_BUCKET_AQUI',
  );
}
```

3. **Substitua os valores** `COLE_SEU_..._AQUI` pelos valores que você copiou do Firebase Console

---

### 7️⃣ Descomentar inicialização no main.dart

1. Abra o arquivo: **`lib/main.dart`**

2. **Descomente** as linhas (remova o `//` do início):

```dart
// DE:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// PARA:
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

3. E também descomente a inicialização:

```dart
// DE:
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );

// PARA:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

### 8️⃣ Alterar para usar serviços reais (não mock)

1. Abra: **`lib/src/config/app_config.dart`**

2. Altere:

```dart
// DE:
static const bool useMockServices = true;

// PARA:
static const bool useMockServices = false;
```

---

### 9️⃣ Testar a configuração

1. No terminal, execute:

```powershell
& "$env:USERPROFILE\flutter\bin\flutter.bat" run
```

2. O app deve:
   - Conectar ao Firebase
   - Permitir criar conta
   - Permitir fazer login
   - Salvar dados no Firestore

---

## ✅ Checklist Final

- [ ] Projeto criado no Firebase Console
- [ ] Authentication com Email/Senha ativado
- [ ] Firestore Database criado
- [ ] Regras de segurança publicadas
- [ ] App Web registrado no Firebase
- [ ] Valores copiados do firebaseConfig
- [ ] Arquivo `firebase_options.dart` atualizado
- [ ] Imports descomentados em `main.dart`
- [ ] Inicialização descomentada em `main.dart`
- [ ] `useMockServices = false` em `app_config.dart`
- [ ] App testado e funcionando

---

## 🆘 Problemas Comuns

### Erro: "Firebase not initialized"
- Verifique se descomentou a inicialização no `main.dart`
- Verifique se o `firebase_options.dart` está correto

### Erro: "Permission denied"
- Verifique se as regras do Firestore foram publicadas
- Verifique se o usuário está autenticado

### Erro: "Invalid API key"
- Verifique se copiou corretamente os valores do Firebase Console
- Não deixe espaços ou aspas extras

---

## 📞 Suporte

Se precisar de ajuda:
1. Verifique o console do Firebase em https://console.firebase.google.com
2. Veja os logs no terminal do Flutter
3. Consulte a documentação: https://firebase.flutter.dev/

---

**Status:** ⏳ Aguardando configuração manual
**Última atualização:** 18/01/2026
