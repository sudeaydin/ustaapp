#!/bin/bash

# 🚀 Ustalar App Auto-Push Script
# Her 10 dakikada bir otomatik commit & push

REPO_DIR="/workspace/ustalar-app"
cd "$REPO_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Ustalar App Auto-Push Script${NC}"
echo -e "${BLUE}=================================${NC}"

# Function to calculate progress
calculate_progress() {
    local total_files=$(find . -name "*.py" -o -name "*.jsx" -o -name "*.js" | wc -l)
    local backend_files=$(find backend -name "*.py" 2>/dev/null | wc -l || echo 0)
    local frontend_files=$(find web -name "*.jsx" -o -name "*.js" 2>/dev/null | wc -l || echo 0)
    
    local progress=$(( (backend_files + frontend_files) * 100 / 50 ))
    if [ $progress -gt 100 ]; then progress=100; fi
    
    echo "$progress"
}

# Function to update progress JSON
update_progress_json() {
    local progress=$1
    local total_files=$(find . -name "*.py" -o -name "*.jsx" -o -name "*.js" | wc -l)
    local backend_files=$(find backend -name "*.py" 2>/dev/null | wc -l || echo 0)
    local frontend_files=$(find web -name "*.jsx" -o -name "*.js" 2>/dev/null | wc -l || echo 0)
    
    cat > dashboard/progress.json << EOF_JSON
{
  "project_name": "Ustalar App",
  "last_update": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "overall_progress": $progress,
  "total_files": $total_files,
  "backend_files": $backend_files,
  "frontend_files": $frontend_files,
  "auto_push": true,
  "github_url": "https://github.com/YOUR_USERNAME/ustalar-app"
}
EOF_JSON
}

# Function to send notification
send_notification() {
    local progress=$1
    local commit_msg="$2"
    
    # Discord webhook (if configured)
    if [ ! -z "$DISCORD_WEBHOOK_URL" ]; then
        curl -s -H "Content-Type: application/json" \
        -d '{
          "embeds": [{
            "title": "🚀 Ustalar App - Auto Push",
            "description": "'"$commit_msg"'",
            "color": 3447003,
            "fields": [
              {
                "name": "📊 Progress",
                "value": "'"$progress"'%",
                "inline": true
              },
              {
                "name": "⏰ Time",
                "value": "'"$(date '+%H:%M:%S')"'",
                "inline": true
              }
            ]
          }]
        }' \
        "$DISCORD_WEBHOOK_URL" > /dev/null
    fi
    
    echo -e "${GREEN}🔔 Notification sent!${NC}"
}

# Main auto-push function
auto_push() {
    echo -e "${YELLOW}⏰ $(date '+%Y-%m-%d %H:%M:%S') - Starting auto-push...${NC}"
    
    # Check if there are changes
    if git diff --quiet && git diff --staged --quiet; then
        echo -e "${YELLOW}📝 No changes detected${NC}"
        return
    fi
    
    # Calculate progress
    local progress=$(calculate_progress)
    
    # Update progress JSON
    update_progress_json $progress
    
    # Add all changes
    git add .
    
    # Create commit message
    local timestamp=$(date '+%H:%M')
    local commit_msg="🔄 Auto-push: Progress ${progress}% - ${timestamp}"
    
    # Commit
    if git commit -m "$commit_msg"; then
        echo -e "${GREEN}✅ Committed: $commit_msg${NC}"
        
        # Push to GitHub (if remote is configured)
        if git remote get-url origin > /dev/null 2>&1; then
            if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
                echo -e "${GREEN}🚀 Pushed to GitHub successfully!${NC}"
                send_notification $progress "$commit_msg"
            else
                echo -e "${RED}❌ Push failed${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  No GitHub remote configured${NC}"
        fi
    else
        echo -e "${RED}❌ Commit failed${NC}"
    fi
}

# Run once or start daemon
if [ "$1" = "daemon" ]; then
    echo -e "${BLUE}🔄 Starting auto-push daemon (every 10 minutes)${NC}"
    echo -e "${BLUE}Press Ctrl+C to stop${NC}"
    echo ""
    
    while true; do
        auto_push
        echo -e "${BLUE}💤 Sleeping for 10 minutes...${NC}"
        echo ""
        sleep 600  # 10 minutes
    done
else
    auto_push
fi
