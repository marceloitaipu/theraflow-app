/**
 * TheraFlow Demo - Gerenciador de Dados (LocalStorage)
 * Simula o comportamento do Firebase para testes
 * VERSÃO: 2026-01-13-FINAL
 */

var TheraFlowData = {
    version: '2026-01-13-FINAL',
    
    // Debug visual na tela
    showDebug: function(msg, isError) {
        console.log('[TheraFlow] ' + msg);
        // Criar badge de versão se não existir
        if (!document.getElementById('tf-debug-badge')) {
            var badge = document.createElement('div');
            badge.id = 'tf-debug-badge';
            badge.style.cssText = 'position:fixed;top:5px;right:5px;background:#10b981;color:white;padding:5px 10px;border-radius:15px;font-size:10px;z-index:99999;font-family:monospace;';
            badge.textContent = '✓';
            document.body.appendChild(badge);
            // Remover badge após 2 segundos
            setTimeout(function() { badge.style.opacity = '0.3'; }, 2000);
        }
    },
    
    // === INICIALIZAÇÃO ===
    init: function() {
        var self = this;
        // Esperar DOM carregar para mostrar debug
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() { self.showDebug('v5 carregado!'); });
        } else {
            this.showDebug('v5 carregado!');
        }
        
        console.log('[TheraFlow v' + this.version + '] Inicializando...');
        console.log('[TheraFlow] theraflow_initialized = ' + localStorage.getItem('theraflow_initialized'));
        
        // Só popula dados de demo se NUNCA foi inicializado
        // Uma vez que theraflow_initialized existe, NUNCA recria dados
        if (!localStorage.getItem('theraflow_initialized')) {
            console.log('[TheraFlow] Primeira inicialização - criando dados de demo');
            this.seedData();
            localStorage.setItem('theraflow_initialized', 'true');
        } else {
            console.log('[TheraFlow] Já inicializado - mantendo dados existentes');
            var clients = this.getClients();
            console.log('[TheraFlow] Clientes atuais: ' + clients.length);
        }
    },

    // Força limpeza de dados de negócio (chamado pelo perfil.html)
    clearBusinessData: function() {
        console.log('[TheraFlow] === LIMPANDO DADOS DE NEGÓCIO ===');
        console.log('[TheraFlow] Clientes ANTES: ' + this.getClients().length);
        
        localStorage.setItem('theraflow_clients', '[]');
        localStorage.setItem('theraflow_sessions', '[]');
        localStorage.setItem('theraflow_packages', '[]');
        localStorage.setItem('theraflow_initialized', 'true');
        
        console.log('[TheraFlow] Clientes DEPOIS: ' + this.getClients().length);
        console.log('[TheraFlow] === LIMPEZA CONCLUÍDA ===');
        return true;
    },

    // Força reset total (chamado pelo perfil.html)
    clearAllData: function() {
        console.log('[TheraFlow] === APAGANDO TUDO ===');
        console.log('[TheraFlow] Clientes ANTES: ' + this.getClients().length);
        
        localStorage.setItem('theraflow_clients', '[]');
        localStorage.setItem('theraflow_sessions', '[]');
        localStorage.setItem('theraflow_packages', '[]');
        localStorage.removeItem('theraflow_profile');
        localStorage.removeItem('theraflow_logged');
        localStorage.removeItem('theraflow_email');
        localStorage.removeItem('theraflow_onboarding');
        localStorage.setItem('theraflow_initialized', 'true');
        
        console.log('[TheraFlow] Clientes DEPOIS: ' + this.getClients().length);
        console.log('[TheraFlow] === TUDO APAGADO ===');
        return true;
    },

    seedData: function() {
        var hoje = new Date();
        var self = this;
        
        // Clientes de exemplo
        var clientes = [
            {id: 1, nome: 'Ana Paula Silva', email: 'ana.silva@email.com', telefone: '(11) 98765-4321', notas: 'Prefere horários pela manhã', sessoes: 23, createdAt: '2025-06-15'},
            {id: 2, nome: 'Carlos Henrique', email: 'carlos.h@email.com', telefone: '(11) 97654-3210', notas: 'Atleta, precisa de massagem desportiva', sessoes: 18, createdAt: '2025-07-20'},
            {id: 3, nome: 'Maria Oliveira', email: 'maria.oli@email.com', telefone: '(11) 96543-2109', notas: 'Gestante - 7 meses', sessoes: 31, createdAt: '2025-05-10'},
            {id: 4, nome: 'João Santos', email: 'joao.santos@email.com', telefone: '(11) 95432-1098', notas: 'Problema crônico no ombro direito', sessoes: 15, createdAt: '2025-08-05'},
            {id: 5, nome: 'Fernanda Costa', email: 'fe.costa@email.com', telefone: '(11) 94321-0987', notas: 'Cliente VIP - pacote mensal', sessoes: 42, createdAt: '2025-04-01'}
        ];
        localStorage.setItem('theraflow_clients', JSON.stringify(clientes));

        // Sessões de exemplo
        var sessoes = [
            {id: 1, clienteId: 1, clienteNome: 'Ana Paula Silva', data: self.formatDate(hoje), hora: '09:00', duracao: 60, tipo: 'Massagem Relaxante', valor: 120, status: 'confirmado', pagamento: 'pendente', notas: ''},
            {id: 2, clienteId: 2, clienteNome: 'Carlos Henrique', data: self.formatDate(hoje), hora: '10:30', duracao: 60, tipo: 'Massagem Desportiva', valor: 150, status: 'confirmado', pagamento: 'pendente', notas: ''},
            {id: 3, clienteId: 3, clienteNome: 'Maria Oliveira', data: self.formatDate(hoje), hora: '14:00', duracao: 90, tipo: 'Drenagem Linfática', valor: 180, status: 'confirmado', pagamento: 'pendente', notas: 'Cuidado extra - gestante'},
            {id: 4, clienteId: 4, clienteNome: 'João Santos', data: self.formatDate(hoje), hora: '16:00', duracao: 60, tipo: 'Shiatsu', valor: 140, status: 'realizado', pagamento: 'pago', notas: ''},
            {id: 5, clienteId: 5, clienteNome: 'Fernanda Costa', data: self.formatDate(hoje), hora: '18:00', duracao: 60, tipo: 'Massagem Relaxante', valor: 120, status: 'realizado', pagamento: 'pago', notas: ''},
            {id: 6, clienteId: 1, clienteNome: 'Ana Paula Silva', data: self.formatDate(self.addDays(hoje, 1)), hora: '10:00', duracao: 60, tipo: 'Massagem Relaxante', valor: 120, status: 'confirmado', pagamento: 'pendente', notas: ''},
            {id: 7, clienteId: 3, clienteNome: 'Maria Oliveira', data: self.formatDate(self.addDays(hoje, 1)), hora: '14:00', duracao: 90, tipo: 'Drenagem Linfática', valor: 180, status: 'confirmado', pagamento: 'pendente', notas: ''},
            {id: 8, clienteId: 2, clienteNome: 'Carlos Henrique', data: self.formatDate(self.addDays(hoje, 2)), hora: '09:00', duracao: 60, tipo: 'Massagem Desportiva', valor: 150, status: 'confirmado', pagamento: 'pendente', notas: ''},
            {id: 9, clienteId: 5, clienteNome: 'Fernanda Costa', data: self.formatDate(self.addDays(hoje, 3)), hora: '11:00', duracao: 60, tipo: 'Reflexologia', valor: 90, status: 'confirmado', pagamento: 'pendente', notas: ''},
            {id: 10, clienteId: 1, clienteNome: 'Ana Paula Silva', data: self.formatDate(self.addDays(hoje, -3)), hora: '10:00', duracao: 60, tipo: 'Massagem Relaxante', valor: 120, status: 'realizado', pagamento: 'pago', notas: 'Excelente sessão'},
            {id: 11, clienteId: 2, clienteNome: 'Carlos Henrique', data: self.formatDate(self.addDays(hoje, -5)), hora: '14:00', duracao: 60, tipo: 'Massagem Desportiva', valor: 150, status: 'realizado', pagamento: 'pago', notas: ''},
            {id: 12, clienteId: 3, clienteNome: 'Maria Oliveira', data: self.formatDate(self.addDays(hoje, -7)), hora: '09:00', duracao: 90, tipo: 'Drenagem Linfática', valor: 180, status: 'realizado', pagamento: 'pendente', notas: ''}
        ];
        localStorage.setItem('theraflow_sessions', JSON.stringify(sessoes));

        // Perfil padrão
        var profile = {
            nome: 'Terapeuta',
            displayName: 'Terapeuta',
            email: 'terapeuta@theraflow.com',
            telefone: '(11) 99999-9999',
            especialidade: 'Massoterapia',
            duracaoPadrao: 60,
            servicos: ['Massagem Relaxante', 'Massagem Desportiva', 'Drenagem Linfática', 'Shiatsu', 'Reiki', 'Reflexologia'],
            createdAt: self.formatDate(new Date())
        };
        localStorage.setItem('theraflow_profile', JSON.stringify(profile));
    },

    // === HELPERS ===
    formatDate: function(date) {
        var d = new Date(date);
        var year = d.getFullYear();
        var month = String(d.getMonth() + 1).padStart(2, '0');
        var day = String(d.getDate()).padStart(2, '0');
        return year + '-' + month + '-' + day;
    },

    addDays: function(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    },

    _lastId: 0,
    generateId: function() {
        var newId = Date.now();
        if (newId <= this._lastId) {
            newId = this._lastId + 1;
        }
        this._lastId = newId;
        return newId;
    },

    // Garante que as estruturas de dados existam (sem forçar dados demo)
    // IMPORTANTE: Não depende de clientes para manter sessão
    ensureInitialized: function() {
        // Apenas garante que as estruturas existam, não força dados
        // O usuário pode ter zero clientes e isso é normal
        if (!localStorage.getItem('theraflow_profile')) {
            var profile = {
                displayName: 'Terapeuta',
                email: '',
                telefone: '',
                especialidade: '',
                duracaoPadrao: 60,
                servicos: ['Massagem Relaxante', 'Massagem Desportiva', 'Drenagem Linfática'],
                createdAt: this.formatDate(new Date())
            };
            localStorage.setItem('theraflow_profile', JSON.stringify(profile));
        }
    },

    // === CLIENTES ===
    getClients: function() {
        try {
            return JSON.parse(localStorage.getItem('theraflow_clients')) || [];
        } catch(e) {
            return [];
        }
    },

    getClientById: function(id) {
        var clients = this.getClients();
        for (var i = 0; i < clients.length; i++) {
            if (clients[i].id == id) return clients[i];
        }
        return null;
    },

    addClient: function(client) {
        var clients = this.getClients();
        client.id = this.generateId();
        client.sessoes = 0;
        client.createdAt = this.formatDate(new Date());
        clients.unshift(client);
        localStorage.setItem('theraflow_clients', JSON.stringify(clients));
        return client;
    },

    updateClient: function(id, data) {
        var clients = this.getClients();
        for (var i = 0; i < clients.length; i++) {
            if (clients[i].id == id) {
                for (var key in data) {
                    clients[i][key] = data[key];
                }
                localStorage.setItem('theraflow_clients', JSON.stringify(clients));
                return clients[i];
            }
        }
        return null;
    },

    deleteClient: function(id) {
        // SOFT DELETE: Marca como inativo em vez de remover
        // Isso mantém o histórico financeiro intacto
        this.updateClient(id, { status: 'inativo' });
    },

    // Deleta permanentemente (não recomendado)
    hardDeleteClient: function(id) {
        var clients = this.getClients();
        var filtered = [];
        for (var i = 0; i < clients.length; i++) {
            if (clients[i].id != id) filtered.push(clients[i]);
        }
        localStorage.setItem('theraflow_clients', JSON.stringify(filtered));
    },

    // Reativar cliente arquivado
    reactivateClient: function(id) {
        this.updateClient(id, { status: 'ativo' });
    },

    // Retorna apenas clientes ativos
    getActiveClients: function() {
        var clients = this.getClients();
        var result = [];
        for (var i = 0; i < clients.length; i++) {
            if (!clients[i].status || clients[i].status === 'ativo') {
                result.push(clients[i]);
            }
        }
        return result;
    },

    // Verifica se cliente está inativo
    isClientInactive: function(clientId) {
        var client = this.getClientById(clientId);
        return client && client.status === 'inativo';
    },

    // === SESSÕES ===
    getSessions: function() {
        try {
            return JSON.parse(localStorage.getItem('theraflow_sessions')) || [];
        } catch(e) {
            return [];
        }
    },

    getSessionById: function(id) {
        var sessions = this.getSessions();
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id == id) return sessions[i];
        }
        return null;
    },

    getSessionsByDate: function(date) {
        var sessions = this.getSessions();
        var result = [];
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].data === date) result.push(sessions[i]);
        }
        result.sort(function(a, b) { return a.hora.localeCompare(b.hora); });
        return result;
    },

    getSessionsByClient: function(clienteId) {
        var sessions = this.getSessions();
        var result = [];
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].clienteId == clienteId) result.push(sessions[i]);
        }
        result.sort(function(a, b) { return b.data.localeCompare(a.data); });
        return result;
    },

    getTodaySessions: function() {
        return this.getSessionsByDate(this.formatDate(new Date()));
    },

    addSession: function(session) {
        var sessions = this.getSessions();
        if (!session.id) {
            session.id = this.generateId();
        }
        sessions.push(session);
        localStorage.setItem('theraflow_sessions', JSON.stringify(sessions));
        
        if (session.clienteId) {
            var client = this.getClientById(session.clienteId);
            if (client) {
                this.updateClient(session.clienteId, { sessoes: (client.sessoes || 0) + 1 });
            }
        }
        return session;
    },

    updateSession: function(id, data) {
        var sessions = this.getSessions();
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id == id) {
                for (var key in data) {
                    sessions[i][key] = data[key];
                }
                localStorage.setItem('theraflow_sessions', JSON.stringify(sessions));
                return sessions[i];
            }
        }
        return null;
    },

    deleteSession: function(id) {
        var sessions = this.getSessions();
        var filtered = [];
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id != id) filtered.push(sessions[i]);
        }
        localStorage.setItem('theraflow_sessions', JSON.stringify(filtered));
    },

    markSessionPaid: function(id) {
        return this.updateSession(id, { pagamento: 'pago' });
    },

    markSessionNoShow: function(id) {
        return this.updateSession(id, { status: 'faltou' });
    },

    markSessionDone: function(id) {
        return this.updateSession(id, { status: 'realizado' });
    },

    // === FINANCEIRO ===
    getFinanceReport: function(year, month) {
        var sessions = this.getSessions();
        var monthStr = year + '-' + String(month).padStart(2, '0');
        
        var monthSessions = [];
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].data && sessions[i].data.indexOf(monthStr) === 0) {
                monthSessions.push(sessions[i]);
            }
        }
        
        var totalReceived = 0;
        var totalPending = 0;
        var paidSessions = [];
        var pendingSessions = [];
        var sessionsCompleted = 0;
        var sessionsMissed = 0;
        
        for (var i = 0; i < monthSessions.length; i++) {
            var s = monthSessions[i];
            if (s.pagamento === 'pago') {
                totalReceived += (s.valor || 0);
                paidSessions.push(s);
            } else if (s.status !== 'faltou') {
                totalPending += (s.valor || 0);
                pendingSessions.push(s);
            }
            if (s.status === 'realizado') sessionsCompleted++;
            if (s.status === 'faltou') sessionsMissed++;
        }

        return {
            totalSessions: monthSessions.length,
            totalReceived: totalReceived,
            totalPending: totalPending,
            total: totalReceived + totalPending,
            sessionsCompleted: sessionsCompleted,
            sessionsMissed: sessionsMissed,
            paidSessions: paidSessions,
            pendingSessions: pendingSessions
        };
    },

    // === PERFIL ===
    getProfile: function() {
        try {
            return JSON.parse(localStorage.getItem('theraflow_profile')) || {};
        } catch(e) {
            return {};
        }
    },

    saveProfile: function(data) {
        localStorage.setItem('theraflow_profile', JSON.stringify(data));
        return data;
    },

    updateProfile: function(data) {
        var profile = this.getProfile();
        for (var key in data) {
            profile[key] = data[key];
        }
        localStorage.setItem('theraflow_profile', JSON.stringify(profile));
        return profile;
    },

    // === AUTENTICAÇÃO ===
    isLoggedIn: function() {
        return localStorage.getItem('theraflow_logged') === 'true';
    },

    hasCompletedOnboarding: function() {
        return localStorage.getItem('theraflow_onboarding') === 'true';
    },

    completeOnboarding: function() {
        localStorage.setItem('theraflow_onboarding', 'true');
    },

    login: function(email) {
        localStorage.setItem('theraflow_logged', 'true');
        if (email) {
            localStorage.setItem('theraflow_email', email);
        }
    },

    logout: function() {
        localStorage.removeItem('theraflow_logged');
    },

    // Limpa apenas dados de negócio (mantém autenticação)
    clearBusinessData: function() {
        localStorage.removeItem('theraflow_clients');
        localStorage.removeItem('theraflow_sessions');
        localStorage.removeItem('theraflow_packages');
    },

    // Limpa TUDO incluindo autenticação (apenas para logout completo)
    clearAll: function() {
        localStorage.removeItem('theraflow_clients');
        localStorage.removeItem('theraflow_sessions');
        localStorage.removeItem('theraflow_profile');
        localStorage.removeItem('theraflow_logged');
        localStorage.removeItem('theraflow_email');
        localStorage.removeItem('theraflow_onboarding');
        localStorage.removeItem('theraflow_initialized');
        localStorage.removeItem('theraflow_packages');
    },

    // Reseta apenas dados de negócio, MANTÉM login do usuário
    resetData: function() {
        // Preservar autenticação
        var logged = localStorage.getItem('theraflow_logged');
        var email = localStorage.getItem('theraflow_email');
        var onboarding = localStorage.getItem('theraflow_onboarding');
        var profile = localStorage.getItem('theraflow_profile');
        
        this.clearBusinessData();
        this.init();
        
        // Restaurar autenticação
        if (logged) localStorage.setItem('theraflow_logged', logged);
        if (email) localStorage.setItem('theraflow_email', email);
        if (onboarding) localStorage.setItem('theraflow_onboarding', onboarding);
        if (profile) localStorage.setItem('theraflow_profile', profile);
    },

    // === PACOTES DE SESSÕES ===
    getPackages: function() {
        try {
            return JSON.parse(localStorage.getItem('theraflow_packages')) || [];
        } catch(e) {
            return [];
        }
    },

    getPackageById: function(id) {
        var packages = this.getPackages();
        for (var i = 0; i < packages.length; i++) {
            if (packages[i].id == id) return packages[i];
        }
        return null;
    },

    getPackagesByClient: function(clienteId) {
        var packages = this.getPackages();
        var result = [];
        for (var i = 0; i < packages.length; i++) {
            if (packages[i].clienteId == clienteId) result.push(packages[i]);
        }
        return result;
    },

    getActivePackagesByClient: function(clienteId) {
        var packages = this.getPackagesByClient(clienteId);
        var result = [];
        for (var i = 0; i < packages.length; i++) {
            if (packages[i].sessoesRestantes > 0) result.push(packages[i]);
        }
        return result;
    },

    addPackage: function(pkg) {
        var packages = this.getPackages();
        pkg.id = this.generateId();
        pkg.createdAt = this.formatDate(new Date());
        pkg.sessoesRestantes = pkg.sessoesTotal;
        packages.unshift(pkg);
        localStorage.setItem('theraflow_packages', JSON.stringify(packages));
        return pkg;
    },

    usePackageSession: function(packageId) {
        var packages = this.getPackages();
        for (var i = 0; i < packages.length; i++) {
            if (packages[i].id == packageId && packages[i].sessoesRestantes > 0) {
                packages[i].sessoesRestantes--;
                packages[i].sessoesUsadas = (packages[i].sessoesUsadas || 0) + 1;
                packages[i].ultimoUso = this.formatDate(new Date());
                localStorage.setItem('theraflow_packages', JSON.stringify(packages));
                return packages[i];
            }
        }
        return null;
    },

    deletePackage: function(id) {
        var packages = this.getPackages();
        var filtered = [];
        for (var i = 0; i < packages.length; i++) {
            if (packages[i].id != id) filtered.push(packages[i]);
        }
        localStorage.setItem('theraflow_packages', JSON.stringify(filtered));
    },

    // === LEMBRETES E CONFIRMAÇÕES ===
    getReminders: function() {
        try {
            return JSON.parse(localStorage.getItem('theraflow_reminders')) || [];
        } catch(e) {
            return [];
        }
    },

    addReminder: function(reminder) {
        var reminders = this.getReminders();
        reminder.id = this.generateId();
        reminder.createdAt = new Date().toISOString();
        reminder.status = 'pendente';
        reminders.push(reminder);
        localStorage.setItem('theraflow_reminders', JSON.stringify(reminders));
        return reminder;
    },

    updateReminder: function(id, data) {
        var reminders = this.getReminders();
        for (var i = 0; i < reminders.length; i++) {
            if (reminders[i].id == id) {
                for (var key in data) {
                    reminders[i][key] = data[key];
                }
                localStorage.setItem('theraflow_reminders', JSON.stringify(reminders));
                return reminders[i];
            }
        }
        return null;
    },

    getTomorrowSessions: function() {
        var tomorrow = this.addDays(new Date(), 1);
        return this.getSessionsByDate(this.formatDate(tomorrow));
    },

    getNext7DaysSessions: function() {
        var sessions = this.getSessions();
        var today = new Date();
        var next7 = this.addDays(today, 7);
        var todayStr = this.formatDate(today);
        var next7Str = this.formatDate(next7);
        var result = [];
        
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].data >= todayStr && sessions[i].data <= next7Str) {
                result.push(sessions[i]);
            }
        }
        result.sort(function(a, b) { return a.data.localeCompare(b.data); });
        return result;
    },

    // === RELATÓRIO FINANCEIRO INTELIGENTE ===
    getSmartFinanceReport: function() {
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var report = this.getFinanceReport(year, month);
        var next7Days = this.getNext7DaysSessions();
        
        // Mês anterior para comparação
        var prevMonth = month === 1 ? 12 : month - 1;
        var prevYear = month === 1 ? year - 1 : year;
        var prevReport = this.getFinanceReport(prevYear, prevMonth);
        
        // Calcular crescimento
        var growth = 0;
        if (prevReport.totalReceived > 0) {
            growth = Math.round(((report.totalReceived - prevReport.totalReceived) / prevReport.totalReceived) * 100);
        }
        
        var next7DaysValue = 0;
        for (var i = 0; i < next7Days.length; i++) {
            if (next7Days[i].pagamento !== 'pago' && next7Days[i].status !== 'faltou') {
                next7DaysValue += (next7Days[i].valor || 0);
            }
        }
        
        return {
            receivedThisMonth: report.totalReceived,
            pendingThisMonth: report.totalPending,
            next7Days: next7DaysValue,
            next7DaysSessions: next7Days.length,
            totalSessions: report.totalSessions,
            averageTicket: report.totalSessions > 0 ? (report.total / report.totalSessions) : 0,
            // Comparativo
            prevMonthReceived: prevReport.totalReceived,
            prevMonthSessions: prevReport.totalSessions,
            growthPercent: growth,
            sessionsCompleted: report.sessionsCompleted,
            sessionsMissed: report.sessionsMissed
        };
    },
    
    // === INDICADORES DE PROGRESSO PROFISSIONAL ===
    getProgressIndicators: function() {
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var sessions = this.getSessions();
        var clients = this.getClients();
        
        var thisMonthStr = year + '-' + String(month).padStart(2, '0');
        var thisMonthCompleted = 0;
        var thisMonthMissed = 0;
        var thisMonthTotal = 0;
        var thisMonthReceived = 0;
        
        // Clientes ativos (com sessão nos últimos 30 dias)
        var today = this.formatDate(new Date());
        var thirtyDaysAgo = this.formatDate(this.addDays(new Date(), -30));
        var activeClients = {};
        
        // Melhor mês histórico
        var monthlyTotals = {};
        
        for (var i = 0; i < sessions.length; i++) {
            var s = sessions[i];
            var monthKey = s.data ? s.data.substring(0, 7) : '';
            
            // Este mês
            if (monthKey === thisMonthStr) {
                thisMonthTotal++;
                if (s.status === 'realizado') thisMonthCompleted++;
                if (s.status === 'faltou') thisMonthMissed++;
                if (s.pagamento === 'pago') thisMonthReceived += (s.valor || 0);
            }
            
            // Clientes ativos
            if (s.data >= thirtyDaysAgo && s.data <= today && s.status === 'realizado') {
                activeClients[s.clienteId] = true;
            }
            
            // Totais mensais históricos
            if (monthKey && s.pagamento === 'pago') {
                if (!monthlyTotals[monthKey]) monthlyTotals[monthKey] = 0;
                monthlyTotals[monthKey] += (s.valor || 0);
            }
        }
        
        // Melhor mês
        var bestMonth = '';
        var bestMonthValue = 0;
        for (var m in monthlyTotals) {
            if (monthlyTotals[m] > bestMonthValue) {
                bestMonthValue = monthlyTotals[m];
                bestMonth = m;
            }
        }
        
        // Taxa de faltas
        var noShowRate = thisMonthTotal > 0 ? Math.round((thisMonthMissed / thisMonthTotal) * 100) : 0;
        
        // Média mensal (últimos 6 meses)
        var monthKeys = Object.keys(monthlyTotals).sort().slice(-6);
        var avgMonthly = 0;
        if (monthKeys.length > 0) {
            var sum = 0;
            for (var j = 0; j < monthKeys.length; j++) {
                sum += monthlyTotals[monthKeys[j]];
            }
            avgMonthly = Math.round(sum / monthKeys.length);
        }
        
        return {
            sessionsThisMonth: thisMonthCompleted,
            totalClientsRegistered: clients.length,
            activeClients: Object.keys(activeClients).length,
            noShowRate: noShowRate,
            bestMonth: bestMonth,
            bestMonthValue: bestMonthValue,
            monthlyAverage: avgMonthly,
            receivedThisMonth: thisMonthReceived
        };
    },
    
    // === ALERTAS INTELIGENTES ===
    getSmartAlerts: function() {
        var alerts = [];
        var today = this.formatDate(new Date());
        var tomorrow = this.formatDate(this.addDays(new Date(), 1));
        var thirtyDaysAgo = this.formatDate(this.addDays(new Date(), -30));
        var fortyFiveDaysAgo = this.formatDate(this.addDays(new Date(), -45));
        var sevenDaysAgo = this.formatDate(this.addDays(new Date(), -7));
        
        var sessions = this.getSessions();
        var clients = this.getClients();
        var packages = this.getPackages();
        
        // Mapa de última sessão por cliente
        var lastSessionByClient = {};
        var pendingPayments = [];
        var unconfirmedTomorrow = [];
        
        for (var i = 0; i < sessions.length; i++) {
            var s = sessions[i];
            
            // Última sessão realizada por cliente
            if (s.status === 'realizado') {
                if (!lastSessionByClient[s.clienteId] || s.data > lastSessionByClient[s.clienteId]) {
                    lastSessionByClient[s.clienteId] = s.data;
                }
            }
            
            // Sessões amanhã não confirmadas
            if (s.data === tomorrow && s.status === 'confirmado') {
                unconfirmedTomorrow.push(s);
            }
            
            // Pagamentos pendentes há mais de 7 dias
            if (s.pagamento === 'pendente' && s.status === 'realizado' && s.data < sevenDaysAgo) {
                pendingPayments.push(s);
            }
        }
        
        // Alerta: Sessões amanhã para confirmar
        if (unconfirmedTomorrow.length > 0) {
            alerts.push({
                type: 'confirmation',
                priority: 'high',
                icon: '📅',
                title: unconfirmedTomorrow.length + ' sessão(ões) amanhã',
                message: 'Lembre de confirmar com os clientes',
                sessions: unconfirmedTomorrow
            });
        }
        
        // Alerta: Clientes sem sessão há muito tempo
        for (var j = 0; j < clients.length; j++) {
            var clientId = clients[j].id;
            var lastSession = lastSessionByClient[clientId];
            
            if (!lastSession || lastSession < fortyFiveDaysAgo) {
                alerts.push({
                    type: 'churn_risk',
                    priority: 'medium',
                    icon: '⚠️',
                    title: 'Cliente inativo: ' + clients[j].nome,
                    message: lastSession ? 'Última sessão: ' + TheraFlowUI.formatDateBR(lastSession) : 'Nunca atendido',
                    clientId: clientId
                });
            } else if (lastSession < thirtyDaysAgo) {
                alerts.push({
                    type: 'reactivation',
                    priority: 'low',
                    icon: '💬',
                    title: 'Contatar: ' + clients[j].nome,
                    message: 'Sem sessão há 30+ dias',
                    clientId: clientId
                });
            }
        }
        
        // Alerta: Pacotes quase acabando
        for (var k = 0; k < packages.length; k++) {
            var pkg = packages[k];
            if (pkg.sessoesRestantes > 0 && pkg.sessoesRestantes <= 2) {
                alerts.push({
                    type: 'package_low',
                    priority: 'medium',
                    icon: '📦',
                    title: 'Pacote acabando: ' + pkg.clienteNome,
                    message: 'Restam ' + pkg.sessoesRestantes + ' sessão(ões)',
                    packageId: pkg.id
                });
            }
        }
        
        // Alerta: Pagamentos pendentes antigos
        if (pendingPayments.length > 0) {
            var totalPending = 0;
            for (var l = 0; l < pendingPayments.length; l++) {
                totalPending += (pendingPayments[l].valor || 0);
            }
            alerts.push({
                type: 'payment_overdue',
                priority: 'high',
                icon: '💰',
                title: pendingPayments.length + ' pagamento(s) pendente(s)',
                message: 'Total: R$ ' + totalPending.toFixed(2).replace('.', ','),
                sessions: pendingPayments
            });
        }
        
        // Ordenar por prioridade
        var priorityOrder = { high: 0, medium: 1, low: 2 };
        alerts.sort(function(a, b) { return priorityOrder[a.priority] - priorityOrder[b.priority]; });
        
        return alerts;
    },
    
    // === LINHA DO TEMPO DO CLIENTE ===
    getClientTimeline: function(clienteId) {
        var sessions = this.getSessionsByClient(clienteId);
        var client = this.getClientById(clienteId);
        var packages = this.getPackagesByClient(clienteId);
        
        if (!client) return null;
        
        // Calcular estatísticas
        var totalSessions = sessions.length;
        var completedSessions = 0;
        var missedSessions = 0;
        var totalSpent = 0;
        var lastSession = null;
        var firstSession = null;
        var sessionDates = [];
        
        for (var i = 0; i < sessions.length; i++) {
            var s = sessions[i];
            if (s.status === 'realizado') {
                completedSessions++;
                totalSpent += (s.valor || 0);
            }
            if (s.status === 'faltou') missedSessions++;
            
            sessionDates.push(new Date(s.data + 'T12:00:00'));
        }
        
        if (sessions.length > 0) {
            lastSession = sessions[0]; // Já ordenado decrescente
            firstSession = sessions[sessions.length - 1];
        }
        
        // Frequência média (dias entre sessões)
        var avgFrequency = 0;
        if (sessionDates.length > 1) {
            sessionDates.sort(function(a, b) { return a - b; });
            var totalDays = 0;
            for (var j = 1; j < sessionDates.length; j++) {
                totalDays += (sessionDates[j] - sessionDates[j-1]) / (1000 * 60 * 60 * 24);
            }
            avgFrequency = Math.round(totalDays / (sessionDates.length - 1));
        }
        
        // Valor médio por sessão
        var avgValue = completedSessions > 0 ? Math.round(totalSpent / completedSessions) : 0;
        
        // Última observação
        var lastNote = '';
        for (var k = 0; k < sessions.length; k++) {
            if (sessions[k].notas && sessions[k].notas.trim()) {
                lastNote = sessions[k].notas;
                break;
            }
        }
        
        // Pacotes ativos
        var activePackages = [];
        for (var l = 0; l < packages.length; l++) {
            if (packages[l].sessoesRestantes > 0) {
                activePackages.push(packages[l]);
            }
        }
        
        return {
            client: client,
            totalSessions: totalSessions,
            completedSessions: completedSessions,
            missedSessions: missedSessions,
            totalSpent: totalSpent,
            avgValue: avgValue,
            avgFrequencyDays: avgFrequency,
            lastSession: lastSession,
            firstSession: firstSession,
            lastNote: lastNote || client.notas || '',
            sessions: sessions,
            activePackages: activePackages,
            noShowRate: totalSessions > 0 ? Math.round((missedSessions / totalSessions) * 100) : 0
        };
    },
    
    // === INICIAR SESSÃO (em andamento) ===
    startSession: function(sessionId) {
        return this.updateSession(sessionId, { 
            status: 'em_andamento',
            inicioReal: new Date().toISOString()
        });
    },
    
    finishSession: function(sessionId, data) {
        var updateData = {
            status: data.status || 'realizado',
            fimReal: new Date().toISOString(),
            notas: data.notas || ''
        };
        
        if (data.pagamento) {
            updateData.pagamento = data.pagamento;
        }
        
        return this.updateSession(sessionId, updateData);
    },

    // === PLANO E LIMITES ===
    getUserPlan: function() {
        try {
            return JSON.parse(localStorage.getItem('theraflow_plan')) || { type: 'free', clientLimit: 5, hasPackages: false };
        } catch(e) {
            return { type: 'free', clientLimit: 5, hasPackages: false };
        }
    },

    setUserPlan: function(plan) {
        localStorage.setItem('theraflow_plan', JSON.stringify(plan));
        return plan;
    },

    checkPlanLimits: function() {
        var plan = this.getUserPlan();
        var clients = this.getClients();
        
        var limits = {
            free: { clients: 5, hasPackages: false, hasReports: false },
            pro: { clients: 50, hasPackages: true, hasReports: false },
            premium: { clients: 999999, hasPackages: true, hasReports: true }
        };
        
        var currentLimits = limits[plan.type] || limits.free;
        
        return {
            plan: plan.type,
            clientCount: clients.length,
            clientLimit: currentLimits.clients,
            clientsRemaining: currentLimits.clients - clients.length,
            isAtLimit: clients.length >= currentLimits.clients,
            hasPackages: currentLimits.hasPackages,
            hasReports: currentLimits.hasReports,
            usagePercent: Math.round((clients.length / currentLimits.clients) * 100)
        };
    },

    // === EXPORTAR RELATÓRIO ===
    generateMonthlyReport: function(year, month) {
        var report = this.getFinanceReport(year, month);
        var clients = this.getClients();
        var sessions = this.getSessions();
        
        var monthStr = year + '-' + String(month).padStart(2, '0');
        var monthSessions = [];
        var clientsAttended = {};
        
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].data && sessions[i].data.indexOf(monthStr) === 0) {
                monthSessions.push(sessions[i]);
                if (sessions[i].status === 'realizado') {
                    clientsAttended[sessions[i].clienteId] = true;
                }
            }
        }
        
        return {
            period: monthStr,
            totalReceived: report.totalReceived,
            totalPending: report.totalPending,
            totalExpected: report.total,
            sessionsCount: monthSessions.length,
            sessionsCompleted: report.sessionsCompleted,
            sessionsMissed: report.sessionsMissed,
            uniqueClientsAttended: Object.keys(clientsAttended).length,
            averageTicket: monthSessions.length > 0 ? (report.total / monthSessions.length) : 0,
            sessions: monthSessions
        };
    }
};

// Inicializa ao carregar
TheraFlowData.init();
