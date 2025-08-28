// =============================================================================
// MDT - Mobile Data Terminal
// Cinelândia
// =============================================================================

let currentUser = null;
let currentDepartment = null;
let isLoggedIn = false;
let currentViewedCitizenPassport = null;

// Atualiza a UI do status de serviço (ponto verde/vermelho e texto)
function setServiceStatus(inService) {
	const $dot = $('#serviceStatus .status-dot');
	const $text = $('#serviceStatus .status-text');
	if (inService) {
		$dot.removeClass('offline').addClass('online');
		$text.text('Em serviço');
	} else {
		$dot.removeClass('online').addClass('offline');
		$text.text('Fora de serviço');
	}
}

// Mapeamento de departamentos
const departmentNames = {
    'PoliciaMilitar': 'Polícia Militar',
    'PCivil': 'Polícia Civil',
    'Core': 'CORE',
    'PRF': 'PRF'
};

// =============================================================================
// FUNÇÕES DE LOGIN E AUTENTICAÇÃO
// =============================================================================

// Função de login
function handleLogin(e) {
    e.preventDefault();
    
    const passport = $('#passport').val();
    const password = $('#password').val();
    
    if (!passport || !password) {
        showLoginError('Por favor, preencha todos os campos.');
        return;
    }
    
    // Verificar senha do departamento
    let department = null;
    if (password === 'pm123') {
        department = 'PoliciaMilitar';
    } else if (password === 'pc123') {
        department = 'PCivil';
    } else if (password === 'core123') {
        department = 'Core';
    } else if (password === 'prf123') {
        department = 'PRF';
    } else {
        showLoginError('Senha do departamento incorreta.');
        return;
    }
    
    // Enviar dados para autenticação
    console.log('Enviando dados de autenticação:', { passport, department });
    $.post('https://mdt/authenticateUser', JSON.stringify({
        passport: passport,
        department: department
    }), function(response) {
        console.log('Resposta de autenticação recebida:', response);
        console.log('Response.result:', response.result);
        console.log('Response.result.success:', response.result ? response.result.success : 'undefined');
        
        if (response.result && response.result.success) {
            console.log('✅ Login bem-sucedido!');
            currentUser = response.result.user;
            currentDepartment = department;
            isLoggedIn = true;
            
            console.log('Dados do usuário:', currentUser);
            console.log('Departamento:', currentDepartment);
            
            // Atualizar interface
            $('#userName').text(currentUser.name);
            $('#userRank').text(currentUser.rank);
            
            console.log('Interface atualizada, escondendo login...');
            
            // Esconder login e mostrar MDT
            $('#loginModal').hide();
            $('#mdtOverlay').show();
            $('#mdtInterface').show();
            
            // Carregar dados iniciais
            loadDashboardData();
            loadWarrants();
            loadAllFines();
            loadAllPrisonFines();
            loadAllPorts();
            loadAllReports();
            loadAllVehicles();
            loadAnnouncements();
            
            showNotification('Login realizado com sucesso!', 'success');

			// Atualizar status de serviço na UI após login
			$.post('https://mdt/getServiceStatus', JSON.stringify({}), function(response) {
				if (response && response.success !== false) {
					setServiceStatus(!!response.inService);
				}
			});
        } else {
            const errorMessage = response.result ? response.result.message : 'Erro no login.';
            showLoginError(errorMessage);
        }
    }).fail(function() {
        showLoginError('Erro de conexão. Tente novamente.');
    });
}

// Mostrar erro de login
function showLoginError(message) {
    $('#errorMessage').text(message);
    $('#loginError').show();
    
    setTimeout(() => {
        $('#loginError').hide();
    }, 5000);
}

// =============================================================================
// FUNÇÕES DE NAVEGAÇÃO
// =============================================================================

// Navegar entre seções
function navigateToSection(section) {
    // Remover classe active de todas as seções
    $('.content-section').removeClass('active');
    $('.nav-item').removeClass('active');
    
    // Adicionar classe active na seção selecionada
    $(`#${section}Section`).addClass('active');
    $(`.nav-item[data-section="${section}"]`).addClass('active');

// Atualizar título da página
    const titles = {
        'dashboard': 'Dashboard',
        'search': 'Buscar Cidadão',
        'prison': 'Prender',
        'fine': 'Multar',
        'warrants': 'Mandados',
        'ports': 'Portes',
        'reports': 'Relatórios',
        'vehicles': 'Veículos',
        'announcements': 'Avisos'
    };
    
    $('#pageTitle').text(titles[section] || 'MDT');
}

// Fechar MDT
function closeMDT() {
    $('#mdtOverlay').hide();
    $('#mdtInterface').hide();
    $('#loginModal').show();
    
    // Resetar dados
    currentUser = null;
    currentDepartment = null;
    isLoggedIn = false;
    
    // Enviar evento para fechar
    $.post('https://mdt/closeMDT', JSON.stringify({}));
}

// =============================================================================
// FUNÇÕES DE BUSCA
// =============================================================================

