# TheraFlow — Starter (Flutter + Firebase-ready)

Este pacote é um **starter executável** para você iniciar o TheraFlow com Flutter.
Ele vem com:
- Estrutura de telas do MVP (Login, Home/Agenda do dia, Agenda, Clientes, Cliente Detalhe, Sessão, Financeiro, Perfil/Plano)
- Navegação (routes)
- Modelos e serviços (Firestore placeholders)
- Onboarding (wizard simples no primeiro acesso)
- Documentos: fluxos/wireframes, backlog detalhado, copy de landing page e posicionamento

## 1) Pré-requisitos
- Flutter instalado (canal estável)
- Android Studio ou VS Code com Flutter/Dart
- Conta Firebase

## 2) Criar o projeto Flutter e copiar os arquivos deste starter
No seu terminal:

```bash
flutter create theraflow_app
cd theraflow_app
```

Agora copie as pastas/arquivos deste starter para dentro do projeto criado:
- Substitua a pasta `lib/`
- Copie a pasta `docs/`
- Mescle o `pubspec.yaml` (adicione as dependências listadas abaixo)

### Dependências sugeridas (pubspec.yaml)
Adicione em `dependencies:`:

```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_messaging: ^15.0.0
firebase_storage: ^12.0.0
go_router: ^14.0.0
intl: ^0.19.0
```

> Observação: versões podem variar. Ajuste conforme seu `flutter pub get`.

Depois:

```bash
flutter pub get
```

## 3) Configurar Firebase
- Crie um projeto no Firebase
- Adicione Android e iOS
- Para Android, defina `applicationId` (ex.: `com.theraflow.app`)
- Rode o FlutterFire CLI (recomendado):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Isso criará `lib/firebase_options.dart` no seu projeto real.

No starter, existe um arquivo placeholder em `lib/firebase_options.dart` para você substituir.

## 4) Executar
```bash
flutter run
```

## 5) Próximos passos recomendados
1. Implementar Auth real (FirebaseAuth) no `AuthService`
2. Implementar persistência no Firestore (Clients/Sessions/Payments)
3. Ajustar UI/UX (cores, ícones, etc.)
4. Implementar notificações (lembretes) com FCM + Cloud Functions

---
© TheraFlow (starter gerado para uso inicial do projeto)
