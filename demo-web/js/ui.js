/**
 * TheraFlow Demo - Utilitários de UI
 */

// Injetar estilos CSS para modais
(function() {
    if (document.getElementById('theraflow-ui-styles')) return;
    var style = document.createElement('style');
    style.id = 'theraflow-ui-styles';
    style.textContent = '\
        .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 10000; opacity: 0; transition: opacity 0.3s ease; padding: 20px; }\
        .modal-overlay.active { opacity: 1; }\
        .modal { background: white; border-radius: 15px; max-width: 500px; width: 100%; max-height: 90vh; overflow: hidden; display: flex; flex-direction: column; transform: translateY(-20px); transition: transform 0.3s ease; }\
        .modal-overlay.active .modal { transform: translateY(0); }\
        .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px; border-bottom: 1px solid #eee; }\
        .modal-title { margin: 0; font-size: 1.2em; color: #333; }\
        .modal-close { background: none; border: none; font-size: 1.5em; cursor: pointer; color: #999; padding: 0; width: 30px; height: 30px; }\
        .modal-close:hover { color: #333; }\
        .modal-body { padding: 20px; overflow-y: auto; flex: 1; }\
        .modal-footer { display: flex; gap: 10px; padding: 20px; border-top: 1px solid #eee; justify-content: flex-end; }\
        .btn { padding: 12px 24px; border-radius: 8px; font-size: 1em; cursor: pointer; border: none; transition: all 0.2s; font-weight: 500; }\
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }\
        .btn-primary:hover { box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4); }\
        .btn-secondary { background: #f0f0f0; color: #666; }\
        .btn-secondary:hover { background: #e0e0e0; }\
        .tf-form-group { margin-bottom: 15px; }\
        .tf-form-group label { display: block; margin-bottom: 5px; font-weight: 600; color: #333; font-size: 0.9em; }\
        .tf-form-group input, .tf-form-group select, .tf-form-group textarea { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 1em; }\
        .tf-form-group input:focus, .tf-form-group select:focus, .tf-form-group textarea:focus { outline: none; border-color: #667eea; }\
        .tf-action-list { list-style: none; padding: 0; margin: 0; }\
        .tf-action-item { display: flex; align-items: center; gap: 15px; padding: 15px; margin-bottom: 8px; background: #f8f9fa; border-radius: 10px; cursor: pointer; transition: all 0.2s; }\
        .tf-action-item:hover { background: #f0f0f0; transform: translateX(5px); }\
        .tf-action-item .icon { font-size: 1.5em; }\
        .tf-action-item .text { flex: 1; }\
        .tf-action-item .text strong { display: block; color: #333; }\
        .tf-action-item .text span { font-size: 0.85em; color: #666; }\
        .tf-badge-success { background: #d1fae5; color: #065f46; padding: 4px 8px; border-radius: 6px; font-size: 0.85em; }\
        .tf-badge-warning { background: #fef3c7; color: #92400e; padding: 4px 8px; border-radius: 6px; font-size: 0.85em; }\
    ';
    document.head.appendChild(style);
})();