// Buscar usuário
function performSearch() {
    const passport = $('#searchPassport').val();
    
    console.log('performSearch chamada com passport:', passport);
    
    if (!passport || passport.trim() === '') {
        showNotification('Por favor, digite o ID do cidadão.', 'error');
        return;
    }
    
    $('#searchResults').html('<div class="loading"><div class="spinner"></div></div>');
    
    console.log('Realizando busca por ID para passport:', passport);
    console.log('Enviando requisição para: https://mdt/searchCitizenById');
    
    const requestData = {
        passport: passport
    };
    
    console.log('Dados enviados:', requestData);
    
    $.post('https://mdt/searchCitizenById', JSON.stringify(requestData), function(response) {
        console.log('=== RESPOSTA RECEBIDA ===');
        console.log('Resposta completa:', response);
        console.log('Tipo de resposta:', typeof response);
        console.log('Response.result:', response.result);
        console.log('Response.result.success:', response.result ? response.result.success : 'undefined');
        console.log('Response.result.message:', response.result ? response.result.message : 'undefined');
        
        if (response && response.result && response.result.success) {
            console.log('✅ Sucesso! Exibindo resultados...');
            displayCompleteSearchResults(response.result);
        } else {
            console.log('❌ Falha na busca');
            const errorMessage = response && response.result && response.result.message ? response.result.message : 'Cidadão não encontrado na base de dados.';
            console.log('Mensagem de erro:', errorMessage);
            $('#searchResults').html(`<div class="no-results"><i class="fas fa-user-slash" style="font-size: 48px; color: #95a5a6; margin-bottom: 15px;"></i><p>${errorMessage}</p><p style="font-size: 12px; color: #7f8c8d;">Verifique se o ID está correto.</p></div>`);
        }
    }).fail(function(xhr, status, error) {
        console.error('Erro na busca por ID:', error);
        console.error('Status:', status);
        console.error('XHR:', xhr);
        console.error('ResponseText:', xhr.responseText);
        $('#searchResults').html('<div class="no-results"><i class="fas fa-exclamation-triangle" style="font-size: 48px; color: #e74c3c; margin-bottom: 15px;"></i><p>Erro ao buscar cidadão.</p><p style="font-size: 12px; color: #7f8c8d;">Tente novamente.</p></div>');
    });
}

