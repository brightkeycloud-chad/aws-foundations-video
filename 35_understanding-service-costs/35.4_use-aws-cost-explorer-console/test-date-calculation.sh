#!/bin/bash

# Test script to verify date calculation works correctly

echo "🗓️  Date Calculation Test"
echo "========================"
echo ""

echo "Current date: $(date)"
echo ""

# Calculate previous month dates properly
if command -v python3 &> /dev/null; then
    echo "✅ Using Python for date calculation"
    # Use Python for reliable cross-platform date calculation
    DATES=$(python3 -c "
from datetime import datetime, timedelta
import calendar

today = datetime.now()
print(f'Today: {today.strftime(\"%Y-%m-%d\")}')

# First day of current month
first_current = today.replace(day=1)
print(f'First day of current month: {first_current.strftime(\"%Y-%m-%d\")}')

# Last day of previous month
last_previous = first_current - timedelta(days=1)
print(f'Last day of previous month: {last_previous.strftime(\"%Y-%m-%d\")}')

# First day of previous month
first_previous = last_previous.replace(day=1)
print(f'First day of previous month: {first_previous.strftime(\"%Y-%m-%d\")}')

print(f'{first_previous.strftime(\"%Y-%m-%d\")} {last_previous.strftime(\"%Y-%m-%d\")}')
")
    PREVIOUS_MONTH_START=$(echo "$DATES" | tail -1 | cut -d' ' -f1)
    PREVIOUS_MONTH_END=$(echo "$DATES" | tail -1 | cut -d' ' -f2)
else
    echo "⚠️  Python not available, using shell calculation"
    # Fallback for systems without Python
    CURRENT_YEAR=$(date +%Y)
    CURRENT_MONTH=$(date +%m)
    
    echo "Current year: $CURRENT_YEAR"
    echo "Current month: $CURRENT_MONTH"
    
    if [ "$CURRENT_MONTH" = "01" ]; then
        PREVIOUS_YEAR=$((CURRENT_YEAR - 1))
        PREVIOUS_MONTH="12"
    else
        PREVIOUS_YEAR=$CURRENT_YEAR
        PREVIOUS_MONTH=$(printf "%02d" $((CURRENT_MONTH - 1)))
    fi
    
    echo "Previous year: $PREVIOUS_YEAR"
    echo "Previous month: $PREVIOUS_MONTH"
    
    PREVIOUS_MONTH_START="${PREVIOUS_YEAR}-${PREVIOUS_MONTH}-01"
    
    # Calculate last day of previous month
    case $PREVIOUS_MONTH in
        01|03|05|07|08|10|12) LAST_DAY="31" ;;
        04|06|09|11) LAST_DAY="30" ;;
        02) 
            # Check for leap year
            if [ $((PREVIOUS_YEAR % 4)) -eq 0 ] && { [ $((PREVIOUS_YEAR % 100)) -ne 0 ] || [ $((PREVIOUS_YEAR % 400)) -eq 0 ]; }; then
                LAST_DAY="29"
            else
                LAST_DAY="28"
            fi
            ;;
    esac
    
    PREVIOUS_MONTH_END="${PREVIOUS_YEAR}-${PREVIOUS_MONTH}-${LAST_DAY}"
    
    echo "Last day calculation: $LAST_DAY"
fi

echo ""
echo "📅 CALCULATED DATE RANGE:"
echo "========================="
echo "Previous month start: $PREVIOUS_MONTH_START"
echo "Previous month end:   $PREVIOUS_MONTH_END"
echo ""

# Validate the dates
echo "🔍 VALIDATION:"
echo "=============="

# Check if dates are valid format
if [[ $PREVIOUS_MONTH_START =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ $PREVIOUS_MONTH_END =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "✅ Date format is valid (YYYY-MM-DD)"
else
    echo "❌ Date format is invalid"
    exit 1
fi

# Check if start date is before end date
if [[ "$PREVIOUS_MONTH_START" < "$PREVIOUS_MONTH_END" ]]; then
    echo "✅ Start date is before end date"
else
    echo "❌ Start date is not before end date"
    exit 1
fi

# Check if dates are not in the future
CURRENT_DATE=$(date +%Y-%m-%d)
if [[ "$PREVIOUS_MONTH_END" < "$CURRENT_DATE" ]]; then
    echo "✅ Previous month dates are in the past"
else
    echo "❌ Previous month dates are not in the past"
    exit 1
fi

echo ""
echo "🎯 READY FOR AWS COST EXPLORER:"
echo "==============================="
echo "Time period: Start=\"$PREVIOUS_MONTH_START\",End=\"$PREVIOUS_MONTH_END\""
echo ""
echo "✅ Date calculation successful!"
