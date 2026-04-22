# Integration tests — TheraFlow

Testes de integração que rodam o app real numa device/emulator. Diferente
dos `flutter test` (unit/widget), aqui o Firebase, sqflite e a árvore de
widgets completa são exercitados.

## Rodar smoke test

```bash
flutter test integration_test/app_smoke_test.dart
```

Em desktop o sqflite usa FFI; em web é necessário um Chrome instalado:

```bash
flutter test --platform chrome integration_test/app_smoke_test.dart
```

## Próximo passo: usar o Firebase Emulator Suite

Para testar fluxos de Auth e Firestore sem tocar o projeto de produção:

1. Instale: `npm install -g firebase-tools`
2. Inicie: `firebase emulators:start --only auth,firestore`
3. No `setUpAll` do teste, aponte para o emulator antes do
   `Firebase.initializeApp`:

   ```dart
   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
   ```

4. Crie testes que cubram: signup → onboarding → criar cliente →
   criar sessão → marcar pago → relatório financeiro.

Referência: <https://firebase.google.com/docs/emulator-suite>