// Exibir resultados da busca completa
function displayCompleteSearchResults(data) {
    console.log('=== INICIANDO DISPLAY COMPLETE SEARCH RESULTS ===');
    console.log('Dados recebidos:', data);
    console.log('Tipo dos dados:', typeof data);
    
    if (!data) {
        console.error('❌ Dados vazios recebidos');
        return;
    }
    
    const user = data.user;
    // Guardar o passaporte do cidadão atualmente exibido para atualizações em tempo real
    currentViewedCitizenPassport = user && user.passport ? String(user.passport) : null;
    const prisonRecords = data.prisonRecords || [];
    const warrants = data.warrants || [];
    const fines = data.fines || [];
    const ports = data.ports || [];
    const vehicles = data.vehicles || [];
    
    console.log('Dados do usuário:', user);
    console.log('Registros de prisão:', prisonRecords);
    console.log('Mandados:', warrants);
    console.log('Multas:', fines);
    console.log('Portes:', ports);
    console.log('Veículos:', vehicles);
    
    let html = `
        <div class="user-card">
            <div class="user-header">
                <h3>${user.name}</h3>
                <span class="passport">Passaporte: ${user.passport}</span>
            </div>
            
            <div class="user-details">
                <!-- Informações Pessoais -->
                <div class="info-section">
                    <h4><i class="fas fa-user"></i> Informações Pessoais</h4>
                    <div class="user-info-grid">
                        <div class="info-item">
                            <strong>Telefone:</strong> ${user.phone || 'N/A'}
                        </div>
                        <div class="info-item">
                            <strong>Idade:</strong> ${user.age || 'N/A'} anos
                        </div>
                        <div class="info-item">
                            <strong>Sexo:</strong> ${user.sex || 'N/A'}
                        </div>
                        <div class="info-item">
                            <strong>Sangue:</strong> ${user.blood || 'N/A'}
                        </div>
                        <div class="info-item">
                            <strong>Localização:</strong> ${user.locate || 'N/A'}
                        </div>
                        <div class="info-item">
                            <strong>Visa:</strong> ${user.visa || 0}
                        </div>
                    </div>
                </div>
                
                <!-- Informações Financeiras -->
                <div class="info-section">
                    <h4><i class="fas fa-dollar-sign"></i> Informações Financeiras</h4>
                    <div class="user-info-grid">
                        <div class="info-item">
                            <strong>Banco:</strong> R$ ${(user.bank || 0).toLocaleString()}
                        </div>
                        <div class="info-item">
                            <strong>PayPal:</strong> R$ ${(user.paypal || 0).toLocaleString()}
                        </div>
                        <div class="info-item">
                            <strong>Garagens:</strong> ${user.garage || 0}
                        </div>
                        <div class="info-item">
                            <strong>Multas Pendentes:</strong> <span id="financePendingFinesAmount">R$ ${(user.totalFines || 0).toLocaleString()}</span> <span id="financePendingFinesCount" style="color:#b0b0b0;">(${user.finesCount || 0} multas)</span>
                        </div>
                    </div>
                </div>
                
                <!-- Estatísticas -->
                <div class="info-section">
                    <h4><i class="fas fa-chart-bar"></i> Estatísticas</h4>
                <div class="user-stats">
                    <div class="stat-item">
                        <span class="stat-label">Multas em Débito:</span>
                        <span class="stat-value fines-total">R$ ${user.totalFines || 0}</span>
                        <span class="stat-count">(${user.finesCount || 0} multas)</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Prisões:</span>
                        <span class="stat-value">${user.prisonCount || 0}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Mandados Ativos:</span>
                        <span class="stat-value">${user.warrantCount || 0}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Portes:</span>
                        <span class="stat-value">${user.portCount || 0}</span>
                    </div>
                        <div class="stat-item">
                            <span class="stat-label">Veículos:</span>
                            <span class="stat-value">${user.vehicleCount || 0}</span>
                </div>
                    </div>
                </div>
                
                <!-- Ações -->
                <div class="user-actions">
                    <button class="action-btn" onclick="cleanPrisonRecords(${user.passport})">
                        <i class="fas fa-eraser"></i> Limpar Registros de Prisão
                    </button>
                </div>
            </div>
        </div>
    `;
    
    // Seção de Veículos
    if (vehicles.length > 0) {
        html += `
            <div class="vehicles-section">
                <h4><i class="fas fa-car"></i> Veículos do Cidadão (${vehicles.length})</h4>
                <div class="vehicles-list">
        `;
        
        vehicles.forEach(vehicle => {
            const statusClass = vehicle.isArrested ? 'arrested' : 
                               vehicle.isRental ? 'rental' : 
                               vehicle.needsTax ? 'tax-due' : 
                               vehicle.isDismantled ? 'dismantled' : 'normal';
            
            const statusText = vehicle.isArrested ? 'APREENDIDO' : 
                              vehicle.isRental ? 'ALUGADO' : 
                              vehicle.needsTax ? 'IMPOSTO VENCIDO' : 
                              vehicle.isDismantled ? 'DESMANCHE' : 'NORMAL';
            
            html += `
                <div class="vehicle-item ${statusClass}">
                    <div class="vehicle-header">
                        <div class="vehicle-plate">${vehicle.plate}</div>
                        <span class="vehicle-status">${statusText}</span>
                    </div>
                    <div class="vehicle-details">
                        <p><strong>Modelo:</strong> ${vehicle.vehicle}</p>
                        <p><strong>Motor:</strong> ${vehicle.engine}/1000</p>
                        <p><strong>Carroceria:</strong> ${vehicle.body}/1000</p>
                        <p><strong>Combustível:</strong> ${vehicle.fuel}%</p>
                        <p><strong>Nitro:</strong> ${vehicle.nitro}%</p>
                    </div>
                </div>
            `;
        });
        
        html += `
                </div>
            </div>
        `;
    }
    
    // Seção de Prisões
    if (prisonRecords.length > 0) {
        html += `
            <div class="records-section">
                <h4><i class="fas fa-jail"></i> Histórico de Prisões (${prisonRecords.length})</h4>
                <div class="records-list">
        `;
        
        prisonRecords.forEach(record => {
            html += `
                <div class="record-item">
                    <div class="record-header">
                        <span class="record-date">${record.date || 'N/A'}</span>
                        <span class="record-services">${record.services || 0} meses</span>
                    </div>
                    <div class="record-details">
                        <p><strong>Multas:</strong> R$ ${record.fines || 0}</p>
                        <p><strong>Observações:</strong> ${record.text || 'N/A'}</p>
                    </div>
                </div>
            `;
        });
        
        html += '</div></div>';
    }
    
    // Seção de Multas
    if (fines.length > 0) {
        html += `
            <div class="fines-section">
                <h4><i class="fas fa-money-bill"></i> Multas em Débito (${fines.length})</h4>
                <div class="fines-list">
        `;
        
        fines.forEach(fine => {
            html += `
                <div class="fine-item">
                    <div class="fine-header">
                        <span class="fine-value">R$ ${fine.Value || 0}</span>
                        <span class="fine-date">${fine.Date || 'N/A'} - ${fine.Hour || 'N/A'}</span>
                    </div>
                    <div class="fine-details">
                        <p><strong>Nome:</strong> ${fine.Name || 'N/A'}</p>
                        <p><strong>Motivo:</strong> ${fine.Message || 'N/A'}</p>
                    </div>
                </div>
            `;
        });
        
        html += '</div></div>';
    }
    
    // Seção de Mandados
    if (warrants.length > 0) {
        html += `
            <div class="warrants-section">
                <h4><i class="fas fa-search-location"></i> Mandados Ativos (${warrants.length})</h4>
                <div class="warrants-list">
        `;
        
        warrants.forEach(warrant => {
            html += `
                <div class="warrant-item">
                    <div class="warrant-header">
                        <span class="warrant-reason">${warrant.reason || 'N/A'}</span>
                        <span class="warrant-date">${warrant.timeStamp || 'N/A'}</span>
                    </div>
                    <div class="warrant-details">
                        <p><strong>Oficial:</strong> ${warrant.nidentity || 'N/A'}</p>
                    </div>
                </div>
            `;
        });
        
        html += '</div></div>';
    }
    
    // Seção de Portes
    if (ports.length > 0) {
        html += `
            <div class="ports-section">
                <h4><i class="fas fa-gun"></i> Portes de Armas (${ports.length})</h4>
                <div class="ports-list">
        `;
        
        ports.forEach(port => {
            html += `
                <div class="port-item">
                    <div class="port-header">
                        <span class="port-serial">Serial: ${port.serial || 'N/A'}</span>
                        <span class="port-date">${port.date || 'N/A'}</span>
                    </div>
                    <div class="port-details">
                        <p><strong>Tipo:</strong> ${port.portType || 'N/A'}</p>
                        <p><strong>Exame:</strong> ${port.exam || 'N/A'}</p>
                        <p><strong>Oficial:</strong> ${port.nidentity || 'N/A'}</p>
                    </div>
                </div>
            `;
        });
        
        html += '</div></div>';
    }
    
    console.log('=== FINALIZANDO DISPLAY COMPLETE SEARCH RESULTS ===');
    console.log('HTML gerado:', html);
    console.log('Aplicando HTML ao searchResults...');
    $('#searchResults').html(html);
    console.log('✅ HTML aplicado com sucesso!');
}

