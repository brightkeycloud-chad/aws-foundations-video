#!/bin/bash

# AWS Cost Explorer Console Demonstration Helper Script
# This script opens the AWS Cost Management console in your default browser

echo "🚀 Opening AWS Cost Explorer Console..."
echo "📊 This will open the AWS Cost Management console where you can access Cost Explorer"
echo ""

# Check if we're on macOS, Linux, or Windows (Git Bash/WSL)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "https://console.aws.amazon.com/costmanagement/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open "https://console.aws.amazon.com/costmanagement/"
    elif command -v gnome-open > /dev/null; then
        gnome-open "https://console.aws.amazon.com/costmanagement/"
    else
        echo "Please manually open: https://console.aws.amazon.com/costmanagement/"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows (Git Bash or Cygwin)
    start "https://console.aws.amazon.com/costmanagement/"
else
    echo "Unable to detect operating system. Please manually open:"
    echo "https://console.aws.amazon.com/costmanagement/"
fi

echo ""
echo "📋 Once the console opens:"
echo "1. Sign in to your AWS account if prompted"
echo "2. Click 'Cost Explorer' in the left navigation pane"
echo "3. If first time, click 'Launch Cost Explorer'"
echo "4. Follow the demonstration steps in README.md"
echo ""
echo "💡 Tip: Bookmark the Cost Explorer URL for quick access:"
echo "   https://console.aws.amazon.com/costmanagement/home#/cost-explorer"
