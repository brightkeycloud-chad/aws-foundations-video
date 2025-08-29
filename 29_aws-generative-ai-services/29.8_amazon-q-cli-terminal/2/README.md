# EventBridge Event Analyzer

A Python application for analyzing events from Amazon EventBridge.

## Setup

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Usage

```python
from eventbridge_analyzer import EventAnalyzer

analyzer = EventAnalyzer()
result = analyzer.analyze_event(event_data)
```

## Testing

```bash
python -m pytest tests/
```