// =============================================================================
// FUNÇÕES DE MULTAS
// =============================================================================

// Multa
function handleFineSubmit(e) {
    e.preventDefault();
    
    const data = {
        passport: $('#finePassport').val(),
        fines: $('#fineAmount').val(),
        text: $('#fineText').val(),
        license: $('#fineLicense').val(),
        article: $('#fineArticle').val(),
        infraction: $('#fineInfraction').val(),
        description: $('#fineDescription').val()
    };
    
    if (!data.passport || !data.fines || !data.article || !data.infraction) {
        showNotification('Por favor, selecione uma infração do código penal e preencha o passaporte.', 'error');
        return;
    }
    
    $.post('https://mdt/initFine', JSON.stringify(data));
    $('#fineForm')[0].reset();
    showNotification('Multa aplicada com sucesso!', 'success');
}

// Variáveis globais para controle dos artigos selecionados
let selectedArticles = [];
let totalFine = 0;
let totalPrisonTime = 0;

// Função para carregar os artigos no dropdown
function loadPrisonArticles() {
    const dropdownMenu = $('#articleDropdownMenu');
    dropdownMenu.empty();
    
    CP.codigopenal.forEach(article => {
        if (article.categoria === 'pena') {
            const dropdownItem = $(`
                <div class="dropdown-item" data-value="${article.id}">
                    <strong>${article.artigo}</strong> - ${article.nome}
                    <div style="font-size: 12px; color: #b0b0b0; margin-top: 2px;">
                        Multa: $${article.multa.toLocaleString()} | Prisão: ${article.tempoPrisao} meses
                    </div>
                </div>
            `);
            dropdownMenu.append(dropdownItem);
        }
    });
}

// Função para calcular totais
function calculatePrisonTotals() {
    totalFine = 0;
    totalPrisonTime = 0;
    
    selectedArticles.forEach(articleId => {
        const article = CP.codigopenal.find(a => a.id == articleId);
        if (article) {
            totalFine += article.multa;
            totalPrisonTime += article.tempoPrisao;
        }
    });
    
    // Aplicar limites máximos
    if (totalPrisonTime > 250) {
        totalPrisonTime = 250;
    }
    if (totalFine > 150000) {
        totalFine = 150000;
    }
    
    // Aplicar desconto de 30% se marcado
    const discountSwitch = $('#prisonFineDiscountSwitch').is(':checked');
    if (discountSwitch) {
        totalFine = Math.floor(totalFine * 0.7);
        totalPrisonTime = Math.floor(totalPrisonTime * 0.7);
    }
    
    // Atualizar campos
    $('#prisonFinePrisonTime').val(totalPrisonTime);
    $('#prisonFineAmountFinal').val(totalFine);
}

// Função para lidar com seleção de artigos no dropdown
function handlePrisonArticleChange(articleId) {
    // Converter para string para garantir comparação correta
    const articleIdStr = String(articleId);
    
    if (articleId && !selectedArticles.some(id => String(id) === articleIdStr)) {
        selectedArticles.push(articleIdStr);
        updateSelectedArticlesDisplay();
        calculatePrisonTotals();
    }
}

// Função para atualizar a exibição dos artigos selecionados
function updateSelectedArticlesDisplay() {
    const container = $('#selectedArticlesContainer');
    const box = $('#selectedArticlesBox');
    
    if (selectedArticles.length === 0) {
        container.hide();
        box.empty(); // Garantir que a caixa seja limpa
        // Forçar o esconder com CSS inline
        container.css('display', 'none');
        return;
    }
    
    container.show();
    box.empty();
    
    selectedArticles.forEach(articleId => {
        const article = CP.codigopenal.find(a => a.id == articleId);
        if (article) {
            const articleElement = $(`
                <div class="selected-article-item">
                    <div class="article-info">
                        <strong>${article.artigo}</strong> - ${article.nome}
                        <div class="article-details">
                            <span class="article-multa">Multa: $${article.multa.toLocaleString()}</span>
                            <span class="article-prisao">Prisão: ${article.tempoPrisao} meses</span>
                        </div>
                    </div>
                    <button class="remove-article-btn" data-article-id="${articleId}">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `);
            box.append(articleElement);
        }
    });
    
    // Forçar a exibição da caixa
    container.css('display', 'block');
}

// Função para remover um artigo selecionado
function removeSelectedArticle(articleId) {
    // Converter para string para garantir comparação correta
    const articleIdStr = String(articleId);
    selectedArticles = selectedArticles.filter(id => String(id) !== articleIdStr);
    
    updateSelectedArticlesDisplay();
    calculatePrisonTotals();
    
    // Se não há mais artigos, esconder a caixa
    if (selectedArticles.length === 0) {
        $('#selectedArticlesContainer').hide();
        $('#selectedArticlesContainer').css('display', 'none');
    }
}

