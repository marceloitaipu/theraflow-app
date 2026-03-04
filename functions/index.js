const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function: Validar compra e atualizar status de assinatura
 * 
 * Chamada quando o app envia o receipt/token de compra do Google Play ou App Store
 * 
 * @param {object} data - Dados da requisição
 * @param {string} data.platform - 'android' ou 'ios'
 * @param {string} data.purchaseToken - Token de compra (Android) ou receipt (iOS)
 * @param {string} data.productId - ID do produto/SKU
 * @param {object} context - Contexto da função (contém auth)
 */
exports.validateSubscription = functions.https.onCall(async (data, context) => {
  // Verificar autenticação
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Usuário não autenticado'
    );
  }

  const userId = context.auth.uid;
  const { platform, purchaseToken, productId } = data;

  // Validar parâmetros
  if (!platform || !purchaseToken || !productId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Parâmetros obrigatórios ausentes'
    );
  }

  try {
    console.log(`Validando assinatura: userId=${userId}, platform=${platform}, productId=${productId}`);

    // TODO: Implementar validação real com Google Play Billing ou App Store
    // Por enquanto, apenas simular validação
    
    let subscriptionData;
    
    if (platform === 'android') {
      // subscriptionData = await validateGooglePlaySubscription(purchaseToken, productId);
      subscriptionData = {
        isValid: true,
        expiryDate: Date.now() + 30 * 24 * 60 * 60 * 1000, // 30 dias
        autoRenewing: true
      };
    } else if (platform === 'ios') {
      // subscriptionData = await validateAppStoreSubscription(purchaseToken);
      subscriptionData = {
        isValid: true,
        expiryDate: Date.now() + 30 * 24 * 60 * 60 * 1000, // 30 dias
        autoRenewing: true
      };
    } else {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Plataforma inválida'
      );
    }

    if (!subscriptionData.isValid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Assinatura inválida'
      );
    }

    // Mapear productId para planId
    const planMapping = {
      'theraflow_professional_monthly': 'professional',
      'theraflow_premium_monthly': 'premium',
      'theraflow_professional_yearly': 'professional',
      'theraflow_premium_yearly': 'premium'
    };

    const planId = planMapping[productId] || 'free';

    // Atualizar documento do usuário no Firestore
    const userRef = db.collection('users').doc(userId);
    await userRef.set({
      subscriptionStatus: 'active',
      planId: planId,
      currentPeriodEnd: new Date(subscriptionData.expiryDate),
      autoRenewing: subscriptionData.autoRenewing,
      lastValidatedAt: admin.firestore.FieldValue.serverTimestamp(),
      purchaseToken: purchaseToken,
      platform: platform,
      productId: productId
    }, { merge: true });

    console.log(`Assinatura validada com sucesso: userId=${userId}, planId=${planId}`);

    return {
      success: true,
      planId: planId,
      expiryDate: subscriptionData.expiryDate,
      subscriptionStatus: 'active'
    };

  } catch (error) {
    console.error('Erro ao validar assinatura:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Erro ao validar assinatura',
      error.message
    );
  }
});

/**
 * Cloud Function: Verificar limites do plano ao criar cliente
 * 
 * Trigger: Antes de criar documento em /users/{userId}/clients/{clientId}
 */
exports.checkClientLimit = functions.firestore
  .document('users/{userId}/clients/{clientId}')
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    
    try {
      // Buscar dados do usuário
      const userDoc = await db.collection('users').doc(userId).get();
      const userData = userDoc.data();
      
      if (!userData) {
        console.error(`Usuário ${userId} não encontrado`);
        return;
      }

      const planId = userData.planId || 'free';
      const subscriptionStatus = userData.subscriptionStatus || 'inactive';

      // Limites por plano
      const limits = {
        free: 5,
        professional: 50,
        premium: Infinity
      };

      const limit = limits[planId] || limits.free;

      // Contar clientes existentes (excluindo soft deletes)
      const clientsSnapshot = await db.collection('users')
        .doc(userId)
        .collection('clients')
        .where('deletedAt', '==', null)
        .get();

      const clientCount = clientsSnapshot.size;

      console.log(`Verificação de limite: userId=${userId}, planId=${planId}, count=${clientCount}, limit=${limit}`);

      // Se exceder limite e assinatura não estiver ativa, deletar documento e notificar
      if (clientCount > limit && subscriptionStatus !== 'active') {
        console.warn(`Limite excedido: userId=${userId}, planId=${planId}, count=${clientCount}, limit=${limit}`);
        
        // Deletar o documento recém-criado
        await snap.ref.delete();
        
        // Registrar tentativa de violação
        await db.collection('users').doc(userId).collection('violations').add({
          type: 'client_limit_exceeded',
          planId: planId,
          limit: limit,
          attempted: clientCount,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`Cliente removido: limite de ${limit} excedido`);
      }

    } catch (error) {
      console.error('Erro ao verificar limite de clientes:', error);
    }
  });

/**
 * Cloud Function: Verificar expiração de assinaturas (executar diariamente)
 * 
 * Cron job que verifica assinaturas expiradas e atualiza status
 */
exports.checkExpiredSubscriptions = functions.pubsub
  .schedule('0 0 * * *') // Executar todo dia à meia-noite
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('Iniciando verificação de assinaturas expiradas');

    try {
      const now = admin.firestore.Timestamp.now();
      
      // Buscar usuários com assinatura ativa mas período expirado
      const usersSnapshot = await db.collection('users')
        .where('subscriptionStatus', '==', 'active')
        .where('currentPeriodEnd', '<', now)
        .get();

      console.log(`Encontradas ${usersSnapshot.size} assinaturas expiradas`);

      const batch = db.batch();
      let updateCount = 0;

      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        
        // Verificar se não está com renovação automática
        if (!userData.autoRenewing) {
          batch.update(doc.ref, {
            subscriptionStatus: 'expired',
            planId: 'free',
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          updateCount++;
          console.log(`Assinatura expirada: userId=${doc.id}`);
        }
      });

      if (updateCount > 0) {
        await batch.commit();
        console.log(`${updateCount} assinaturas atualizadas para expiradas`);
      }

      return { updated: updateCount };

    } catch (error) {
      console.error('Erro ao verificar assinaturas expiradas:', error);
      throw error;
    }
  });

/**
 * Cloud Function: Notificar app sobre mudanças na assinatura
 * 
 * Trigger: Quando o documento do usuário é atualizado
 */
exports.onSubscriptionChange = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const userId = context.params.userId;

    // Verificar se houve mudança no status da assinatura
    if (before.subscriptionStatus !== after.subscriptionStatus ||
        before.planId !== after.planId) {
      
      console.log(`Mudança de assinatura detectada: userId=${userId}, ` +
                  `status=${before.subscriptionStatus}->${after.subscriptionStatus}, ` +
                  `plan=${before.planId}->${after.planId}`);

      // TODO: Enviar notificação push para o app
      // TODO: Enviar email de notificação
      
      // Registrar evento de auditoria
      await db.collection('users').doc(userId).collection('subscription_history').add({
        previousStatus: before.subscriptionStatus,
        newStatus: after.subscriptionStatus,
        previousPlan: before.planId,
        newPlan: after.planId,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    return null;
  });
