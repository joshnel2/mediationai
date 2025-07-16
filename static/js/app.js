// AI Legal System JavaScript Application

class LegalSystemApp {
    constructor() {
        this.apiBaseUrl = '/api';
        this.currentCase = null;
        this.websocket = null;
        this.init();
    }

    init() {
        this.loadCases();
        this.loadStats();
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Enter key for message input
        document.getElementById('messageInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.sendMessage();
            }
        });

        // Auto-refresh stats every 30 seconds
        setInterval(() => {
            this.loadStats();
        }, 30000);
    }

    // API Helper Methods
    async apiCall(endpoint, method = 'GET', data = null) {
        const config = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            },
        };

        if (data) {
            config.body = JSON.stringify(data);
        }

        try {
            const response = await fetch(`${this.apiBaseUrl}${endpoint}`, config);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error('API call failed:', error);
            this.showError('API call failed: ' + error.message);
            throw error;
        }
    }

    // Loading and Error Handling
    showLoading(message = 'Processing...') {
        const modal = new bootstrap.Modal(document.getElementById('loadingModal'));
        modal.show();
    }

    hideLoading() {
        const modal = bootstrap.Modal.getInstance(document.getElementById('loadingModal'));
        if (modal) {
            modal.hide();
        }
    }

    showError(message) {
        // Create and show error alert
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-danger alert-dismissible fade show';
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        
        document.body.insertBefore(alertDiv, document.body.firstChild);
        
        // Auto-dismiss after 5 seconds
        setTimeout(() => {
            alertDiv.remove();
        }, 5000);
    }

    showSuccess(message) {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-success alert-dismissible fade show';
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        
        document.body.insertBefore(alertDiv, document.body.firstChild);
        
        setTimeout(() => {
            alertDiv.remove();
        }, 3000);
    }

    // Case Management
    async loadCases() {
        try {
            const cases = await this.apiCall('/cases');
            this.displayCases(cases);
        } catch (error) {
            console.error('Failed to load cases:', error);
        }
    }

    displayCases(cases) {
        const casesList = document.getElementById('casesList');
        
        if (cases.length === 0) {
            casesList.innerHTML = '<p class="text-muted">No cases available</p>';
            return;
        }

        casesList.innerHTML = cases.map(case_ => `
            <div class="case-item ${this.currentCase?.id === case_.id ? 'active' : ''}" 
                 onclick="app.selectCase('${case_.id}')">
                <div class="case-title">${case_.title}</div>
                <div class="case-meta">
                    <span class="status-badge status-${case_.status}">${case_.status}</span>
                    <br>
                    <small>${new Date(case_.created_at).toLocaleDateString()}</small>
                </div>
            </div>
        `).join('');
    }

    async selectCase(caseId) {
        try {
            this.showLoading('Loading case...');
            const case_ = await this.apiCall(`/cases/${caseId}`);
            this.currentCase = case_;
            this.displayCase(case_);
            this.loadCaseDetails();
            this.connectWebSocket(caseId);
            this.hideLoading();
        } catch (error) {
            this.hideLoading();
            this.showError('Failed to load case');
        }
    }

    displayCase(case_) {
        document.getElementById('welcomeScreen').classList.add('d-none');
        document.getElementById('caseView').classList.remove('d-none');
        
        document.getElementById('caseTitle').textContent = case_.title;
        document.getElementById('caseDescription').textContent = case_.description;
        document.getElementById('caseStatus').textContent = case_.status;
        document.getElementById('caseStatus').className = `badge bg-secondary status-${case_.status}`;
        
        // Update case details
        document.getElementById('caseType').textContent = case_.case_type;
        document.getElementById('caseStatusDetail').textContent = case_.status;
        document.getElementById('caseCreated').textContent = new Date(case_.created_at).toLocaleDateString();
        document.getElementById('caseUpdated').textContent = new Date(case_.updated_at).toLocaleDateString();
        
        // Update cases list to show active case
        this.loadCases();
    }

    async loadCaseDetails() {
        if (!this.currentCase) return;

        try {
            await Promise.all([
                this.loadParties(),
                this.loadEvidence(),
                this.loadMessages(),
                this.loadVerdict()
            ]);
        } catch (error) {
            console.error('Failed to load case details:', error);
        }
    }

    async loadParties() {
        try {
            const parties = await this.apiCall(`/cases/${this.currentCase.id}/parties`);
            this.displayParties(parties);
            this.updateEvidenceSubmitters(parties);
        } catch (error) {
            console.error('Failed to load parties:', error);
        }
    }

    displayParties(parties) {
        const partiesList = document.getElementById('partiesList');
        
        if (parties.length === 0) {
            partiesList.innerHTML = '<p class="text-muted">No parties added yet</p>';
            return;
        }

        partiesList.innerHTML = parties.map(party => `
            <div class="party-item">
                <div class="party-name">${party.name}</div>
                <span class="party-type ${party.party_type}">${party.party_type}</span>
                <p class="party-description">${party.description || 'No description'}</p>
            </div>
        `).join('');
    }

    updateEvidenceSubmitters(parties) {
        const select = document.getElementById('evidenceSubmittedBy');
        select.innerHTML = '<option value="">Select party...</option>' + 
            parties.map(party => `<option value="${party.id}">${party.name}</option>`).join('');
    }

    async loadEvidence() {
        try {
            const evidence = await this.apiCall(`/cases/${this.currentCase.id}/evidence`);
            this.displayEvidence(evidence);
        } catch (error) {
            console.error('Failed to load evidence:', error);
        }
    }

    displayEvidence(evidence) {
        const evidenceList = document.getElementById('evidenceList');
        
        if (evidence.length === 0) {
            evidenceList.innerHTML = '<p class="text-muted">No evidence submitted yet</p>';
            return;
        }

        evidenceList.innerHTML = evidence.map(item => `
            <div class="evidence-item">
                <div class="evidence-title">${item.title}</div>
                <span class="evidence-type">${item.evidence_type}</span>
                <div class="evidence-description">${item.description}</div>
                <div class="evidence-content">${item.content}</div>
            </div>
        `).join('');
    }

    async loadMessages() {
        try {
            const messages = await this.apiCall(`/cases/${this.currentCase.id}/messages`);
            this.displayMessages(messages);
        } catch (error) {
            console.error('Failed to load messages:', error);
        }
    }

    displayMessages(messages) {
        const conversationHistory = document.getElementById('conversationHistory');
        
        if (messages.length === 0) {
            conversationHistory.innerHTML = '<p class="text-muted text-center">No proceedings yet. Add evidence and parties, then start proceedings.</p>';
            return;
        }

        conversationHistory.innerHTML = messages.map(msg => `
            <div class="message ${msg.role}">
                <div class="message-role">${msg.role}</div>
                <div class="message-content">${msg.content}</div>
                <div class="message-time">${new Date(msg.timestamp).toLocaleTimeString()}</div>
            </div>
        `).join('');
        
        // Scroll to bottom
        conversationHistory.scrollTop = conversationHistory.scrollHeight;
    }

    async loadVerdict() {
        try {
            const verdict = await this.apiCall(`/cases/${this.currentCase.id}/verdict`);
            this.displayVerdict(verdict);
        } catch (error) {
            // No verdict yet is expected
            if (error.message.includes('400')) {
                this.displayNoVerdict();
            } else {
                console.error('Failed to load verdict:', error);
            }
        }
    }

    displayVerdict(verdictResponse) {
        const verdictContainer = document.getElementById('verdictContainer');
        const verdict = verdictResponse.verdict;
        
        verdictContainer.innerHTML = `
            <div class="verdict-display">
                <div class="verdict-type ${verdict.verdict_type}">${verdict.verdict_type.replace('_', ' ').toUpperCase()}</div>
                <div class="verdict-confidence">Confidence: ${(verdict.confidence_score * 100).toFixed(1)}%</div>
                <div class="verdict-reasoning">${verdict.reasoning}</div>
                <div class="decision-factors">
                    <h6>Decision Factors:</h6>
                    ${verdict.decision_factors.map(factor => `
                        <div class="decision-factor">
                            <div class="factor-name">${factor.factor}</div>
                            <div class="factor-weight">Weight: ${(factor.weight * 100).toFixed(1)}%</div>
                            <div class="factor-reasoning">${factor.reasoning}</div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    displayNoVerdict() {
        const verdictContainer = document.getElementById('verdictContainer');
        verdictContainer.innerHTML = `
            <div class="text-center text-muted">
                <i class="fas fa-gavel fa-3x mb-3"></i>
                <h5>No Verdict Yet</h5>
                <p>Complete the legal proceedings to receive a verdict</p>
            </div>
        `;
    }

    // WebSocket Connection
    connectWebSocket(caseId) {
        if (this.websocket) {
            this.websocket.close();
        }

        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = `${protocol}//${window.location.host}/ws/${caseId}`;
        
        this.websocket = new WebSocket(wsUrl);
        
        this.websocket.onmessage = (event) => {
            const message = JSON.parse(event.data);
            this.handleWebSocketMessage(message);
        };

        this.websocket.onclose = () => {
            console.log('WebSocket connection closed');
        };

        this.websocket.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
    }

    handleWebSocketMessage(message) {
        if (message.type === 'case_update') {
            this.loadCaseDetails();
            this.showSuccess('Case updated: ' + message.message);
        }
    }

    // Statistics
    async loadStats() {
        try {
            const stats = await this.apiCall('/stats');
            document.getElementById('totalCases').textContent = stats.total_cases;
            document.getElementById('activeCases').textContent = stats.active_cases;
        } catch (error) {
            console.error('Failed to load stats:', error);
        }
    }

    // Actions
    async startProceedings() {
        if (!this.currentCase) return;

        try {
            this.showLoading('Starting legal proceedings...');
            await this.apiCall(`/cases/${this.currentCase.id}/start-proceedings`, 'POST');
            this.showSuccess('Legal proceedings started successfully');
            this.loadCaseDetails();
            this.hideLoading();
        } catch (error) {
            this.hideLoading();
            this.showError('Failed to start proceedings');
        }
    }

    async sendMessage() {
        if (!this.currentCase) return;

        const messageInput = document.getElementById('messageInput');
        const messageRole = document.getElementById('messageRole').value;
        const content = messageInput.value.trim();

        if (!content) return;

        try {
            await this.apiCall(`/cases/${this.currentCase.id}/messages`, 'POST', {
                role: messageRole,
                content: content
            });

            messageInput.value = '';
            this.loadMessages();
        } catch (error) {
            this.showError('Failed to send message');
        }
    }

    closeCaseView() {
        this.currentCase = null;
        if (this.websocket) {
            this.websocket.close();
            this.websocket = null;
        }
        
        document.getElementById('caseView').classList.add('d-none');
        document.getElementById('welcomeScreen').classList.remove('d-none');
        this.loadCases();
    }

    // Case Creation
    async createSampleCase() {
        try {
            this.showLoading('Creating sample case...');
            const result = await this.apiCall('/demo/create-sample-case');
            this.showSuccess('Sample case created successfully');
            this.loadCases();
            this.selectCase(result.case_id);
            this.hideLoading();
        } catch (error) {
            this.hideLoading();
            this.showError('Failed to create sample case');
        }
    }

    // Modal Functions
    showModal(modalId) {
        const modal = new bootstrap.Modal(document.getElementById(modalId));
        modal.show();
    }

    hideModal(modalId) {
        const modal = bootstrap.Modal.getInstance(document.getElementById(modalId));
        if (modal) {
            modal.hide();
        }
    }

    async submitNewCase() {
        const title = document.getElementById('newCaseTitle').value.trim();
        const description = document.getElementById('newCaseDescription').value.trim();
        const caseType = document.getElementById('newCaseType').value;

        if (!title || !description || !caseType) {
            this.showError('Please fill in all fields');
            return;
        }

        try {
            this.showLoading('Creating case...');
            const result = await this.apiCall('/cases', 'POST', {
                title: title,
                description: description,
                case_type: caseType
            });

            this.hideModal('createCaseModal');
            this.showSuccess('Case created successfully');
            this.loadCases();
            this.selectCase(result.case.id);
            this.hideLoading();

            // Clear form
            document.getElementById('createCaseForm').reset();
        } catch (error) {
            this.hideLoading();
            this.showError('Failed to create case');
        }
    }

    async submitNewParty() {
        if (!this.currentCase) return;

        const name = document.getElementById('partyName').value.trim();
        const partyType = document.getElementById('partyType').value;
        const description = document.getElementById('partyDescription').value.trim();

        if (!name || !partyType) {
            this.showError('Please fill in required fields');
            return;
        }

        try {
            await this.apiCall(`/cases/${this.currentCase.id}/parties`, 'POST', {
                name: name,
                party_type: partyType,
                description: description
            });

            this.hideModal('addPartyModal');
            this.showSuccess('Party added successfully');
            this.loadParties();

            // Clear form
            document.getElementById('addPartyForm').reset();
        } catch (error) {
            this.showError('Failed to add party');
        }
    }

    async submitNewEvidence() {
        if (!this.currentCase) return;

        const title = document.getElementById('evidenceTitle').value.trim();
        const evidenceType = document.getElementById('evidenceType').value;
        const description = document.getElementById('evidenceDescription').value.trim();
        const content = document.getElementById('evidenceContent').value.trim();
        const submittedBy = document.getElementById('evidenceSubmittedBy').value;

        if (!title || !evidenceType || !description || !content || !submittedBy) {
            this.showError('Please fill in all fields');
            return;
        }

        try {
            await this.apiCall(`/cases/${this.currentCase.id}/evidence`, 'POST', {
                title: title,
                evidence_type: evidenceType,
                description: description,
                content: content,
                submitted_by: submittedBy
            });

            this.hideModal('addEvidenceModal');
            this.showSuccess('Evidence added successfully');
            this.loadEvidence();

            // Clear form
            document.getElementById('addEvidenceForm').reset();
        } catch (error) {
            this.showError('Failed to add evidence');
        }
    }
}

// Global Functions (called from HTML)
function createNewCase() {
    app.showModal('createCaseModal');
}

function createSampleCase() {
    app.createSampleCase();
}

function startProceedings() {
    app.startProceedings();
}

function sendMessage() {
    app.sendMessage();
}

function closeCaseView() {
    app.closeCaseView();
}

function addParty() {
    app.showModal('addPartyModal');
}

function addEvidence() {
    app.showModal('addEvidenceModal');
}

function submitNewCase() {
    app.submitNewCase();
}

function submitNewParty() {
    app.submitNewParty();
}

function submitNewEvidence() {
    app.submitNewEvidence();
}

function showCrossExamination() {
    app.showSuccess('Cross-examination feature coming soon!');
}

function showLegalResearch() {
    app.showSuccess('Legal research feature coming soon!');
}

// Initialize the application
const app = new LegalSystemApp();