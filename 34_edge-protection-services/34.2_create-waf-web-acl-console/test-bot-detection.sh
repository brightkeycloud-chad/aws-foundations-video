#!/bin/bash

# Test script to demonstrate bot detection capabilities
# This script simulates different types of automated requests to test WAF Bot Control
# WARNING: Only use this against your own resources with proper authorization

set -e

echo "🤖 Bot Detection Test Script for AWS WAF Demo"
echo "=============================================="
echo ""

# Check if URL is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide a CloudFront distribution URL to test"
    echo "Usage: $0 <cloudfront-url>"
    echo "Example: $0 https://d1234567890.cloudfront.net"
    exit 1
fi

TARGET_URL="$1"

echo "🎯 Target URL: $TARGET_URL"
echo "⚠️  WARNING: Only test against your own resources!"
echo ""

# Function to make multiple requests and show results
make_request() {
    local description="$1"
    local user_agent="$2"
    local additional_headers="$3"
    local count=100
    
    echo "📡 Testing: $description (${count} requests)"
    echo "   User-Agent: $user_agent"
    
    local success_count=0
    local blocked_count=0
    local failed_count=0
    local other_count=0
    
    for i in $(seq 1 $count); do
        # Make the request and capture response
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nCONTENT_TYPE:%{content_type}\n" \
            -H "User-Agent: $user_agent" \
            $additional_headers \
            "$TARGET_URL" 2>/dev/null || echo "REQUEST_FAILED")
        
        # Extract HTTP code
        http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
        
        if [ "$http_code" = "403" ]; then
            ((blocked_count++))
        elif [ "$http_code" = "200" ]; then
            ((success_count++))
        elif [ -z "$http_code" ] || [ "$response" = "REQUEST_FAILED" ]; then
            ((failed_count++))
        else
            ((other_count++))
        fi
        
        # Show progress every 25 requests
        if [ $((i % 25)) -eq 0 ]; then
            echo "   Progress: $i/$count requests completed"
        fi
    done
    
    echo "   ✅ Results Summary:"
    echo "      - ALLOWED (200): $success_count requests"
    echo "      - BLOCKED (403): $blocked_count requests"
    echo "      - FAILED: $failed_count requests"
    echo "      - OTHER: $other_count requests"
    
    echo ""
    sleep 1
}

echo "🧪 Running bot detection tests..."
echo ""

# Test 1: Normal browser request (should be allowed)
make_request "Normal Browser Request" \
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

# Test 2: Python requests library (may be blocked)
make_request "Python Requests Library" \
    "python-requests/2.25.1"

# Test 3: Curl (may be blocked)
make_request "Curl Command Line Tool" \
    "curl/7.68.0"

# Test 4: Wget (may be blocked)
make_request "Wget Download Tool" \
    "Wget/1.20.3 (linux-gnu)"

# Test 5: Scrapy bot (likely blocked)
make_request "Scrapy Web Scraper" \
    "Scrapy/2.5.0 (+https://scrapy.org)"

# Test 6: Search engine bot (should be allowed)
make_request "Googlebot Search Engine" \
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

# Test 7: Social media bot (behavior depends on configuration)
make_request "Facebook Bot" \
    "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)"

# Test 8: Monitoring tool (may be blocked)
make_request "Monitoring Tool" \
    "UptimeRobot/2.0; http://www.uptimerobot.com/"

echo "🎉 Bot detection testing completed!"
echo ""
echo "📊 Understanding the Results:"
echo "   - HTTP 403 responses indicate Bot Control blocked the request"
echo "   - HTTP 200 responses indicate the request was allowed"
echo "   - Different user agents trigger different bot categories"
echo ""
echo "💡 Next Steps:"
echo "   1. Check CloudWatch metrics for bot detection statistics"
echo "   2. Review WAF logs to see detailed bot categorization"
echo "   3. Adjust Bot Control rules based on your application needs"
echo ""
echo "📚 Learn More:"
echo "   - AWS WAF Bot Control: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html"
echo "   - Bot Categories: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html#aws-managed-rule-groups-bot"
