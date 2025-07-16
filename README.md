# AI Legal Decision-Making System

A comprehensive AI-powered legal system that simulates legal proceedings with AI agents acting as prosecutor, defense attorney, cross-examiner, and judge. The system can analyze evidence, conduct legal research, and render informed verdicts.

## 🚀 Features

- **AI Legal Agents**: Four specialized AI agents with distinct roles
  - **Prosecutor**: Builds the case for the prosecution
  - **Defense Attorney**: Represents the defendant's interests
  - **Cross-Examiner**: Conducts strategic questioning
  - **Judge**: Makes impartial decisions and renders verdicts

- **Legal Research**: Integration with legal databases
  - Harvard Caselaw Access Project integration
  - Case law search and citation verification
  - Precedent analysis and legal reasoning

- **Case Management**: Complete case lifecycle management
  - Case creation and tracking
  - Party and evidence management
  - Real-time proceeding updates

- **Modern Web Interface**: Responsive, professional UI
  - Real-time updates via WebSocket
  - Interactive case dashboard
  - Chat-style legal proceedings

## 📋 Prerequisites

- Python 3.8 or higher
- OpenAI API key (required)
- Anthropic API key (recommended)
- Harvard Caselaw API key (optional)

## ⚡ Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ai-legal-system
python setup.py
```

### 2. Configure API Keys

Edit the `.env` file and add your API keys:

```bash
# Required
OPENAI_API_KEY=your_openai_api_key_here

# Recommended for better legal reasoning
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional for legal research
HARVARD_CASELAW_API_KEY=your_harvard_api_key_here
```

### 3. Run the Application

```bash
# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Start the server
python main.py
```

### 4. Access the Application

Open your browser and go to: `http://localhost:8000`

## 🎯 Usage Guide

### Creating a Case

1. **Click "New Case"** or **"Demo Case"** for a sample
2. **Fill in case details**: title, description, and type
3. **Add parties**: plaintiff, defendant, witnesses
4. **Submit evidence**: documents, testimony, digital evidence
5. **Start proceedings** to begin AI-powered legal analysis

### Legal Proceedings

Once you start proceedings, the AI agents will:

1. **Opening Arguments**: Prosecutor and defense present their cases
2. **Evidence Analysis**: Each piece of evidence is analyzed by both sides
3. **Cross-Examination**: Strategic questioning of parties and witnesses
4. **Final Verdict**: Judge renders decision based on all evidence and arguments

### Real-Time Interaction

- **Chat Interface**: Communicate with AI agents in real-time
- **WebSocket Updates**: Receive instant updates on case progress
- **Role Selection**: Choose to speak as user, prosecutor, defense, or judge

## 🏗️ System Architecture

### Core Components

```
├── main.py                 # FastAPI application and endpoints
├── models.py              # Pydantic models for data structures
├── config.py              # Configuration management
├── legal_agents.py        # AI agent implementations
├── legal_database.py      # Legal research and database integration
├── templates/             # HTML templates
├── static/               # CSS, JavaScript, and assets
└── requirements.txt      # Python dependencies
```

### AI Agent Architecture

Each AI agent is implemented with:
- **Specialized prompts** for legal reasoning
- **Context-aware responses** based on case data
- **API integration** with OpenAI and Anthropic
- **Legal research capabilities** for precedent analysis

### Data Models

- **LegalCase**: Main case entity with parties, evidence, and proceedings
- **Party**: Plaintiff, defendant, or witness information
- **Evidence**: Documents, testimony, and digital evidence
- **Verdict**: Final decision with reasoning and confidence scores

## 🔧 API Reference

### Case Management

- `POST /api/cases` - Create new case
- `GET /api/cases` - List all cases
- `GET /api/cases/{id}` - Get specific case
- `DELETE /api/cases/{id}` - Delete case

### Legal Proceedings

- `POST /api/cases/{id}/start-proceedings` - Start automated proceedings
- `POST /api/cases/{id}/cross-examine` - Begin cross-examination
- `GET /api/cases/{id}/verdict` - Get case verdict

### Legal Research

