/**
 * TheraFlow Demo - Gerenciador de Dados (LocalStorage)
 * Simula o comportamento do Firebase para testes
 */

var TheraFlowData = {
    // === INICIALIZAÇÃO ===
    init: function() {
        if (!localStorage.getItem('theraflow_initialized')) {
            this.seedData();
            localStorage.setItem('theraflow_initialized', 'true');
        }
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

    generateId: function() {
        return Date.now();
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
        var clients = this.getClients();
        var filtered = [];
        for (var i = 0; i < clients.length; i++) {
            if (clients[i].id != id) filtered.push(clients[i]);
        }
        localStorage.setItem('theraflow_clients', JSON.stringify(filtered));
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

    clearAll: function() {
        localStorage.removeItem('theraflow_clients');
        localStorage.removeItem('theraflow_sessions');
        localStorage.removeItem('theraflow_profile');
        localStorage.removeItem('theraflow_logged');
        localStorage.removeItem('theraflow_email');
        localStorage.removeItem('theraflow_onboarding');
        localStorage.removeItem('theraflow_initialized');
    },

    resetData: function() {
        this.clearAll();
        this.init();
    }
};

// Inicializa ao carregar
TheraFlowData.init();
