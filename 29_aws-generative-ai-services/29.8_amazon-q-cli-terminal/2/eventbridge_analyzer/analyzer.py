import json
from typing import Dict, Any


class EventAnalyzer:
    def analyze_event(self, event: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze an EventBridge event and return insights."""
        return {
            "source": event.get("source"),
            "detail_type": event.get("detail-type"),
            "account": event.get("account"),
            "region": event.get("region"),
            "time": event.get("time"),
            "detail_keys": list(event.get("detail", {}).keys())
        }