var TheraFlowUI = {
    // === MODAL ===
    showModal: function(options) {
        var title = options.title || '';
        var content = options.content || '';
        var buttons = options.buttons || [];
        
        // Remove modal existente
        var existingModal = document.getElementById('modal-overlay');
        if (existingModal) existingModal.remove();
        
        var overlay = document.createElement('div');
        overlay.id = 'modal-overlay';
        overlay.className = 'modal-overlay';
        overlay.onclick = function(e) {
            if (e.target === overlay) TheraFlowUI.closeModal();
        };
        
        var modal = document.createElement('div');
        modal.className = 'modal';
        
        var header = document.createElement('div');
        header.className = 'modal-header';
        
        var titleEl = document.createElement('h3');
        titleEl.className = 'modal-title';
        titleEl.textContent = title;
        header.appendChild(titleEl);
        
        var closeBtn = document.createElement('button');
        closeBtn.className = 'modal-close';
        closeBtn.innerHTML = '&times;';
        closeBtn.onclick = function() { TheraFlowUI.closeModal(); };
        header.appendChild(closeBtn);
        
        modal.appendChild(header);
        
        var body = document.createElement('div');
        body.className = 'modal-body';
        if (typeof content === 'string') {
            body.innerHTML = content;
        } else {
            body.appendChild(content);
        }
        modal.appendChild(body);
        
        if (buttons.length > 0) {
            var footer = document.createElement('div');
            footer.className = 'modal-footer';
            
            for (var i = 0; i < buttons.length; i++) {
                var btn = buttons[i];
                var buttonEl = document.createElement('button');
                buttonEl.className = 'btn ' + (btn.primary ? 'btn-primary' : 'btn-secondary');
                buttonEl.textContent = btn.text;
                buttonEl.onclick = (function(b) {
                    return function() {
                        if (b.onClick) b.onClick();
                        if (b.closeOnClick !== false) TheraFlowUI.closeModal();
                    };
                })(btn);
                footer.appendChild(buttonEl);
            }
            modal.appendChild(footer);
        }
        
        overlay.appendChild(modal);
        document.body.appendChild(overlay);
        
        setTimeout(function() { overlay.classList.add('active'); }, 10);
        return modal;
    },
    
    closeModal: function() {
        var overlay = document.getElementById('modal-overlay');
        if (overlay) {
            overlay.classList.remove('active');
            setTimeout(function() { overlay.remove(); }, 300);
        }
    },

    confirm: function(message, onConfirm, onCancel) {
        this.showModal({
            title: 'Confirmação',
            content: '<p style="margin: 0;">' + message + '</p>',
            buttons: [
                { text: 'Cancelar', onClick: onCancel || function() {} },
                { text: 'Confirmar', primary: true, onClick: onConfirm || function() {} }
            ]
        });
    },

    alert: function(title, message, onOk) {
        this.showModal({
            title: title,
            content: '<p style="margin: 0;">' + message + '</p>',
            buttons: [
                { text: 'OK', primary: true, onClick: onOk || function() {} }
            ]
        });
    },

    // === TOAST ===
    toast: function(message, type, duration) {
        type = type || 'info';
        duration = duration || 3000;
        
        var existing = document.getElementById('toast-container');
        if (!existing) {
            existing = document.createElement('div');
            existing.id = 'toast-container';
            existing.style.cssText = 'position: fixed; bottom: 20px; right: 20px; z-index: 10000;';
            document.body.appendChild(existing);
        }
        
        var toast = document.createElement('div');
        toast.className = 'toast toast-' + type;
        toast.innerHTML = message;
        toast.style.cssText = 'background: #333; color: white; padding: 12px 24px; border-radius: 8px; margin-top: 8px; animation: slideIn 0.3s ease; box-shadow: 0 4px 12px rgba(0,0,0,0.3);';
        
        if (type === 'success') toast.style.background = '#10b981';
        if (type === 'error') toast.style.background = '#ef4444';
        if (type === 'warning') toast.style.background = '#f59e0b';
        
        existing.appendChild(toast);
        
        setTimeout(function() {
            toast.style.opacity = '0';
            toast.style.transition = 'opacity 0.3s';
            setTimeout(function() { toast.remove(); }, 300);
        }, duration);
    },

    // === LOADING ===
    showLoading: function(message) {
        message = message || 'Carregando...';
        
        var existing = document.getElementById('loading-overlay');
        if (existing) existing.remove();
        
        var overlay = document.createElement('div');
        overlay.id = 'loading-overlay';
        overlay.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 10000;';
        
        var spinner = document.createElement('div');
        spinner.style.cssText = 'text-align: center; color: white;';
        spinner.innerHTML = '<div style="width: 40px; height: 40px; border: 4px solid #fff; border-top-color: transparent; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px;"></div>' + message;
        
        overlay.appendChild(spinner);
        document.body.appendChild(overlay);
        
        // Adiciona animação de spin se não existir
        if (!document.getElementById('loading-styles')) {
            var style = document.createElement('style');
            style.id = 'loading-styles';
            style.textContent = '@keyframes spin { to { transform: rotate(360deg); } } @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }';
            document.head.appendChild(style);
        }
    },
    
    hideLoading: function() {
        var overlay = document.getElementById('loading-overlay');
        if (overlay) overlay.remove();
    },

    // === FORMATADORES ===
    formatCurrency: function(value) {
        value = parseFloat(value) || 0;
        return 'R$ ' + value.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    },

    formatDateBR: function(dateStr) {
        if (!dateStr) return '';
        if (dateStr.indexOf('/') > -1) return dateStr;
        var parts = dateStr.split('-');
        if (parts.length === 3) {
            return parts[2] + '/' + parts[1] + '/' + parts[0];
        }
        return dateStr;
    },

    formatDateISO: function(dateStr) {
        if (!dateStr) return '';
        if (dateStr.indexOf('-') > -1) return dateStr;
        var parts = dateStr.split('/');
        if (parts.length === 3) {
            return parts[2] + '-' + parts[1] + '-' + parts[0];
        }
        return dateStr;
    },

    formatPhone: function(phone) {
        if (!phone) return '';
        var cleaned = phone.replace(/\D/g, '');
        if (cleaned.length === 11) {
            return '(' + cleaned.slice(0,2) + ') ' + cleaned.slice(2,7) + '-' + cleaned.slice(7);
        }
        if (cleaned.length === 10) {
            return '(' + cleaned.slice(0,2) + ') ' + cleaned.slice(2,6) + '-' + cleaned.slice(6);
        }
        return phone;
    },

    // === HELPERS DE DATA ===
    getWeekdayName: function(dateStr) {
        var days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
        var date = new Date(dateStr + 'T12:00:00');
        return days[date.getDay()];
    },

    getMonthName: function(month) {
        var months = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
                      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
        return months[parseInt(month) - 1] || '';
    },

    isToday: function(dateStr) {
        var today = new Date();
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0');
        var day = String(today.getDate()).padStart(2, '0');
        return dateStr === year + '-' + month + '-' + day;
    },

    // === AUTENTICAÇÃO ===
    checkAuth: function() {
        if (!TheraFlowData.isLoggedIn()) {
            window.location.href = 'index.html';
            return false;
        }
        return true;
    },

    checkOnboarding: function() {
        if (!TheraFlowData.hasCompletedOnboarding()) {
            window.location.href = 'onboarding.html';
            return false;
        }
        return true;
    },

    // === HELPERS DE SESSÃO ===
    getStatusLabel: function(status) {
        var labels = {
            'confirmado': 'Confirmado',
            'realizado': 'Realizado',
            'faltou': 'Faltou'
        };
        return labels[status] || status;
    },

    getStatusClass: function(status) {
        var classes = {
            'confirmado': 'status-confirmed',
            'realizado': 'status-completed',
            'faltou': 'status-missed'
        };
        return classes[status] || '';
    },

    getPagamentoLabel: function(pagamento) {
        return pagamento === 'pago' ? 'Pago' : 'Pendente';
    },

    getPagamentoClass: function(pagamento) {
        return pagamento === 'pago' ? 'payment-paid' : 'payment-pending';
    },

    // === HELPER DE SERVIÇOS ===
    getServicesList: function() {
        var profile = TheraFlowData.getProfile();
        return profile.servicos || ['Massagem Relaxante', 'Massagem Desportiva', 'Drenagem Linfática', 'Shiatsu', 'Reiki', 'Reflexologia'];
    },

    getDuracaoOptions: function() {
        return [30, 45, 60, 90, 120];
    },

    // === EXPORTAR RELATÓRIO ===
    exportToCSV: function(data, filename) {
        var csv = '';
        var headers = Object.keys(data[0] || {});
        csv += headers.join(';') + '\n';
        
        for (var i = 0; i < data.length; i++) {
            var row = [];
            for (var j = 0; j < headers.length; j++) {
                var value = data[i][headers[j]];
                if (typeof value === 'string' && value.indexOf(';') > -1) {
                    value = '"' + value + '"';
                }
                row.push(value || '');
            }
            csv += row.join(';') + '\n';
        }
        
        var blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = filename || 'relatorio.csv';
        a.click();
        URL.revokeObjectURL(url);
    },

    generatePDFReport: function(reportData) {
        // Gera HTML para impressão/PDF
        var html = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Relatório TheraFlow</title>' +
            '<style>body{font-family:Arial,sans-serif;padding:40px;max-width:800px;margin:0 auto;}' +
            '.header{text-align:center;margin-bottom:30px;border-bottom:2px solid #667eea;padding-bottom:20px;}' +
            '.header h1{color:#667eea;margin:0 0 10px 0;}' +
            '.summary{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-bottom:30px;}' +
            '.summary-item{background:#f8f9fa;padding:20px;border-radius:10px;text-align:center;}' +
            '.summary-item .value{font-size:2em;font-weight:bold;color:#667eea;}' +
            '.summary-item .label{color:#666;margin-top:5px;}' +
            'table{width:100%;border-collapse:collapse;margin-top:20px;}' +
            'th,td{padding:12px;text-align:left;border-bottom:1px solid #eee;}' +
            'th{background:#667eea;color:white;}' +
            '.footer{margin-top:40px;text-align:center;color:#999;font-size:0.9em;}' +
            '@media print{body{padding:20px;}}</style></head><body>' +
            '<div class="header"><h1>💆 TheraFlow</h1><p>Relatório Mensal - ' + reportData.period + '</p></div>' +
            '<div class="summary">' +
            '<div class="summary-item"><div class="value">R$ ' + (reportData.totalReceived || 0).toFixed(2).replace('.', ',') + '</div><div class="label">✅ Recebido</div></div>' +
            '<div class="summary-item"><div class="value">R$ ' + (reportData.totalPending || 0).toFixed(2).replace('.', ',') + '</div><div class="label">⏳ Pendente</div></div>' +
            '<div class="summary-item"><div class="value">' + (reportData.uniqueClientsAttended || 0) + '</div><div class="label">👥 Clientes Atendidos</div></div>' +
            '</div>' +
            '<h3>📊 Resumo</h3>' +
            '<table><tr><th>Métrica</th><th>Valor</th></tr>' +
            '<tr><td>Total de Sessões</td><td>' + (reportData.sessionsCount || 0) + '</td></tr>' +
            '<tr><td>Sessões Realizadas</td><td>' + (reportData.sessionsCompleted || 0) + '</td></tr>' +
            '<tr><td>Faltas</td><td>' + (reportData.sessionsMissed || 0) + '</td></tr>' +
            '<tr><td>Ticket Médio</td><td>R$ ' + (reportData.averageTicket || 0).toFixed(2).replace('.', ',') + '</td></tr>' +
            '<tr><td>Total Esperado</td><td>R$ ' + (reportData.totalExpected || 0).toFixed(2).replace('.', ',') + '</td></tr>' +
            '</table>' +
            '<div class="footer"><p>Relatório gerado em ' + new Date().toLocaleDateString('pt-BR') + '</p><p>TheraFlow - Gestão para Terapeutas</p></div>' +
            '</body></html>';
        
        var printWindow = window.open('', '_blank');
        printWindow.document.write(html);
        printWindow.document.close();
        printWindow.focus();
        setTimeout(function() { printWindow.print(); }, 500);
    }
};

// Alias global para compatibilidade
var UI = TheraFlowUI;
