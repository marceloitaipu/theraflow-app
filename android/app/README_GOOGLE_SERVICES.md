# ⚠️ IMPORTANTE - Leia Antes de Usar Android

## 🔴 Arquivo Necessário: google-services.json

Para o app funcionar no **Android**, você precisa adicionar o arquivo de configuração do Firebase.

### ❌ O que está faltando

```
android/app/google-services.json  ← ARQUIVO NÃO ENCONTRADO
```

### ✅ Como Adicionar

#### 1️⃣ Baixar do Firebase Console

1. Acesse: https://console.firebase.google.com
2. Selecione o projeto: **theraflow-app-83126**
3. Clique na engrenagem ⚙️ → **Project Settings**
4. Role até a seção **"Your apps"**

#### 2️⃣ Registrar App Android (se ainda não existe)

Se você não vê um app Android listado:

1. Clique em **"Add app"** → Ícone do Android
2. Preencha:
   - **Android package name**: `com.theraflow.app`
   - **App nickname**: `TheraFlow Android` (opcional)
   - **Debug signing certificate SHA-1**: (deixe em branco por enquanto)
3. Clique em **"Register app"**

#### 3️⃣ Baixar o Arquivo

1. Clique em **"Download google-services.json"**
2. **NÃO modifique o arquivo!**

#### 4️⃣ Salvar no Projeto

Coloque o arquivo aqui:
```
android/app/google-services.json
```

**Estrutura correta:**
```
android/
├── app/
│   ├── build.gradle.kts
│   ├── google-services.json  ← AQUI
│   └── src/
```

### 🔧 Plugin Já Configurado

✅ O plugin do Google Services já está no `build.gradle.kts`:
```kotlin
id("com.google.gms.google-services")
```

Você só precisa adicionar o arquivo JSON!

### 🧪 Testar

Após adicionar o arquivo:

```powershell
# Limpar build anterior
flutter clean

# Reconstruir
flutter pub get

# Executar no Android
flutter run
```

### 🔒 Segurança

**Posso commitar no Git?**
- ⚠️ **Depende**: Por padrão está seguro
- ✅ O arquivo só funciona com o bundle ID configurado
- 🔐 Para maior segurança, adicione ao `.gitignore`

No arquivo `.gitignore`, você pode descomentar:
```gitignore
# android/app/google-services.json
```

### ❓ FAQ

**Q: O app funciona no Web sem esse arquivo?**  
A: ✅ Sim! Web usa o `firebase_options.dart`

**Q: Preciso disso para iOS?**  
A: Não, iOS usa `GoogleService-Info.plist`

**Q: Onde consigo ajuda?**  
A: Veja [FIREBASE_SETUP.md](../FIREBASE_SETUP.md)

---

**Status**: ⚠️ Arquivo pendente  
**Prioridade**: Alta (se for usar Android)  
**Tempo**: 5 minutos