// Função para lidar com mudanças no switch de desconto
function handlePrisonDiscountChange() {
    calculatePrisonTotals();
}

function handlePrisonFineSubmit(e) {
    e.preventDefault();
    
    if (!selectedArticles.length) {
        showNotification('Por favor, selecione pelo menos um artigo.', 'error');
        return;
    }
    
    const data = {
        passport: $('#prisonFinePassport').val(),
        fines: totalFine,
        text: $('#prisonFineDescription').val(),
        license: $('#prisonFineDescription').val(),
        articles: selectedArticles,
        prisonTime: totalPrisonTime,
        discountApplied: $('#prisonFineDiscountSwitch').is(':checked')
    };
    
    if (!data.passport || !data.fines || !data.prisonTime) {
        showNotification('Por favor, preencha todos os campos obrigatórios.', 'error');
        return;
    }
    
    $.post('https://mdt/initPrisonFine', JSON.stringify(data));
    $('#prisonFineForm')[0].reset();
    selectedArticles = [];
    totalFine = 0;
    totalPrisonTime = 0;
    $('#selectedArticlesContainer').hide();
    $('#selectedArticlesBox').empty();
    showNotification('Multa com prisão aplicada com sucesso!', 'success');
}

// =============================================================================
// FUNÇÕES DE MANDADOS
// =============================================================================

// Carregar mandados
function loadWarrants() {
    $.post('https://mdt/getWarrants', JSON.stringify({}), function(response) {
        if (response.result) {
            displayWarrants(response.result);
        }
    });
}

// Exibir mandados
function displayWarrants(warrants) {
    let html = '';
    
    if (warrants.length === 0) {
        html = '<p class="no-data">Nenhum mandado encontrado.</p>';
    } else {
        warrants.forEach(warrant => {
            html += `
                <div class="warrant-card">
                    <div class="warrant-header">
                        <h4>${warrant.identity}</h4>
                        <button class="delete-btn" onclick="deleteWarrant(${warrant.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                    <p><strong>Motivo:</strong> ${warrant.reason}</p>
                    <p><strong>Data:</strong> ${warrant.timeStamp}</p>
                    <p><strong>Status:</strong> ${warrant.status}</p>
                </div>
            `;
        });
    }
    
    $('#warrantsList').html(html);
}

// Deletar mandado
function deleteWarrant(id) {
    showConfirmModal(
        'Deletar Mandado',
        'Tem certeza que deseja deletar este mandado?',
        () => {
            $.post('https://mdt/deleteWarrant', JSON.stringify({ id: id }));
            loadWarrants();
            showNotification('Mandado deletado com sucesso!', 'success');
        }
    );
}

// =============================================================================
// FUNÇÕES DE PORTES
// =============================================================================

// Carregar portes
function loadAllPorts() {
    $.post('https://mdt/getAllPorts', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            displayAllPorts(response.result.ports);
        }
    });
}

// Exibir portes
function displayAllPorts(ports) {
    const container = $('#portsList');
    container.empty();
    
    if (ports && ports.length > 0) {
        ports.forEach(port => {
            const portElement = $(`
                <div class="port-card">
                    <div class="port-header">
                        <h4>Serial: ${port.serial || 'N/A'}</h4>
                        <button class="delete-btn" onclick="deletePort(${port.id})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    <p><strong>Tipo:</strong> ${port.portType || 'N/A'}</p>
                    <p><strong>Exame:</strong> ${port.exam || 'N/A'}</p>
                    <p><strong>Data:</strong> ${port.date || 'N/A'}</p>
                    <p><strong>Oficial:</strong> ${port.nidentity || 'N/A'}</p>
                </div>
            `);
            container.append(portElement);
        });
    } else {
        container.html('<p class="no-data">Nenhum porte encontrado.</p>');
    }
}

// Deletar porte
function deletePort(id) {
    showConfirmModal(
        'Deletar Porte',
        'Tem certeza que deseja deletar este porte?',
        () => {
            $.post('https://mdt/deletePort', JSON.stringify({ id: id }));
            loadAllPorts();
            showNotification('Porte deletado com sucesso!', 'success');
        }
    );
}

// =============================================================================
// FUNÇÕES DE RELATÓRIOS
// =============================================================================

// Carregar relatórios
function loadAllReports() {
    $.post('https://mdt/getAllReports', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            displayAllReports(response.result.reports);
        }
    });
}

// Exibir relatórios
function displayAllReports(reports) {
    const container = $('#reportsList');
    container.empty();
    
    if (reports && reports.length > 0) {
        reports.forEach(report => {
            const reportElement = $(`
                <div class="report-card">
                    <div class="report-header">
                        <h4>${report.title || 'Sem título'}</h4>
                        <span class="report-status ${report.status}">${report.status}</span>
                        </div>
                    <p><strong>Autor:</strong> ${report.author || 'N/A'}</p>
                    <p><strong>Data:</strong> ${report.date || 'N/A'}</p>
                    <p><strong>Conteúdo:</strong> ${report.content || 'N/A'}</p>
                    </div>
            `);
            container.append(reportElement);
        });
    } else {
        container.html('<p class="no-data">Nenhum relatório encontrado.</p>');
    }
}

// =============================================================================
// FUNÇÕES DE VEÍCULOS
// =============================================================================

// Carregar veículos
function loadAllVehicles() {
    $.post('https://mdt/getAllVehicles', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            displayAllVehicles(response.result.vehicles);
        }
    });
}

