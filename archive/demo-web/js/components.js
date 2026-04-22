/**
 * TheraFlow - Componentes Compartilhados
 * Componentes reutilizáveis em todas as páginas
 */

const TheraFlowComponents = (function() {
    
    // Array de nomes dos meses em português
    const MONTHS = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 
        'Maio', 'Junho', 'Julho', 'Agosto',
        'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    /**
     * Adiciona minutos a um horário
     * @param {string} time - Horário no formato HH:MM
     * @param {number} minutes - Minutos a adicionar
     * @returns {string} Horário resultante no formato HH:MM
     */
    function addMinutes(time, minutes) {
        const [h, m] = time.split(':').map(Number);
        const date = new Date(2000, 0, 1, h, m);
        date.setMinutes(date.getMinutes() + minutes);
        return date.toTimeString().substr(0, 5);
    }
    
    /**
     * Renderiza a navegação inferior
     * @param {string} activePage - Página ativa ('home', 'agenda', 'clientes', 'financeiro', 'perfil')
     * @returns {string} HTML da navegação
     */
    function renderNavigation(activePage) {
        const pages = [
            { id: 'home', icon: '🏠', label: 'Início', href: 'app.html' },
            { id: 'agenda', icon: '📅', label: 'Agenda', href: 'agenda.html' },
            { id: 'clientes', icon: '👥', label: 'Clientes', href: 'clientes.html' },
            { id: 'financeiro', icon: '💰', label: 'Finanças', href: 'financeiro.html' },
            { id: 'perfil', icon: '👤', label: 'Perfil', href: 'perfil.html' }
        ];
        
        return `
            <nav class="bottom-nav">
                ${pages.map(page => `
                    <a href="${page.href}" class="nav-item ${page.id === activePage ? 'active' : ''}">
                        <span class="icon">${page.icon}</span>
                        ${page.label}
                    </a>
                `).join('')}
            </nav>
        `;
    }
    
    /**
     * Injeta a navegação na página
     * @param {string} activePage - Página ativa
     */
    function injectNavigation(activePage) {
        // Remove navegação existente
        const existingNav = document.querySelector('.bottom-nav');
        if (existingNav) {
            existingNav.remove();
        }
        
        // Adiciona nova navegação
        document.body.insertAdjacentHTML('beforeend', renderNavigation(activePage));
    }
    
    /**
     * Renderiza um card de sessão
     * @param {Object} session - Dados da sessão
     * @param {Object} client - Dados do cliente
     * @param {Object} options - Opções de renderização
     * @returns {string} HTML do card
     */
    function renderSessionCard(session, client, options = {}) {
        const { showDate = false, showActions = true, isNext = false } = options;
        
        const endTime = addMinutes(session.time, session.duration || 50);
        const clientName = client ? client.name : 'Cliente não encontrado';
        const statusClass = `status-${session.status}`;
        const statusLabel = getStatusLabel(session.status);
        
        // Badge de valor
        let valueBadge = '';
        if (session.value) {
            const valueFormatted = TheraFlowUI.formatCurrency(session.value);
            const paymentClass = session.paymentStatus === 'pago' ? 'tf-badge-success' : 'tf-badge-warning';
            const paymentLabel = session.paymentStatus === 'pago' ? 'Pago' : 'Pendente';
            valueBadge = `<span class="${paymentClass}">${valueFormatted} - ${paymentLabel}</span>`;
        }
        
        // Data formatada
        let dateInfo = '';
        if (showDate && session.date) {
            dateInfo = `<div style="font-size: 0.85em; color: #888; margin-bottom: 5px;">
                📅 ${TheraFlowUI.formatDateBR(session.date)}
            </div>`;
        }
        
        // Ações rápidas
        let actionsHtml = '';
        if (showActions && session.status !== 'realizado') {
            actionsHtml = `
                <div class="quick-actions">
                    <button class="quick-action-btn" onclick="event.stopPropagation(); TheraFlowComponents.markSessionRealized('${session.id}')">
                        ✅ Realizada
                    </button>
                    <button class="quick-action-btn" onclick="event.stopPropagation(); TheraFlowComponents.markSessionMissed('${session.id}')">
                        ❌ Faltou
                    </button>
                </div>
            `;
        }
        
        return `
            <div class="session-card ${isNext ? 'next' : ''}" onclick="TheraFlowComponents.openSessionModal('${session.id}')">
                ${dateInfo}
                <div class="time">${session.time} - ${endTime}</div>
                <div class="client">${clientName}</div>
                <div class="details">
                    <span class="status-badge ${statusClass}">${statusLabel}</span>
                    ${valueBadge}
                </div>
                ${actionsHtml}
            </div>
        `;
    }
    
    /**
     * Retorna o label do status
     * @param {string} status - Código do status
     * @returns {string} Label do status
     */
    function getStatusLabel(status) {
        const labels = {
            'confirmado': 'Confirmado',
            'pendente': 'Pendente',
            'realizado': 'Realizado',
            'faltou': 'Faltou',
            'cancelado': 'Cancelado',
            'em_andamento': 'Em Andamento'
        };
        return labels[status] || status;
    }
    
    /**
     * Marca sessão como realizada
     * @param {string} sessionId - ID da sessão
     */
    function markSessionRealized(sessionId) {
        const session = TheraFlowData.updateSession(sessionId, { status: 'realizado' });
        if (session) {
            TheraFlowUI.showToast('Sessão marcada como realizada! ✅', 'success');
            
            // Dispara evento para atualizar a UI
            window.dispatchEvent(new CustomEvent('sessionUpdated', { detail: { sessionId, status: 'realizado' } }));
            
            // Recarrega a lista se a função existir
            if (typeof window.loadSessions === 'function') {
                window.loadSessions();
            } else if (typeof window.renderToday === 'function') {
                window.renderToday();
            }
        }
    }
    
    /**
     * Marca sessão como faltou
     * @param {string} sessionId - ID da sessão
     */
    function markSessionMissed(sessionId) {
        const session = TheraFlowData.updateSession(sessionId, { status: 'faltou' });
        if (session) {
            TheraFlowUI.showToast('Sessão marcada como falta', 'warning');
            
            // Dispara evento para atualizar a UI
            window.dispatchEvent(new CustomEvent('sessionUpdated', { detail: { sessionId, status: 'faltou' } }));
            
            // Recarrega a lista se a função existir
            if (typeof window.loadSessions === 'function') {
                window.loadSessions();
            } else if (typeof window.renderToday === 'function') {
                window.renderToday();
            }
        }
    }
    
    /**
     * Abre modal de detalhes da sessão
     * @param {string} sessionId - ID da sessão
     */
    function openSessionModal(sessionId) {
        const session = TheraFlowData.getSessions().find(s => s.id === sessionId);
        if (!session) return;
        
        const client = TheraFlowData.getClients().find(c => c.id === session.clientId);
        const clientName = client ? client.name : 'Cliente não encontrado';
        const endTime = addMinutes(session.time, session.duration || 50);
        
        const modalContent = `
            <div style="padding: 20px;">
                <h2 style="margin-bottom: 20px;">📋 Detalhes da Sessão</h2>
                
                <div style="background: #f8f9fa; padding: 15px; border-radius: 10px; margin-bottom: 20px;">
                    <p><strong>Cliente:</strong> ${clientName}</p>
                    <p><strong>Data:</strong> ${TheraFlowUI.formatDateBR(session.date)}</p>
                    <p><strong>Horário:</strong> ${session.time} - ${endTime}</p>
                    <p><strong>Duração:</strong> ${session.duration || 50} minutos</p>
                    <p><strong>Status:</strong> <span class="status-badge status-${session.status}">${getStatusLabel(session.status)}</span></p>
                    ${session.value ? `<p><strong>Valor:</strong> ${TheraFlowUI.formatCurrency(session.value)} (${session.paymentStatus === 'pago' ? 'Pago' : 'Pendente'})</p>` : ''}
                    ${session.notes ? `<p><strong>Observações:</strong> ${session.notes}</p>` : ''}
                </div>
                
                <ul class="tf-action-list">
                    ${session.status !== 'realizado' ? `
                        <li class="tf-action-item" onclick="TheraFlowComponents.markSessionRealized('${sessionId}'); TheraFlowUI.closeModal();">
                            <span class="icon">✅</span>
                            <div class="text">
                                <strong>Marcar como Realizada</strong>
                                <span>Confirma que a sessão foi realizada</span>
                            </div>
                        </li>
                    ` : ''}
                    ${session.status !== 'faltou' ? `
                        <li class="tf-action-item" onclick="TheraFlowComponents.markSessionMissed('${sessionId}'); TheraFlowUI.closeModal();">
                            <span class="icon">❌</span>
                            <div class="text">
                                <strong>Marcar como Falta</strong>
                                <span>Cliente não compareceu</span>
                            </div>
                        </li>
                    ` : ''}
                    ${session.paymentStatus !== 'pago' && session.value ? `
                        <li class="tf-action-item" onclick="TheraFlowComponents.markSessionPaid('${sessionId}'); TheraFlowUI.closeModal();">
                            <span class="icon">💰</span>
                            <div class="text">
                                <strong>Registrar Pagamento</strong>
                                <span>Marcar sessão como paga</span>
                            </div>
                        </li>
                    ` : ''}
                    <li class="tf-action-item" onclick="TheraFlowComponents.editSession('${sessionId}');">
                        <span class="icon">✏️</span>
                        <div class="text">
                            <strong>Editar Sessão</strong>
                            <span>Alterar horário, valor ou observações</span>
                        </div>
                    </li>
                    <li class="tf-action-item" style="color: #ef4444;" onclick="TheraFlowComponents.deleteSession('${sessionId}');">
                        <span class="icon">🗑️</span>
                        <div class="text">
                            <strong>Excluir Sessão</strong>
                            <span>Remover permanentemente</span>
                        </div>
                    </li>
                </ul>
            </div>
        `;
        
        TheraFlowUI.showModal(modalContent);
    }
    
    /**
     * Marca sessão como paga
     * @param {string} sessionId - ID da sessão
     */
    function markSessionPaid(sessionId) {
        const session = TheraFlowData.updateSession(sessionId, { paymentStatus: 'pago' });
        if (session) {
            TheraFlowUI.showToast('Pagamento registrado! 💰', 'success');
            
            // Recarrega a lista se a função existir
            if (typeof window.loadSessions === 'function') {
                window.loadSessions();
            } else if (typeof window.renderToday === 'function') {
                window.renderToday();
            } else if (typeof window.loadPayments === 'function') {
                window.loadPayments();
            }
        }
    }
    
    /**
     * Abre modal de edição de sessão
     * @param {string} sessionId - ID da sessão
     */
    function editSession(sessionId) {
        const session = TheraFlowData.getSessions().find(s => s.id === sessionId);
        if (!session) return;
        
        const clients = TheraFlowData.getClients();
        
        const modalContent = `
            <div style="padding: 20px;">
                <h2 style="margin-bottom: 20px;">✏️ Editar Sessão</h2>
                
                <form id="edit-session-form">
                    <div class="tf-form-group">
                        <label>Cliente</label>
                        <select id="edit-client" required>
                            ${clients.map(c => `<option value="${c.id}" ${c.id === session.clientId ? 'selected' : ''}>${c.name}</option>`).join('')}
                        </select>
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Data</label>
                        <input type="date" id="edit-date" value="${session.date}" required>
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Horário</label>
                        <input type="time" id="edit-time" value="${session.time}" required>
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Duração (minutos)</label>
                        <input type="number" id="edit-duration" value="${session.duration || 50}" min="15" max="180">
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Valor (R$)</label>
                        <input type="number" id="edit-value" value="${session.value || ''}" step="0.01" min="0">
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Observações</label>
                        <textarea id="edit-notes" rows="3">${session.notes || ''}</textarea>
                    </div>
                    
                    <div style="display: flex; gap: 10px; margin-top: 20px;">
                        <button type="button" class="btn btn-secondary" onclick="TheraFlowUI.closeModal()">Cancelar</button>
                        <button type="submit" class="btn btn-primary" style="flex: 1;">Salvar</button>
                    </div>
                </form>
            </div>
        `;
        
        TheraFlowUI.showModal(modalContent);
        
        // Event listener para salvar
        document.getElementById('edit-session-form').onsubmit = function(e) {
            e.preventDefault();
            
            const updates = {
                clientId: document.getElementById('edit-client').value,
                date: document.getElementById('edit-date').value,
                time: document.getElementById('edit-time').value,
                duration: parseInt(document.getElementById('edit-duration').value) || 50,
                value: parseFloat(document.getElementById('edit-value').value) || 0,
                notes: document.getElementById('edit-notes').value
            };
            
            TheraFlowData.updateSession(sessionId, updates);
            TheraFlowUI.closeModal();
            TheraFlowUI.showToast('Sessão atualizada! ✅', 'success');
            
            // Recarrega
            if (typeof window.loadSessions === 'function') {
                window.loadSessions();
            } else if (typeof window.renderToday === 'function') {
                window.renderToday();
            }
        };
    }
    
    /**
     * Exclui uma sessão
     * @param {string} sessionId - ID da sessão
     */
    function deleteSession(sessionId) {
        TheraFlowUI.showConfirmModal(
            'Excluir Sessão?',
            'Tem certeza que deseja excluir esta sessão? Esta ação não pode ser desfeita.',
            () => {
                TheraFlowData.deleteSession(sessionId);
                TheraFlowUI.closeModal();
                TheraFlowUI.showToast('Sessão excluída', 'success');
                
                // Recarrega
                if (typeof window.loadSessions === 'function') {
                    window.loadSessions();
                } else if (typeof window.renderToday === 'function') {
                    window.renderToday();
                }
            }
        );
    }
    
    /**
     * Mostra modal para criar nova sessão
     * @param {string} preselectedDate - Data pré-selecionada (opcional)
     * @param {string} preselectedClientId - ID do cliente pré-selecionado (opcional)
     */
    function showNewSessionModal(preselectedDate, preselectedClientId) {
        const clients = TheraFlowData.getClients();
        const today = preselectedDate || new Date().toISOString().split('T')[0];
        
        if (clients.length === 0) {
            TheraFlowUI.showToast('Cadastre um cliente primeiro!', 'warning');
            return;
        }
        
        // Pega o valor padrão do profissional
        const user = TheraFlowData.getUser();
        const defaultValue = user.defaultSessionValue || 150;
        const defaultDuration = user.defaultSessionDuration || 50;
        
        const modalContent = `
            <div style="padding: 20px;">
                <h2 style="margin-bottom: 20px;">📅 Nova Sessão</h2>
                
                <form id="new-session-form">
                    <div class="tf-form-group">
                        <label>Cliente *</label>
                        <select id="new-client" required>
                            <option value="">Selecione um cliente</option>
                            ${clients.map(c => `<option value="${c.id}" ${c.id === preselectedClientId ? 'selected' : ''}>${c.name}</option>`).join('')}
                        </select>
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Data *</label>
                        <input type="date" id="new-date" value="${today}" required>
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Horário *</label>
                        <input type="time" id="new-time" value="09:00" required>
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Duração (minutos)</label>
                        <input type="number" id="new-duration" value="${defaultDuration}" min="15" max="180">
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Valor (R$)</label>
                        <input type="number" id="new-value" value="${defaultValue}" step="0.01" min="0">
                    </div>
                    
                    <div class="tf-form-group">
                        <label>Observações</label>
                        <textarea id="new-notes" rows="3" placeholder="Anotações sobre a sessão..."></textarea>
                    </div>
                    
                    <div style="display: flex; gap: 10px; margin-top: 20px;">
                        <button type="button" class="btn btn-secondary" onclick="TheraFlowUI.closeModal()">Cancelar</button>
                        <button type="submit" class="btn btn-primary" style="flex: 1;">Agendar</button>
                    </div>
                </form>
            </div>
        `;
        
        TheraFlowUI.showModal(modalContent);
        
        // Event listener para salvar
        document.getElementById('new-session-form').onsubmit = function(e) {
            e.preventDefault();
            
            const newSession = {
                clientId: document.getElementById('new-client').value,
                date: document.getElementById('new-date').value,
                time: document.getElementById('new-time').value,
                duration: parseInt(document.getElementById('new-duration').value) || defaultDuration,
                value: parseFloat(document.getElementById('new-value').value) || 0,
                notes: document.getElementById('new-notes').value,
                status: 'confirmado',
                paymentStatus: 'pendente'
            };
            
            TheraFlowData.addSession(newSession);
            TheraFlowUI.closeModal();
            TheraFlowUI.showToast('Sessão agendada com sucesso! 📅', 'success');
            
            // Recarrega
            if (typeof window.loadSessions === 'function') {
                window.loadSessions();
            } else if (typeof window.renderToday === 'function') {
                window.renderToday();
            }
        };
    }
    
    /**
     * Renderiza o seletor de mês
     * @param {number} currentMonth - Mês atual (0-11)
     * @param {number} currentYear - Ano atual
     * @param {Function} onChangeCallback - Callback quando mês mudar
     * @returns {string} HTML do seletor
     */
    function renderMonthSelector(currentMonth, currentYear, onChangeCallback) {
        window._monthSelectorCallback = onChangeCallback;
        
        return `
            <div class="month-selector">
                <button onclick="TheraFlowComponents.changeMonth(-1)">&lt;</button>
                <span id="current-month">${MONTHS[currentMonth]} ${currentYear}</span>
                <button onclick="TheraFlowComponents.changeMonth(1)">&gt;</button>
            </div>
        `;
    }
    
    // Variáveis para o seletor de mês
    let _currentMonth = new Date().getMonth();
    let _currentYear = new Date().getFullYear();
    
    /**
     * Muda o mês selecionado
     * @param {number} delta - Direção (+1 ou -1)
     */
    function changeMonth(delta) {
        _currentMonth += delta;
        if (_currentMonth > 11) {
            _currentMonth = 0;
            _currentYear++;
        } else if (_currentMonth < 0) {
            _currentMonth = 11;
            _currentYear--;
        }
        
        const monthDisplay = document.getElementById('current-month');
        if (monthDisplay) {
            monthDisplay.textContent = `${MONTHS[_currentMonth]} ${_currentYear}`;
        }
        
        if (typeof window._monthSelectorCallback === 'function') {
            window._monthSelectorCallback(_currentMonth, _currentYear);
        }
    }
    
    /**
     * Obtém mês e ano atuais do seletor
     * @returns {Object} { month, year }
     */
    function getCurrentMonthYear() {
        return { month: _currentMonth, year: _currentYear };
    }
    
    /**
     * Define o mês e ano do seletor
     * @param {number} month - Mês (0-11)
     * @param {number} year - Ano
     */
    function setCurrentMonthYear(month, year) {
        _currentMonth = month;
        _currentYear = year;
    }
    
    /**
     * Renderiza estado vazio
     * @param {string} icon - Emoji do ícone
     * @param {string} message - Mensagem
     * @param {string} buttonText - Texto do botão (opcional)
     * @param {Function} buttonAction - Ação do botão (opcional)
     * @returns {string} HTML do estado vazio
     */
    function renderEmptyState(icon, message, buttonText, buttonAction) {
        let buttonHtml = '';
        if (buttonText && buttonAction) {
            const actionId = `empty-action-${Date.now()}`;
            window[actionId] = buttonAction;
            buttonHtml = `<button onclick="${actionId}()">${buttonText}</button>`;
        }
        
        return `
            <div class="empty-state">
                <div class="icon">${icon}</div>
                <p>${message}</p>
                ${buttonHtml}
            </div>
        `;
    }
    
    /**
     * Renderiza card de cliente
     * @param {Object} client - Dados do cliente
     * @param {Object} stats - Estatísticas do cliente
     * @returns {string} HTML do card
     */
    function renderClientCard(client, stats = {}) {
        const initials = client.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
        
        return `
            <div class="client-card" onclick="TheraFlowComponents.openClientModal('${client.id}')">
                <div class="name">
                    <div class="avatar">${initials}</div>
                    ${client.name}
                </div>
                ${client.email ? `<div class="info">📧 ${client.email}</div>` : ''}
                ${client.phone ? `<div class="info">📱 ${client.phone}</div>` : ''}
                <div class="stats-row">
                    <span>📅 ${stats.totalSessions || 0} sessões</span>
                    <span class="status-badge status-${client.status || 'ativo'}">${client.status === 'ativo' ? 'Ativo' : 'Inativo'}</span>
                </div>
            </div>
        `;
    }
    
    /**
     * Abre modal de detalhes do cliente
     * @param {string} clientId - ID do cliente
     */
    function openClientModal(clientId) {
        window.location.href = `clientes.html?id=${clientId}`;
    }
    
    /**
     * Renderiza card de pagamento
     * @param {Object} session - Dados da sessão
     * @param {Object} client - Dados do cliente
     * @returns {string} HTML do card
     */
    function renderPaymentCard(session, client) {
        const clientName = client ? client.name : 'Cliente não encontrado';
        const isPaid = session.paymentStatus === 'pago';
        
        return `
            <div class="payment-card ${isPaid ? 'paid' : ''}" onclick="${isPaid ? '' : `TheraFlowComponents.markSessionPaid('${session.id}')`}">
                <div class="header-row">
                    <span class="client">${clientName}</span>
                    <span class="pay-value">${TheraFlowUI.formatCurrency(session.value)}</span>
                </div>
                <div class="details">
                    ${TheraFlowUI.formatDateBR(session.date)} às ${session.time}
                    ${isPaid ? ' ✅ Pago' : ' ⏳ Pendente'}
                </div>
            </div>
        `;
    }
    
    /**
     * Verifica autenticação e redireciona se necessário
     * Wrapper para TheraFlowUI.checkAuth() com mensagem contextual
     */
    function requireAuth() {
        return TheraFlowUI.checkAuth();
    }
    
    // API Pública
    return {
        // Constantes
        MONTHS,
        
        // Utilitários
        addMinutes,
        getStatusLabel,
        requireAuth,
        
        // Navegação
        renderNavigation,
        injectNavigation,
        
        // Cards
        renderSessionCard,
        renderClientCard,
        renderPaymentCard,
        renderEmptyState,
        
        // Modais
        openSessionModal,
        editSession,
        deleteSession,
        showNewSessionModal,
        openClientModal,
        
        // Ações
        markSessionRealized,
        markSessionMissed,
        markSessionPaid,
        
        // Seletor de mês
        renderMonthSelector,
        changeMonth,
        getCurrentMonthYear,
        setCurrentMonthYear
    };
})();

// Exporta para uso global
if (typeof window !== 'undefined') {
    window.TheraFlowComponents = TheraFlowComponents;
}
