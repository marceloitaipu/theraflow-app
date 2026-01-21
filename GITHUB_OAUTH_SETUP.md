# 🔐 Configuração do GitHub OAuth

## 📋 Visão Geral

Este guia explica como configurar o login com GitHub no TheraFlow, permitindo que usuários façam login usando suas contas do GitHub.

**Status Atual**: ⚠️ Código implementado, mas OAuth não configurado

---

## 🎯 O que você vai fazer

1. Criar OAuth App no GitHub
2. Ativar GitHub como provider no Firebase
3. Conectar GitHub ↔ Firebase
4. Testar login

**Tempo estimado**: 10 minutos

---

## 📝 Passo a Passo

### 1️⃣ Ativar GitHub no Firebase Console

1. Acesse: **https://console.firebase.google.com**
2. Selecione o projeto: **theraflow-app-83126**
3. No menu lateral, clique em **"Authentication"**
4. Clique na aba **"Sign-in method"**
5. Na lista de provedores, encontre **"GitHub"**
6. Clique em **"GitHub"** para expandir
7. **Ative** o toggle (Enable)

**⚠️ NÃO clique em "Salvar" ainda!**

8. **COPIE** a **"Authorization callback URL"**
   - Será algo como: `https://theraflow-app-83126.firebaseapp.com/__/auth/handler`
   - Você vai usar isso no próximo passo

---

### 2️⃣ Criar OAuth App no GitHub

1. Acesse: **https://github.com/settings/developers**
   - Ou: Settings → Developer settings → OAuth Apps

2. Clique em **"New OAuth App"**

3. Preencha os campos:

   **Application name:**
   ```
   TheraFlow
   ```

   **Homepage URL:**
   ```
   https://theraflow-app-83126.web.app
   ```
   
   **Application description** (opcional):
   ```
   Plataforma de gestão para consultórios de terapia
   ```

   **Authorization callback URL:**
   ```
   Cole a URL que você copiou do Firebase (passo 1.8)
   Exemplo: https://theraflow-app-83126.firebaseapp.com/__/auth/handler
   ```

4. Clique em **"Register application"**

5. Na página do app criado:
   - **COPIE** o **Client ID**
   - Clique em **"Generate a new client secret"**
   - **COPIE** o **Client Secret** (só aparece uma vez!)

---

### 3️⃣ Conectar GitHub ao Firebase

1. Volte para o **Firebase Console** (aba ainda aberta do passo 1)
2. Na configuração do GitHub:

   **Client ID:**
   ```
   Cole o Client ID copiado do GitHub
   ```

   **Client secret:**
   ```
   Cole o Client Secret copiado do GitHub
   ```

3. Clique em **"Salvar"** ou **"Save"**

4. ✅ O GitHub deve aparecer como **"Enabled"** na lista

---

### 4️⃣ Testar Login com GitHub

#### Opção A: Testar no Web (Recomendado)

1. Execute o app:
   ```powershell
   flutter run -d chrome
   ```

2. Na tela de login:
   - Clique em **"Continuar com GitHub"**
   - Será aberto popup do GitHub
   - Autorize o app
   - Você será redirecionado de volta

3. ✅ Se funcionar:
   - Você será levado para o onboarding (primeiro login)
   - Ou para a home (login subsequente)

#### Opção B: Testar no Emulador Android

⚠️ **ATENÇÃO**: No Android, você precisa:
1. Configurar SHA-1 fingerprint
2. Adicionar ao Firebase Console
3. Baixar novo `google-services.json`

**Para desenvolvimento, use Web primeiro!**

---

## 🔍 Verificar Configuração

### No Firebase Console

1. Authentication → Sign-in method
2. GitHub deve estar **"Enabled"**
3. Clique para ver detalhes:
   - ✅ Client ID configurado
   - ✅ Client Secret configurado
   - ✅ Callback URL copiada

### No GitHub

1. https://github.com/settings/developers
2. Seu app "TheraFlow" deve aparecer
3. Clique para ver:
   - ✅ Client ID correto
   - ✅ Callback URL do Firebase
   - ✅ App ativo

---

## ⚠️ Problemas Comuns

### "Redirect URI mismatch"

**Causa**: Callback URL no GitHub diferente da URL do Firebase

**Solução**:
1. Copie novamente a callback URL do Firebase
2. Atualize no GitHub OAuth App
3. Aguarde 1-2 minutos para propagar