// Exibir veículos
function displayAllVehicles(vehicles) {
    const container = $('#vehiclesList');
    container.empty();
    
    if (vehicles && vehicles.length > 0) {
        vehicles.forEach(vehicle => {
            const vehicleElement = $(`
                <div class="vehicle-card">
                    <div class="vehicle-header">
                        <h4>${vehicle.plate || 'N/A'}</h4>
                        <span class="vehicle-status ${vehicle.status}">${vehicle.status}</span>
                    </div>
                    <p><strong>Modelo:</strong> ${vehicle.model || 'N/A'}</p>
                    <p><strong>Proprietário:</strong> ${vehicle.owner || 'N/A'}</p>
                    <p><strong>Motivo:</strong> ${vehicle.reason || 'N/A'}</p>
                </div>
            `);
            container.append(vehicleElement);
        });
    } else {
        container.html('<p class="no-data">Nenhum veículo apreendido encontrado.</p>');
    }
}

// =============================================================================
// FUNÇÕES DE AVISOS
// =============================================================================

// Carregar avisos
function loadAnnouncements() {
    $.post('https://mdt/getAnnouncements', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            displayAnnouncements(response.result.announcements);
        }
    });
}

// Exibir avisos
function displayAnnouncements(announcements) {
    const container = $('#announcementsList');
    container.empty();
    
    if (announcements && announcements.length > 0) {
        announcements.forEach(announcement => {
            const announcementElement = $(`
                <div class="announcement-card">
                    <div class="announcement-header">
                        <h4>${announcement.title || 'Sem título'}</h4>
                        <span class="announcement-date">${announcement.date || 'N/A'}</span>
                        </div>
                    <p>${announcement.content || 'N/A'}</p>
                    </div>
            `);
            container.append(announcementElement);
        });
        } else {
        container.html('<p class="no-data">Nenhum aviso encontrado.</p>');
    }
}

// =============================================================================
// FUNÇÕES DE DASHBOARD
// =============================================================================

// Carregar dados do dashboard
function loadDashboardData() {
    $.post('https://mdt/getDashboardStats', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            updateDashboardStats(response.result.stats);
        }
    });
}

// Atualizar estatísticas do dashboard
function updateDashboardStats(stats) {
    if (stats) {
        $('#prisonCount').text(stats.prisons || 0);
        $('#fineCount').text(stats.fines || 0);
        $('#warrantCount').text(stats.warrants || 0);
        $('#vehicleCount').text(stats.vehicles || 0);
    }
}

// =============================================================================
// FUNÇÕES DE CARREGAMENTO DE DADOS
// =============================================================================

// Função para carregar todas as multas
function loadAllFines() {
    $.post('https://mdt/getAllFines', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            displayAllFines(response.result.fines);
        }
    });
}

// Função para exibir todas as multas
function displayAllFines(fines) {
    const container = $('#finesList');
    container.empty();
    
    if (fines && fines.length > 0) {
    fines.forEach(fine => {
            const fineElement = $(`
            <div class="fine-item">
                <div class="fine-header">
                        <span class="fine-passport">Passaporte: ${fine.Passport}</span>
                        <span class="fine-value">R$ ${fine.Value || 0}</span>
                </div>
                <div class="fine-details">
                        <div class="fine-name">${fine.Name || 'N/A'}</div>
                        <div class="fine-date">${fine.Date || 'N/A'} - ${fine.Hour || 'N/A'}</div>
                </div>
            </div>
        `);
            container.append(fineElement);
        });
        } else {
        container.html('<p class="no-data">Nenhuma multa encontrada.</p>');
    }
}

// Função para carregar multas com prisão
function loadAllPrisonFines() {
    $.post('https://mdt/getAllPrisonFines', JSON.stringify({}), function(response) {
        if (response.result && response.result.success) {
            displayAllPrisonFines(response.result.fines);
        }
    });
}

// Função para exibir multas com prisão
function displayAllPrisonFines(fines) {
    const container = $('#prisonFinesList');
    container.empty();
    
    if (fines && fines.length > 0) {
        fines.forEach(fine => {
            const fineElement = $(`
            <div class="fine-item">
                <div class="fine-header">
                        <span class="fine-passport">Passaporte: ${fine.Passport}</span>
                        <span class="fine-value">R$ ${fine.Value || 0}</span>
                </div>
                <div class="fine-details">
                        <div class="fine-name">${fine.Name || 'N/A'}</div>
                        <div class="fine-date">${fine.Date || 'N/A'} - ${fine.Hour || 'N/A'}</div>
                        <div class="fine-prison">Prisão: ${fine.PrisonTime || 0} meses</div>
                </div>
            </div>
            `);
            container.append(fineElement);
        });
    } else {
        container.html('<p class="no-data">Nenhuma multa com prisão encontrada.</p>');
    }
}

// =============================================================================
// FUNÇÕES AUXILIARES
// =============================================================================

// Mostrar notificação
function showNotification(message, type = 'info') {
    const notification = $(`
        <div class="notification ${type}">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
            <span>${message}</span>
            </div>
        `);
    
    $('body').append(notification);
    
    setTimeout(() => {
        notification.fadeOut(() => {
            notification.remove();
        });
    }, 3000);
}

