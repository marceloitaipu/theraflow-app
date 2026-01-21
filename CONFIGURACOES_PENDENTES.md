# ✅ Checklist de Configuração - Ações Pendentes

## 📋 Tarefas que Requerem Acesso ao Console

Este documento lista todas as configurações que **VOCÊ** precisa fazer manualmente nos consoles do Firebase e GitHub.

**Data**: 19/01/2026  
**Projeto**: TheraFlow  
**Firebase Project ID**: theraflow-app-83126

---

## 🔥 Firebase Console

Acesse: https://console.firebase.google.com

### 1️⃣ Configurar GitHub OAuth

**Status**: ⚠️ Pendente  
**Prioridade**: Alta  
**Tempo estimado**: 10 minutos

**O que fazer:**
1. Authentication → Sign-in method
2. Ativar provider "GitHub"
3. Copiar Callback URL
4. Seguir guia completo: [GITHUB_OAUTH_SETUP.md](GITHUB_OAUTH_SETUP.md)

**Por que é importante:**
- Botão "Continuar com GitHub" na tela de login não funciona sem isso
- Melhora experiência do usuário
- Reduz fricção no onboarding

---

### 2️⃣ Publicar Regras de Segurança do Firestore

**Status**: ⚠️ Pendente  
**Prioridade**: CRÍTICA  
**Tempo estimado**: 2 minutos

**O que fazer:**
1. Firestore Database → Regras
2. Copiar conteúdo do arquivo: [firestore.rules](firestore.rules)
3. Colar no editor
4. Clicar em **"Publicar"**

**Por que é CRÍTICO:**
- Sem regras publicadas, usuários podem ter erro "Permission denied"
- Dados podem ficar expostos se regras estiverem em modo teste
- Necessário para segurança multi-tenant (cada usuário só vê seus dados)

**⚠️ ATENÇÃO**: As regras estão prontas no código, mas NÃO foram publicadas no servidor!

---

### 3️⃣ Baixar google-services.json (Android)

**Status**: ⚠️ Pendente  
**Prioridade**: Média (se for usar Android)  
**Tempo estimado**: 5 minutos

**O que fazer:**
1. Project Settings (engrenagem)
2. Na seção "Your apps", encontre o app Android
   - Se não existe: clicar em "Add app" → Android
3. Registrar app:
   - **Package name**: `com.theraflow.app`
   - **App nickname**: TheraFlow Android
4. Baixar `google-services.json`
5. Salvar em: `android/app/google-services.json`

**Por que é importante:**
- App Android não conecta ao Firebase sem este arquivo
- Contém configurações específicas da plataforma
- Já adicionamos o plugin no build.gradle

**Nota**: ✅ Plugin já configurado no código, só falta o arquivo JSON

---

### 4️⃣ Configurar App iOS (Opcional)

**Status**: 📋 Opcional  
**Prioridade**: Baixa  
**Tempo estimado**: 5 minutos

**O que fazer:**
1. Project Settings → Your apps
2. Add app → iOS
3. **Bundle ID**: `com.theraflow.app`
4. Baixar `GoogleService-Info.plist`
5. Salvar em: `ios/Runner/GoogleService-Info.plist`

**Nota**: Necessário apenas se for testar em iOS/macOS

---

### 5️⃣ Ativar Firebase Hosting (Opcional)

**Status**: 📋 Opcional  
**Prioridade**: Baixa  
**Tempo estimado**: 5 minutos

**O que fazer:**
1. Hosting → Get started
2. Seguir wizard de configuração
3. Instalar Firebase CLI: `npm install -g firebase-tools`
4. Deploy: `firebase deploy --only hosting`

**Benefícios:**
- URL permanente: `theraflow-app-83126.web.app`
- SSL automático
- CDN global
- Alternativa ao GitHub Pages

**Nota**: GitHub Pages já está configurado via Actions

---

## 🐙 GitHub Console

Acesse: https://github.com/settings/developers

### 6️⃣ Criar OAuth App

