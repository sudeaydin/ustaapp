#!/bin/bash

# 🔧 GitHub Repository Setup Script

echo "🚀 GitHub Repository Kurulum Scripti"
echo "===================================="

# Get user input
read -p "GitHub username: " GITHUB_USERNAME
read -p "Repository name (ustalar-app): " REPO_NAME
REPO_NAME=${REPO_NAME:-ustalar-app}

read -p "Discord Webhook URL (opsiyonel): " DISCORD_WEBHOOK

echo ""
echo "📋 Kurulum Bilgileri:"
echo "Username: $GITHUB_USERNAME"
echo "Repository: $REPO_NAME"
echo "Discord: ${DISCORD_WEBHOOK:0:50}..."
echo ""

read -p "Devam etmek istiyor musun? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# Set git config
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_USERNAME@users.noreply.github.com"

# Add remote
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Create initial commit
git add .
git commit -m "🚀 Initial commit: Ustalar App project setup"

echo ""
echo "✅ Git repository hazırlandı!"
echo ""
echo "📝 Sonraki adımlar:"
echo "1. GitHub'da '$REPO_NAME' repository'sini oluştur"
echo "2. Repository'yi public yap"
echo "3. Şu komutu çalıştır:"
echo "   git push -u origin main"
echo ""

if [ ! -z "$DISCORD_WEBHOOK" ]; then
    echo "4. Discord webhook için GitHub Secrets ekle:"
    echo "   Repository Settings > Secrets > Actions"
    echo "   Name: DISCORD_WEBHOOK_URL"
    echo "   Value: $DISCORD_WEBHOOK"
    echo ""
fi

echo "5. Auto-push daemon'u başlat:"
echo "   ./scripts/auto-push.sh daemon"
echo ""

# Save config for auto-push script
cat > .github-config << EOF
GITHUB_USERNAME=$GITHUB_USERNAME
REPO_NAME=$REPO_NAME
DISCORD_WEBHOOK_URL=$DISCORD_WEBHOOK