// Mostrar modal de confirmação
function showConfirmModal(title, message, onConfirm) {
    $('#confirmModalTitle').text(title);
    $('#confirmModalMessage').text(message);
    $('#confirmModal').show();
    
    $('#confirmOk').off('click').on('click', function() {
        $('#confirmModal').hide();
        if (onConfirm) onConfirm();
    });
    
    $('#confirmCancel').off('click').on('click', function() {
        $('#confirmModal').hide();
    });
}

// Limpar registros de prisão
function cleanPrisonRecords(passport) {
    showConfirmModal(
        'Limpar Registros',
        'Tem certeza que deseja limpar todos os registros de prisão deste cidadão?',
        () => {
            $.post('https://mdt/cleanPrisonRecords', JSON.stringify({ passport: passport }));
            showNotification('Registros de prisão limpos com sucesso!', 'success');
        }
    );
}

// =============================================================================
// EVENT LISTENERS
// =============================================================================

$(document).ready(function() {
    console.log('MDT JavaScript loaded successfully');
    
    // Login form
    $('#loginForm').on('submit', handleLogin);
    
    // Navigation
    $('.nav-item').on('click', function() {
        const section = $(this).data('section');
        navigateToSection(section);
    });
    
    // Close button
    $('#closeBtn').on('click', closeMDT);
    
    // Search button
    $('#searchBtn').on('click', performSearch);
    
    // Forms
    $('#fineForm').on('submit', handleFineSubmit);
    $('#prisonFineForm').on('submit', handlePrisonFineSubmit);
    
    // Modal close
    $('#modalClose, #citizenRecordsClose').on('click', function() {
        $('#modalOverlay, #citizenRecordsModal').hide();
    });
    
    // Confirm modal
    $('#confirmCancel').on('click', function() {
        $('#confirmModal').hide();
    });
    
    // Refresh buttons
    $('#refreshFinesBtn').on('click', loadAllFines);
    $('#refreshPrisonFinesBtn').on('click', loadAllPrisonFines);
    
    // Event listeners para a nova funcionalidade de prisão
    $('#prisonFineDiscountSwitch').on('change', handlePrisonDiscountChange);
    
    // Event listeners para o dropdown de artigos
    $('#articleDropdownToggle').on('click', function(e) {
        e.stopPropagation();
        const dropdownMenu = $('#articleDropdownMenu');
        const isOpen = dropdownMenu.hasClass('show');
        
        if (isOpen) {
            // Fechar dropdown
            dropdownMenu.removeClass('show');
            $(this).removeClass('active');
        } else {
            // Abrir dropdown
            dropdownMenu.addClass('show');
            $(this).addClass('active');
        }
    });
    
    // Fechar dropdown quando clicar fora
    $(document).on('click', function(e) {
        if (!$(e.target).closest('.dropdown-container').length) {
            $('#articleDropdownMenu').removeClass('show');
            $('#articleDropdownToggle').removeClass('active');
        }
    });
    
    // Selecionar artigo do dropdown
    $(document).on('click', '.dropdown-item', function(e) {
        e.stopPropagation();
        const articleId = $(this).data('value');
        handlePrisonArticleChange(articleId);
        
        // Fechar dropdown após seleção
        $('#articleDropdownMenu').removeClass('show');
        $('#articleDropdownToggle').removeClass('active');
    });
    
    // Event listener delegado para o botão de remover artigos
    $(document).on('click', '.remove-article-btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const articleId = $(this).data('article-id');
        if (articleId) {
            removeSelectedArticle(articleId);
        }
    });
    
    // Carregar artigos quando a seção de prisão for aberta
    $('.nav-item[data-section="prison"]').on('click', function() {
        setTimeout(() => {
            loadPrisonArticles();
        }, 100);
    });
    
    // Carregar artigos quando o MDT for inicializado
    loadPrisonArticles();
    
    // Penal code buttons
    $('#openPenalCodeBtn').on('click', function() {
        // Implementar abertura do código penal
        showNotification('Funcionalidade do código penal será implementada em breve.', 'info');
    });
    
    // Botão do código penal removido - agora os artigos são selecionados diretamente no select
    
    // Add buttons
    $('#addWarrantBtn').on('click', function() {
        // Implementar adição de mandado
        showNotification('Funcionalidade de adicionar mandado será implementada em breve.', 'info');
    });
    
    $('#addPortBtn').on('click', function() {
        // Implementar adição de porte
        showNotification('Funcionalidade de adicionar porte será implementada em breve.', 'info');
    });
    
    $('#addReportBtn').on('click', function() {
        // Implementar adição de relatório
        showNotification('Funcionalidade de adicionar relatório será implementada em breve.', 'info');
    });
    
    $('#addVehicleBtn').on('click', function() {
        // Implementar apreensão de veículo
        showNotification('Funcionalidade de apreender veículo será implementada em breve.', 'info');
    });
    
    $('#addAnnouncementBtn').on('click', function() {
        // Implementar adição de aviso
        showNotification('Funcionalidade de adicionar aviso será implementada em breve.', 'info');
    });
    
    $('#addAnnouncementSectionBtn').on('click', function() {
        // Implementar adição de aviso na seção
        showNotification('Funcionalidade de adicionar aviso será implementada em breve.', 'info');
    });
    
    // Service toggle
    $('#serviceToggle').on('click', function() {
        $.post('https://mdt/toggleService', JSON.stringify({}), function(response) {
            if (response && typeof response.inService !== 'undefined') {
                setServiceStatus(!!response.inService);
            }
        });
    });
    
    // Enter key on search
    $('#searchPassport').on('keypress', function(e) {
        if (e.which === 13) {
            performSearch();
        }
    });
    
    // Limpar campo de busca ao carregar
    $('#searchPassport').val('');
    
    // Verificar se há algum valor sendo definido automaticamente
    console.log('Valor inicial do campo de busca:', $('#searchPassport').val());
    
    // Add CSS styles for new sections
    $('<style>')
        .text(`
            .user-card, .record-item, .warrant-item, .warrant-card, .port-card, .report-card, .vehicle-card, .announcement-card {
                background: #2a2a30;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 15px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
            .user-header h3 {
                color: #ffffff;
            }
            .info-item {
                background: rgba(255, 255, 255, 0.05);
                padding: 10px;
                border-radius: 5px;
                border-left: 3px solid #e74c3c;
                color: #e0e0e0;
            }
            .info-item strong {
                color: #ffffff;
            }
            .vehicle-details p {
                margin: 5px 0;
                font-size: 14px;
                color: #e0e0e0;
            }
            .user-stats {
                display: flex;
                flex-wrap: wrap;
                gap: 15px;
                margin-bottom: 20px;
            }
            .stat-item {
                color: #e0e0e0;
            }
            .stat-label {
                color: #b0b0b0;
            }
            .stat-value {
                color: #ffffff;
            }
            .stat-count {
                color: #7f8c8d;
            }
            
            .info-section {
                margin-bottom: 25px;
                padding: 20px;
                background: rgba(255, 255, 255, 0.02);
                border-radius: 10px;
                border: 1px solid rgba(255, 255, 255, 0.05);
            }
            
            .info-section h4 {
                color: #ffffff;
                margin-bottom: 15px;
                font-size: 16px;
                font-weight: 600;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .info-section h4 i {
                color: #e74c3c;
            }
            
            .vehicles-section {
                margin-top: 20px;
                padding: 20px;
                background: rgba(255, 255, 255, 0.02);
                border-radius: 10px;
                border: 1px solid rgba(255, 255, 255, 0.05);
            }
            
            .vehicles-section h4 {
                color: #ffffff;
                margin-bottom: 15px;
                font-size: 16px;
                font-weight: 600;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .vehicles-section h4 i {
                color: #e74c3c;
            }
        `)
        .appendTo('head');
});

