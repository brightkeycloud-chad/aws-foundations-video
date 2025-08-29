import pytest
from eventbridge_analyzer import EventAnalyzer


class TestEventAnalyzer:
    def test_analyze_event(self):
        analyzer = EventAnalyzer()
        event = {
            "source": "aws.ec2",
            "detail-type": "EC2 Instance State-change Notification",
            "account": "123456789012",
            "region": "us-east-1",
            "time": "2023-01-01T12:00:00Z",
            "detail": {"state": "running", "instance-id": "i-1234567890abcdef0"}
        }
        
        result = analyzer.analyze_event(event)
        
        assert result["source"] == "aws.ec2"
        assert result["detail_type"] == "EC2 Instance State-change Notification"
        assert result["account"] == "123456789012"
        assert result["region"] == "us-east-1"
        assert "state" in result["detail_keys"]
        assert "instance-id" in result["detail_keys"]