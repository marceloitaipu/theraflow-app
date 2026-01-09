/**
 * TheraFlow - Validação Automatizada via Console
 * Execute este script no console do navegador para validar o app
 * 
 * Uso: Abra qualquer página do TheraFlow e cole este código no console
 */

(function() {
    'use strict';
    
    console.log('%c🧪 TheraFlow Validation Suite', 'font-size: 20px; font-weight: bold; color: #667eea;');
    console.log('%cExecutando validação automatizada...', 'color: #666;');
    console.log('');
    
    var results = {
        pass: 0,
        fail: 0,
        tests: []
    };
    
    function test(name, condition, details) {
        var passed = !!condition;
        results.tests.push({ name: name, passed: passed, details: details });
        if (passed) {
            results.pass++;
            console.log('%c✅ ' + name + (details ? ' (' + details + ')' : ''), 'color: #059669;');
        } else {
            results.fail++;
            console.log('%c❌ ' + name + (details ? ' (' + details + ')' : ''), 'color: #dc2626;');
        }
        return passed;
    }
    
    function section(title) {
        console.log('');
        console.log('%c' + title, 'font-weight: bold; font-size: 14px; color: #667eea;');
        console.log('%c' + '─'.repeat(50), 'color: #ccc;');
    }
    
    // ========================================
    // VALIDAÇÕES
    // ========================================
    
    section('🔧 1. Data Layer - TheraFlowData');
    test('TheraFlowData está definido', typeof TheraFlowData === 'object');
    test('getClients() funciona', typeof TheraFlowData.getClients === 'function');
    test('getSessions() funciona', typeof TheraFlowData.getSessions === 'function');
    test('getPackages() funciona', typeof TheraFlowData.getPackages === 'function');
    test('getProfile() funciona', typeof TheraFlowData.getProfile === 'function');
    
    section('👥 2. Clientes');
    var clients = TheraFlowData.getClients();
    test('Lista de clientes é array', Array.isArray(clients), clients.length + ' clientes');
    test('Clientes têm ID', clients.length === 0 || clients[0].hasOwnProperty('id'));
    test('Clientes têm nome', clients.length === 0 || clients[0].hasOwnProperty('nome'));
    
    section('📅 3. Sessões');
    var sessions = TheraFlowData.getSessions();
    test('Lista de sessões é array', Array.isArray(sessions), sessions.length + ' sessões');
    test('Sessões têm estrutura correta', sessions.length === 0 || (sessions[0].data && sessions[0].hora));
    test('getTodaySessions() funciona', Array.isArray(TheraFlowData.getTodaySessions()));
    test('getTomorrowSessions() funciona', Array.isArray(TheraFlowData.getTomorrowSessions()));
    test('getNext7DaysSessions() funciona', Array.isArray(TheraFlowData.getNext7DaysSessions()));
    
    section('📦 4. Pacotes');
    var packages = TheraFlowData.getPackages();
    test('Lista de pacotes é array', Array.isArray(packages), packages.length + ' pacotes');
    test('getPackagesByClient() funciona', typeof TheraFlowData.getPackagesByClient === 'function');
    test('getActivePackagesByClient() funciona', typeof TheraFlowData.getActivePackagesByClient === 'function');
    test('usePackageSession() funciona', typeof TheraFlowData.usePackageSession === 'function');
    
    section('💰 5. Financeiro');
    test('getFinanceReport() existe', typeof TheraFlowData.getFinanceReport === 'function');
    test('getSmartFinanceReport() existe', typeof TheraFlowData.getSmartFinanceReport === 'function');
    
    var smartReport = TheraFlowData.getSmartFinanceReport();
    test('Relatório inteligente tem receivedThisMonth', typeof smartReport.receivedThisMonth === 'number');
    test('Relatório inteligente tem pendingThisMonth', typeof smartReport.pendingThisMonth === 'number');
    test('Relatório inteligente tem next7Days', typeof smartReport.next7Days === 'number');
    test('Relatório inteligente tem growthPercent', typeof smartReport.growthPercent === 'number');
    test('Relatório inteligente tem prevMonthReceived', typeof smartReport.prevMonthReceived === 'number');
    
    section('📈 6. Indicadores de Progresso');
    test('getProgressIndicators() existe', typeof TheraFlowData.getProgressIndicators === 'function');
    
    var indicators = TheraFlowData.getProgressIndicators();
    test('Indicadores têm sessionsThisMonth', typeof indicators.sessionsThisMonth === 'number');
    test('Indicadores têm activeClients', typeof indicators.activeClients === 'number');
    test('Indicadores têm noShowRate', typeof indicators.noShowRate === 'number');
    test('Indicadores têm bestMonth', indicators.hasOwnProperty('bestMonth'));
    test('Indicadores têm monthlyAverage', typeof indicators.monthlyAverage === 'number');
    
    section('🔔 7. Alertas Inteligentes');
    test('getSmartAlerts() existe', typeof TheraFlowData.getSmartAlerts === 'function');
    
    var alerts = TheraFlowData.getSmartAlerts();
    test('Alertas retorna array', Array.isArray(alerts), alerts.length + ' alertas');
    if (alerts.length > 0) {
        test('Alertas têm type', alerts[0].hasOwnProperty('type'));
        test('Alertas têm priority', alerts[0].hasOwnProperty('priority'));
        test('Alertas têm title', alerts[0].hasOwnProperty('title'));
    }
    
    section('⏳ 8. Timeline do Cliente');
    test('getClientTimeline() existe', typeof TheraFlowData.getClientTimeline === 'function');
    
    if (clients.length > 0) {
        var timeline = TheraFlowData.getClientTimeline(clients[0].id);
        test('Timeline retorna objeto', typeof timeline === 'object');
        test('Timeline tem totalSessions', typeof timeline.totalSessions === 'number');
        test('Timeline tem avgValue', typeof timeline.avgValue === 'number');
        test('Timeline tem avgFrequencyDays', typeof timeline.avgFrequencyDays === 'number');
        test('Timeline tem noShowRate', typeof timeline.noShowRate === 'number');
        test('Timeline tem sessions array', Array.isArray(timeline.sessions));
    }
    
    section('▶️ 9. Fluxo Iniciar/Finalizar Sessão');
    test('startSession() existe', typeof TheraFlowData.startSession === 'function');
    test('finishSession() existe', typeof TheraFlowData.finishSession === 'function');
    
    section('🚫 10. Limites de Plano');
    test('getUserPlan() existe', typeof TheraFlowData.getUserPlan === 'function');
    test('checkPlanLimits() existe', typeof TheraFlowData.checkPlanLimits === 'function');
    
    var limits = TheraFlowData.checkPlanLimits();
    test('Limites têm plan', limits.hasOwnProperty('plan'));
    test('Limites têm clientLimit', typeof limits.clientLimit === 'number');
    test('Limites têm isAtLimit', typeof limits.isAtLimit === 'boolean');
    test('Limites têm usagePercent', typeof limits.usagePercent === 'number');
    test('Plano Free tem limite 5', limits.plan === 'free' && limits.clientLimit === 5);
    
    section('🎨 11. UI Components - TheraFlowUI');
    test('TheraFlowUI está definido', typeof TheraFlowUI === 'object');
    test('showModal() existe', typeof TheraFlowUI.showModal === 'function');
    test('closeModal() existe', typeof TheraFlowUI.closeModal === 'function');
    test('toast() existe', typeof TheraFlowUI.toast === 'function');
    test('confirm() existe', typeof TheraFlowUI.confirm === 'function');
    test('formatCurrency() existe', typeof TheraFlowUI.formatCurrency === 'function');
    test('formatDateBR() existe', typeof TheraFlowUI.formatDateBR === 'function');
    test('exportToCSV() existe', typeof TheraFlowUI.exportToCSV === 'function');
    test('generatePDFReport() existe', typeof TheraFlowUI.generatePDFReport === 'function');
    
    section('💬 12. Mensagens Contextuais');
    test('contextualMessages existe', TheraFlowUI.hasOwnProperty('contextualMessages'));
    test('getContextualMessage() existe', typeof TheraFlowUI.getContextualMessage === 'function');
    test('showContextualToast() existe', typeof TheraFlowUI.showContextualToast === 'function');
    test('showUpgradeModal() existe', typeof TheraFlowUI.showUpgradeModal === 'function');
    
    var msg = TheraFlowUI.getContextualMessage('greetings');
    test('Mensagens contextuais retornam string', typeof msg === 'string' && msg.length > 0, msg);
    
    section('📄 13. Exportação');
    test('generateMonthlyReport() existe', typeof TheraFlowData.generateMonthlyReport === 'function');
    
    var now = new Date();
    var report = TheraFlowData.generateMonthlyReport(now.getFullYear(), now.getMonth() + 1);
    test('Relatório mensal tem period', typeof report.period === 'string');
    test('Relatório mensal tem totalReceived', typeof report.totalReceived === 'number');
    test('Relatório mensal tem sessions', Array.isArray(report.sessions));
    test('Relatório mensal tem uniqueClientsAttended', typeof report.uniqueClientsAttended === 'number');
    
    // ========================================
    // RESUMO
    // ========================================
    console.log('');
    console.log('%c═══════════════════════════════════════════════════════', 'color: #667eea;');
    console.log('%c📊 RESUMO DA VALIDAÇÃO', 'font-size: 16px; font-weight: bold; color: #667eea;');
    console.log('%c═══════════════════════════════════════════════════════', 'color: #667eea;');
    
    var total = results.pass + results.fail;
    var percentage = total > 0 ? Math.round((results.pass / total) * 100) : 0;
    
    console.log('');
    console.log('%c✅ Passou: ' + results.pass, 'color: #059669; font-size: 14px;');
    console.log('%c❌ Falhou: ' + results.fail, 'color: #dc2626; font-size: 14px;');
    console.log('%c📝 Total: ' + total, 'color: #666; font-size: 14px;');
    console.log('%c📈 Cobertura: ' + percentage + '%', 'font-weight: bold; font-size: 14px; color: ' + (percentage >= 90 ? '#059669' : percentage >= 70 ? '#d97706' : '#dc2626') + ';');
    console.log('');
    
    if (results.fail === 0) {
        console.log('%c🎉 TODOS OS TESTES PASSARAM!', 'font-size: 18px; font-weight: bold; color: #059669;');
    } else {
        console.log('%c⚠️ ALGUNS TESTES FALHARAM', 'font-size: 18px; font-weight: bold; color: #dc2626;');
        console.log('%cTestes que falharam:', 'color: #dc2626;');
        results.tests.filter(function(t) { return !t.passed; }).forEach(function(t) {
            console.log('%c  • ' + t.name, 'color: #dc2626;');
        });
    }
    
    console.log('');
    console.log('%cPara testes mais detalhados, abra: tests/test-suite.html', 'color: #666; font-style: italic;');
    
    // Retornar resultados para uso programático
    return {
        passed: results.pass,
        failed: results.fail,
        total: total,
        percentage: percentage,
        allPassed: results.fail === 0,
        tests: results.tests
    };
})();