**Status**: ⚠️ Pendente (depende do item 1️⃣)  
**Prioridade**: Alta  
**Tempo estimado**: 5 minutos

**O que fazer:**
1. Settings → Developer settings → OAuth Apps
2. New OAuth App
3. Preencher:
   - **Name**: TheraFlow
   - **Homepage**: `https://theraflow-app-83126.web.app`
   - **Callback URL**: Copiar do Firebase (item 1️⃣)
4. Copiar Client ID e Secret
5. Colar no Firebase Console

**Guia completo**: [GITHUB_OAUTH_SETUP.md](GITHUB_OAUTH_SETUP.md)

---

### 7️⃣ Habilitar GitHub Pages (Opcional)

**Status**: ✅ Parcialmente configurado  
**Prioridade**: Baixa  
**Tempo estimado**: 2 minutos

**O que fazer:**
1. Repository → Settings → Pages
2. Source: **GitHub Actions**
3. Aguardar deploy automático

**Nota**: Workflow já configurado em [.github/workflows/deploy.yml](.github/workflows/deploy.yml)

---

## 🔐 Segurança

### 8️⃣ Revisar Configurações de Segurança

**Status**: 📋 Recomendado  
**Prioridade**: Média  
**Tempo estimado**: 10 minutos

**Firebase Console:**
- [ ] Verificar domínios autorizados (Authentication → Settings → Authorized domains)
- [ ] Revisar quotas (Usage and billing)
- [ ] Configurar alertas de uso

**GitHub:**
- [ ] Habilitar 2FA na conta
- [ ] Revisar webhooks
- [ ] Configurar branch protection rules

---

## 📊 Monitoramento

### 9️⃣ Configurar Monitoramento (Opcional)

**Status**: 📋 Futuro  
**Prioridade**: Baixa  

**Sugestões:**
- Firebase Analytics (grátis)
- Firebase Crashlytics (erros)
- Firebase Performance Monitoring

---

## ✅ Checklist Rápido

### Configurações CRÍTICAS (Fazer AGORA)
- [ ] **2️⃣ Publicar regras do Firestore** ⚠️ CRÍTICO
- [ ] **1️⃣ Configurar GitHub OAuth** (se quiser login com GitHub)

### Configurações IMPORTANTES (Esta Semana)
- [ ] **3️⃣ Baixar google-services.json** (se for usar Android)
- [ ] **6️⃣ Criar OAuth App no GitHub**

### Configurações OPCIONAIS (Quando Precisar)
- [ ] 4️⃣ Configurar App iOS
- [ ] 5️⃣ Ativar Firebase Hosting
- [ ] 7️⃣ Habilitar GitHub Pages
- [ ] 8️⃣ Revisar segurança
- [ ] 9️⃣ Configurar monitoramento

---

## 🆘 Precisa de Ajuda?

### Documentação Disponível
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Setup completo do Firebase
- [GITHUB_OAUTH_SETUP.md](GITHUB_OAUTH_SETUP.md) - Guia detalhado GitHub OAuth
- [GITHUB_FIREBASE.md](GITHUB_FIREBASE.md) - Como funcionam juntos
- [README.md](README.md) - Visão geral do projeto

### Guias Oficiais
- [Firebase Console](https://console.firebase.google.com)
- [Firebase Docs](https://firebase.google.com/docs)
- [GitHub OAuth](https://docs.github.com/en/developers/apps/building-oauth-apps)

---

## 📝 Após Completar as Configurações

Quando terminar:
1. Marque os itens como concluídos neste arquivo
2. Teste o app completamente
3. Faça commit das mudanças necessárias
4. Atualize a documentação se necessário

---

## 🧪 Como Testar

Após configurar:

```powershell
# 1. Testar Web
flutter run -d chrome

# 2. Testar login com email
# 3. Testar login com GitHub
# 4. Criar cliente
# 5. Criar sessão
# 6. Verificar dados no Firestore Console
```

---

**Última atualização**: 19/01/2026  
**Próxima revisão**: Após completar itens críticos
