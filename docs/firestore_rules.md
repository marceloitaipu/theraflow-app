# 🔐 Firestore Security Rules

Este arquivo contém as regras de segurança para o Firestore do TheraFlow.

## Como aplicar as regras

### Via Firebase Console
1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Selecione seu projeto
3. Vá em **Firestore Database** → **Rules**
4. Copie o conteúdo do arquivo `firestore.rules`
5. Clique em **Publish**

### Via Firebase CLI
```bash
firebase deploy --only firestore:rules
```

## Regras Implementadas

### ✅ Autenticação Obrigatória
Todas as operações exigem que o usuário esteja autenticado.

### ✅ Isolamento por Usuário
- Cada usuário só pode acessar seus próprios dados
- Estrutura: `users/{userId}/clientes`, `users/{userId}/sessions`, etc.

### ✅ Validação de Limites
- **Free**: máximo 5 clientes
- **Professional**: máximo 50 clientes  
- **Premium**: ilimitado

### ✅ Coleções Protegidas
- `users/{userId}` - dados do usuário
- `users/{userId}/clients` - clientes do usuário
- `users/{userId}/sessions` - sessões do usuário
- `users/{userId}/payments` - pagamentos do usuário

## Estrutura de Dados

```
users/{userId}
├── name: string
├── email: string
├── plan: "free" | "professional" | "premium"
├── onboardingCompleted: boolean
├── createdAt: timestamp
└── subcollections:
    ├── clients/
    ├── sessions/
    └── payments/
```

## Testando as Regras

### No Firebase Console
1. Vá em **Firestore Database** → **Rules**
2. Clique em **Rules Playground**
3. Teste operações de leitura/escrita

### Exemplos de Testes

**✅ Permitido - Usuário lê seus próprios dados:**
```
Location: /users/user123
Type: get
Auth: { uid: "user123" }
Result: Allow
```

**❌ Negado - Usuário tenta ler dados de outro:**
```
Location: /users/user456
Type: get
Auth: { uid: "user123" }
Result: Deny
```

**✅ Permitido - Criação de cliente (dentro do limite):**
```
Location: /users/user123/clients/client1
Type: create
Auth: { uid: "user123" }
Data: { name: "Cliente A", phone: "123456789" }
Result: Allow (se < 5 clientes no plano Free)
```

## ⚠️ Importante

- As regras são aplicadas no servidor Firebase
- **NÃO** confie apenas em validações client-side
- Sempre teste as regras antes de publicar
- Mantenha backups das regras anteriores

## Melhorias Futuras

1. **Rate Limiting**: adicionar limites de requisições
2. **Validação de Campos**: verificar tipos e valores obrigatórios
3. **Auditoria**: registrar operações sensíveis
4. **Compartilhamento**: permitir que clientes acessem suas próprias sessões