// =============================================================================
// NUI CALLBACKS
// =============================================================================

// Receber notificações do servidor
window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('NUI Message received:', data);
    
    if (data.action === 'openMDT') {
        console.log('Opening MDT...');
        $('#loginModal').css('display', 'flex').show();
        $('#mdtOverlay').hide();
        $('#mdtInterface').hide();
        console.log('MDT opened successfully');
    } else if (data.action === 'closeMDT') {
        console.log('Closing MDT...');
        $('#loginModal').hide();
        $('#mdtOverlay').hide();
        $('#mdtInterface').hide();
    } else if (data.action === 'test') {
        console.log('Test message received:', data.message);
        alert('NUI está funcionando! Mensagem: ' + data.message);
    } else if (data.type === 'showNotification') {
        showNotification(data.message, data.notificationType);
    } else if (data.type === 'updateServiceStatus') {
        setServiceStatus(!!data.inService);
    } else if (data.action === 'updateFines') {
        // Atualização em tempo real de multas pendentes
        try {
            const targetPassport = data && data.data && data.data.passport ? String(data.data.passport) : null;
            const addedAmount = data && data.data && data.data.amount ? Number(data.data.amount) : 0;
            if (!targetPassport || !currentViewedCitizenPassport) return;
            if (targetPassport !== currentViewedCitizenPassport) return;

            // Atualizar valor em "Informações Financeiras"
            const $amountEl = $('#financePendingFinesAmount');
            if ($amountEl.length) {
                const currentText = $amountEl.text() || 'R$ 0';
                const currentVal = Number(currentText.replace(/[^0-9]/g, '')) || 0;
                const newVal = currentVal + (Number(addedAmount) || 0);
                $amountEl.text('R$ ' + newVal.toLocaleString());
            }

            // Atualizar contador de multas, se existir
            const $countEl = $('#financePendingFinesCount');
            if ($countEl.length) {
                const match = ($countEl.text() || '').match(/(\d+)/);
                const currentCount = match ? Number(match[1]) : 0;
                const newCount = currentCount + 1;
                $countEl.text('(' + newCount + ' multas)');
            }

            // Atualizar também os dados do bloco de estatísticas, se estiver visível
            const $statsAmount = $('.stat-value.fines-total');
            if ($statsAmount.length) {
                const statsText = $statsAmount.text() || 'R$ 0';
                const statsVal = Number(statsText.replace(/[^0-9]/g, '')) || 0;
                const newStatsVal = statsVal + (Number(addedAmount) || 0);
                $statsAmount.text('R$ ' + newStatsVal.toLocaleString());
            }
            const $statsCount = $('.stat-count');
            if ($statsCount.length) {
                const match2 = ($statsCount.first().text() || '').match(/(\d+)/);
                const currentCount2 = match2 ? Number(match2[1]) : 0;
                const newCount2 = currentCount2 + 1;
                $statsCount.first().text('(' + newCount2 + ' multas)');
            }
        } catch (e) {
            console.error('Erro ao atualizar multas em tempo real:', e);
        }
    }
});