- `POST /api/research/legal-question` - Research legal questions
- `POST /api/research/case-law` - Search case law
- `POST /api/research/verify-citation` - Verify legal citations

### WebSocket

- `WS /ws/{case_id}` - Real-time case updates

## 🧪 Testing

### Sample Case

Use the "Demo Case" button to create a sample contract dispute case with:
- Pre-populated parties (plaintiff and defendant)
- Sample evidence (contract, emails, payment records)
- Ready for immediate proceedings

### Manual Testing

1. Create a case with relevant parties and evidence
2. Start proceedings and observe AI agent interactions
3. Test cross-examination features
4. Review final verdict and reasoning

## 🎨 Customization

### Adding New Agent Types

1. Create new agent class in `legal_agents.py`
2. Define specialized prompts and behaviors
3. Add to orchestrator workflow
4. Update UI to display new agent messages

### Integrating Additional Legal Databases

1. Add database client to `legal_database.py`
2. Implement search and retrieval methods
3. Update research engine to use new sources
4. Add configuration for API keys

### UI Customization

- Modify `templates/index.html` for layout changes
- Update `static/css/style.css` for styling
- Enhance `static/js/app.js` for new functionality

## 📊 Configuration Options

### Environment Variables

```bash
# AI Configuration
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
MAX_CONVERSATION_TURNS=50

# Legal Research
HARVARD_CASELAW_API_KEY=your_key_here
ENABLE_FACT_CHECKING=True
ENABLE_BIAS_DETECTION=True

# System Settings
DEBUG=True
HOST=0.0.0.0
PORT=8000
```

### Legal System Settings

- **MAX_CONVERSATION_TURNS**: Limit on case proceeding length
- **CASE_TIMEOUT_HOURS**: Maximum time for case resolution
- **EVIDENCE_UPLOAD_MAX_SIZE**: File size limit for evidence
- **ENABLE_BIAS_DETECTION**: AI bias detection in decisions

## 🛠️ Development

### Project Structure

```
ai-legal-system/
├── main.py                 # FastAPI application
├── config.py              # Configuration
├── models.py              # Data models
├── legal_agents.py        # AI agents
├── legal_database.py      # Legal research
├── templates/             # HTML templates
├── static/               # Frontend assets
├── requirements.txt      # Dependencies
├── setup.py              # Setup script
└── README.md             # This file
```

### Adding Features

1. **New Legal Agent**: Extend `BaseAgent` class
2. **Database Integration**: Add to `legal_database.py`
3. **API Endpoints**: Add to `main.py`
4. **UI Components**: Update templates and static files

### Testing

```bash
# Run tests
pytest

# Test specific components
python -m pytest tests/test_agents.py
python -m pytest tests/test_database.py
```

## 📖 Legal Considerations

### Disclaimer

This system is for educational and research purposes only. It should not be used for:
- Actual legal proceedings
- Professional legal advice
- Binding legal decisions
- Replacement of qualified legal counsel

### Ethical AI Use

- The system includes bias detection mechanisms
- Decisions are clearly marked as AI-generated
- Human oversight is recommended for all outputs
- Transparency in AI reasoning is maintained

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

### Common Issues

**API Keys Not Working**
- Verify keys are correctly set in `.env` file
- Check API key permissions and quotas
- Ensure no extra spaces or characters

**Installation Errors**
- Verify Python 3.8+ is installed
- Run `python setup.py` again
- Check virtual environment activation

**Performance Issues**
- Reduce `MAX_CONVERSATION_TURNS` for faster processing
- Use OpenAI for general responses, Claude for complex reasoning
- Consider implementing caching for legal research

### Getting Help

- Check the documentation in this README
- Review error logs in the console
- Open an issue on GitHub
- Contact the development team

## 🎯 Roadmap

### Near-term Features

- [ ] Advanced cross-examination workflows
- [ ] Integration with more legal databases
- [ ] Export case reports and verdicts
- [ ] Multi-language support

### Future Enhancements

- [ ] Machine learning for verdict prediction
- [ ] Integration with legal document templates
- [ ] Collaboration features for multiple users
- [ ] Mobile application development

---

Built with ❤️ for the legal technology community.