### "Invalid client_id or client_secret"

**Causa**: Valores copiados incorretamente

**Solução**:
1. Verifique espaços extras
2. Gere novo Client Secret no GitHub
3. Atualize no Firebase

### "Popup blocked"

**Causa**: Navegador bloqueou popup de autenticação

**Solução**:
1. Permita popups para localhost
2. Ou use: `flutter run -d chrome --web-browser-flag "--disable-popup-blocking"`

### "Access denied"

**Causa**: Usuário negou permissão no GitHub

**Solução**:
1. Normal - usuário escolheu não autorizar
2. Tentar login novamente

---

## 🔒 Segurança

### Client Secret

- ⚠️ **NUNCA** commite o Client Secret no código
- ✅ Está seguro no Firebase (servidor)
- ✅ O app usa Firebase SDK (não precisa do secret)

### Callback URL

- ✅ Deve ser EXATAMENTE a URL do Firebase
- ⚠️ Se mudar domínio, atualizar no GitHub
- ✅ Firebase só aceita callbacks do próprio domínio

### Permissões Solicitadas

O GitHub OAuth solicitará:
- ✅ Email address (obrigatório para login)
- ✅ Public profile (nome, avatar)

**NÃO solicitamos**:
- ❌ Acesso a repositórios
- ❌ Permissão de escrita
- ❌ Dados privados

---

## 🌍 Múltiplos Ambientes

### Desenvolvimento vs Produção

Se você tem 2 projetos Firebase (dev/prod):

**Projeto DEV**:
1. Criar OAuth App: "TheraFlow Dev"
2. Callback: `https://theraflow-dev.firebaseapp.com/__/auth/handler`

**Projeto PROD**:
1. Criar OAuth App: "TheraFlow"
2. Callback: `https://theraflow-app-83126.firebaseapp.com/__/auth/handler`

Cada projeto Firebase precisa de um OAuth App separado no GitHub.

---

## 📱 Plataformas

### ✅ Web (Chrome, Edge, Safari, Firefox)
- Funciona imediatamente após configuração
- Usa popup para autenticação
- Melhor experiência

### ⚠️ Android
Requer configuração adicional:
```bash
# Gerar SHA-1
cd android
./gradlew signingReport

# Adicionar ao Firebase Console
# Project Settings → Your apps → Android
# Add SHA-1 fingerprint
```

### ⚠️ iOS
Requer configuração adicional:
- URL Scheme no Info.plist
- Associated Domains
- Capabilities habilitadas

**Recomendação**: Comece com Web, adicione mobile depois.

---

## 🧪 Testes

### Cenário 1: Primeiro Login
1. Usuário clica "Continuar com GitHub"
2. Popup do GitHub abre
3. Usuário autoriza
4. Conta criada no Firestore
5. Redirecionado para `/onboarding`

### Cenário 2: Login Subsequente
1. Usuário clica "Continuar com GitHub"
2. GitHub reconhece autorização prévia
3. Login imediato
4. Redirecionado para `/home`

### Cenário 3: Email já Cadastrado
Se usuário criou conta com email/senha e depois tenta GitHub com mesmo email:
- ✅ Firebase vincula automaticamente
- ✅ Pode usar ambos os métodos

---

## ✅ Checklist Final

- [ ] OAuth App criado no GitHub
- [ ] Client ID e Secret copiados
- [ ] GitHub ativado no Firebase Console
- [ ] Callback URL configurada corretamente
- [ ] Testado no navegador
- [ ] Login funcionando
- [ ] Dados do usuário salvos no Firestore
- [ ] Redirecionamento correto após login

---

## 📚 Referências

- [Firebase Authentication - GitHub](https://firebase.google.com/docs/auth/web/github-auth)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [FlutterFire Auth](https://firebase.flutter.dev/docs/auth/usage)

---

## 🆘 Precisa de Ajuda?

Se algo não funcionar:

1. **Console do navegador** (F12):
   ```
   Veja erros de JavaScript/Firebase
   ```

2. **Firebase Console → Authentication → Users**:
   ```
   Verifique se usuários estão sendo criados
   ```

3. **GitHub OAuth Settings**:
   ```
   Verifique "Recent Delivery" para ver requisições
   ```

---

**Status**: ⏳ Aguardando configuração
**Última atualização**: 19/01/2026
