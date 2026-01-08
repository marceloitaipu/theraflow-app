/**
 * TheraFlow - Script de Validação das Melhorias Essenciais
 * Execute no console do navegador após abrir qualquer página do demo-web
 */

(function() {
    console.log('🧪 === THERAFLOW - VALIDAÇÃO DAS MELHORIAS ===\n');
    
    var passed = 0;
    var failed = 0;
    
    function test(name, condition, details) {
        if (condition) {
            console.log('✅ ' + name + (details ? ' (' + details + ')' : ''));
            passed++;
        } else {
            console.log('❌ ' + name + (details ? ' (' + details + ')' : ''));
            failed++;
        }
    }
    
    // Inicializar dados
    if (typeof TheraFlowData === 'undefined') {
        console.log('❌ ERRO: TheraFlowData não encontrado. Abra uma página do demo-web primeiro.');
        return;
    }
    
    console.log('\n📊 1. RESUMO FINANCEIRO INTELIGENTE');
    console.log('-'.repeat(40));
    
    test('getSmartFinanceReport existe', typeof TheraFlowData.getSmartFinanceReport === 'function');
    test('getNext7DaysSessions existe', typeof TheraFlowData.getNext7DaysSessions === 'function');
    
    if (typeof TheraFlowData.getSmartFinanceReport === 'function') {
        var smartReport = TheraFlowData.getSmartFinanceReport();
        test('Retorna receivedThisMonth', smartReport.hasOwnProperty('receivedThisMonth'), 'R$ ' + smartReport.receivedThisMonth);
        test('Retorna pendingThisMonth', smartReport.hasOwnProperty('pendingThisMonth'), 'R$ ' + smartReport.pendingThisMonth);
        test('Retorna next7Days', smartReport.hasOwnProperty('next7Days'), 'R$ ' + smartReport.next7Days);
    }
    
    console.log('\n📦 2. SISTEMA DE PACOTES');
    console.log('-'.repeat(40));
    
    test('getPackages existe', typeof TheraFlowData.getPackages === 'function');
    test('addPackage existe', typeof TheraFlowData.addPackage === 'function');
    test('usePackageSession existe', typeof TheraFlowData.usePackageSession === 'function');
    test('getActivePackagesByClient existe', typeof TheraFlowData.getActivePackagesByClient === 'function');
    
    // Testar criação de pacote
    var clients = TheraFlowData.getClients();
    if (clients.length > 0 && typeof TheraFlowData.addPackage === 'function') {
        var testPkg = TheraFlowData.addPackage({
            clienteId: clients[0].id,
            clienteNome: clients[0].nome,
            nome: 'Pacote Teste',
            sessoesTotal: 3,
            valorTotal: 300
        });
        test('Criar pacote funciona', testPkg && testPkg.id, 'ID: ' + (testPkg ? testPkg.id : 'N/A'));
        test('Sessões iniciais corretas', testPkg && testPkg.sessoesRestantes === 3, testPkg ? testPkg.sessoesRestantes + ' sessões' : 'N/A');
        
        if (testPkg) {
            var usedPkg = TheraFlowData.usePackageSession(testPkg.id);
            test('Usar sessão funciona', usedPkg && usedPkg.sessoesRestantes === 2, usedPkg ? usedPkg.sessoesRestantes + ' restantes' : 'N/A');
        }
    }
    
    console.log('\n🔔 3. LEMBRETES E CONFIRMAÇÃO');
    console.log('-'.repeat(40));
    
    test('getTomorrowSessions existe', typeof TheraFlowData.getTomorrowSessions === 'function');
    test('addReminder existe', typeof TheraFlowData.addReminder === 'function');
    test('updateSession existe', typeof TheraFlowData.updateSession === 'function');
    
    if (typeof TheraFlowData.getTomorrowSessions === 'function') {
        var tomorrow = TheraFlowData.getTomorrowSessions();
        test('getTomorrowSessions retorna array', Array.isArray(tomorrow), tomorrow.length + ' sessões');
    }
    
    console.log('\n🚫 4. LIMITES DO PLANO FREE');
    console.log('-'.repeat(40));
    
    test('checkPlanLimits existe', typeof TheraFlowData.checkPlanLimits === 'function');
    test('getUserPlan existe', typeof TheraFlowData.getUserPlan === 'function');
    test('setUserPlan existe', typeof TheraFlowData.setUserPlan === 'function');
    
    if (typeof TheraFlowData.checkPlanLimits === 'function') {
        var limits = TheraFlowData.checkPlanLimits();
        test('Retorna plan', limits.hasOwnProperty('plan'), limits.plan);
        test('Retorna clientLimit', limits.hasOwnProperty('clientLimit'), limits.clientLimit);
        test('Retorna isAtLimit', limits.hasOwnProperty('isAtLimit'), limits.isAtLimit ? 'SIM' : 'NÃO');
        test('Retorna usagePercent', limits.hasOwnProperty('usagePercent'), limits.usagePercent + '%');
        test('Limite Free = 5', limits.plan === 'free' && limits.clientLimit === 5);
    }
    
    console.log('\n📄 5. EXPORTAR RELATÓRIO');
    console.log('-'.repeat(40));
    
    test('generateMonthlyReport existe', typeof TheraFlowData.generateMonthlyReport === 'function');
    
    if (typeof TheraFlowData.generateMonthlyReport === 'function') {
        var now = new Date();
        var report = TheraFlowData.generateMonthlyReport(now.getFullYear(), now.getMonth() + 1);
        test('Relatório contém totalReceived', report.hasOwnProperty('totalReceived'), 'R$ ' + report.totalReceived);
        test('Relatório contém sessionsCount', report.hasOwnProperty('sessionsCount'), report.sessionsCount);
        test('Relatório contém uniqueClientsAttended', report.hasOwnProperty('uniqueClientsAttended'), report.uniqueClientsAttended);
    }
    
    if (typeof TheraFlowUI !== 'undefined') {
        test('UI.exportToCSV existe', typeof TheraFlowUI.exportToCSV === 'function');
        test('UI.generatePDFReport existe', typeof TheraFlowUI.generatePDFReport === 'function');
    }
    
    console.log('\n🔒 6. BACKUP E SEGURANÇA');
    console.log('-'.repeat(40));
    
    test('Dados persistem (clientes)', TheraFlowData.getClients().length > 0, TheraFlowData.getClients().length + ' clientes');
    test('Dados persistem (sessões)', TheraFlowData.getSessions().length > 0, TheraFlowData.getSessions().length + ' sessões');
    test('Perfil existe', TheraFlowData.getProfile() && Object.keys(TheraFlowData.getProfile()).length > 0);
    test('resetData existe', typeof TheraFlowData.resetData === 'function');
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 RESULTADO FINAL');
    console.log('='.repeat(50));
    console.log('✅ Passou: ' + passed);
    console.log('❌ Falhou: ' + failed);
    console.log('📈 Taxa de sucesso: ' + Math.round(passed / (passed + failed) * 100) + '%');
    console.log('='.repeat(50));
    
    if (failed === 0) {
        console.log('\n🎉 TODOS OS TESTES PASSARAM! As melhorias estão funcionando corretamente.');
    } else {
        console.log('\n⚠️ Alguns testes falharam. Verifique as implementações.');
    }
    
    return { passed: passed, failed: failed, total: passed + failed };
})();
