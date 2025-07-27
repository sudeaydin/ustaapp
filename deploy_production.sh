#!/bin/bash

# ================================================
# USTAM APP - PRODUCTION DEPLOYMENT SCRIPT
# ================================================
# This script sets up the production environment
# and deploys the Ustam application

set -e  # Exit on any error

echo "🔨 USTAM - PRODUCTION DEPLOYMENT"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ustam"
APP_DIR="/var/www/ustam"
BACKUP_DIR="/var/backups/ustam"
LOG_DIR="/var/log/ustam"
VENV_DIR="$APP_DIR/venv"
DB_PATH="$APP_DIR/backend/production.db"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking system requirements..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root for security reasons"
        exit 1
    fi
    
    # Check required commands
    local required_commands=("python3" "npm" "git" "nginx" "systemctl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd is required but not installed"
            exit 1
        fi
    done
    
    # Check Python version
    local python_version=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
    if [[ $(echo "$python_version < 3.8" | bc -l) -eq 1 ]]; then
        log_error "Python 3.8+ is required, found $python_version"
        exit 1
    fi
    
    # Check Node.js version
    local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $node_version -lt 16 ]]; then
        log_error "Node.js 16+ is required, found $node_version"
        exit 1
    fi
    
    log_success "System requirements check passed"
}

create_directories() {
    log_info "Creating application directories..."
    
    sudo mkdir -p $APP_DIR
    sudo mkdir -p $BACKUP_DIR
    sudo mkdir -p $LOG_DIR
    sudo mkdir -p $APP_DIR/backend/uploads
    sudo mkdir -p $APP_DIR/backend/logs
    
    # Set ownership
    sudo chown -R $USER:$USER $APP_DIR
    sudo chown -R $USER:$USER $LOG_DIR
    
    log_success "Directories created"
}

backup_existing() {
    if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
        log_info "Backing up existing installation..."
        
        local backup_name="ustam_backup_$(date +%Y%m%d_%H%M%S)"
        sudo cp -r $APP_DIR $BACKUP_DIR/$backup_name
        
        log_success "Backup created: $BACKUP_DIR/$backup_name"
    fi
}

deploy_backend() {
    log_info "Deploying backend application..."
    
    cd $APP_DIR
    
    # Copy backend files
    if [ ! -d "backend" ]; then
        mkdir backend
    fi
    
    # Copy application files (assuming they're in current directory)
    cp -r ./ustaapp/backend/* ./backend/
    
    # Create virtual environment
    log_info "Creating Python virtual environment..."
    python3 -m venv $VENV_DIR
    source $VENV_DIR/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install dependencies
    log_info "Installing Python dependencies..."
    pip install -r backend/requirements.txt
    
    # Install additional production dependencies
    pip install gunicorn supervisor redis celery
    
    # Set up database
    log_info "Setting up production database..."
    cd backend
    python production_db_setup.py
    
    log_success "Backend deployment completed"
}

deploy_frontend() {
    log_info "Deploying frontend application..."
    
    cd $APP_DIR
    
    # Copy frontend files
    if [ ! -d "web" ]; then
        mkdir web
    fi
    
    cp -r ./ustaapp/web/* ./web/
    
    # Install dependencies
    log_info "Installing Node.js dependencies..."
    cd web
    npm ci --only=production
    
    # Build for production
    log_info "Building frontend for production..."
    npm run build
    
    # Copy built files to nginx directory
    sudo mkdir -p /var/www/html/ustam
    sudo cp -r dist/* /var/www/html/ustam/
    
    log_success "Frontend deployment completed"
}

setup_nginx() {
    log_info "Configuring Nginx..."
    
    # Create Nginx configuration
    cat > /tmp/ustam_nginx.conf << EOF
server {
    listen 80;
    server_name ustam.com www.ustam.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ustam.com www.ustam.com;
    
    # SSL Configuration (you need to add your SSL certificates)
    # ssl_certificate /etc/ssl/certs/ustam.com.crt;
    # ssl_certificate_key /etc/ssl/private/ustam.com.key;
    
    # Frontend static files
    location / {
        root /var/www/html/ustam;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API endpoints
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # File uploads
    location /uploads/ {
        alias $APP_DIR/backend/uploads/;
        expires 1y;
        add_header Cache-Control "public";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF
    
    # Install Nginx configuration
    sudo cp /tmp/ustam_nginx.conf /etc/nginx/sites-available/ustam
    sudo ln -sf /etc/nginx/sites-available/ustam /etc/nginx/sites-enabled/
    
    # Test Nginx configuration
    sudo nginx -t
    
    # Reload Nginx
    sudo systemctl reload nginx
    
    log_success "Nginx configuration completed"
}

setup_systemd() {
    log_info "Setting up systemd services..."
    
    # Create Gunicorn service
    cat > /tmp/ustam.service << EOF
[Unit]
Description=Ustam Flask Application
After=network.target

[Service]
Type=notify
User=$USER
Group=$USER
WorkingDirectory=$APP_DIR/backend
Environment=PATH=$VENV_DIR/bin
Environment=FLASK_ENV=production
Environment=DATABASE_URL=sqlite:///$DB_PATH
ExecStart=$VENV_DIR/bin/gunicorn --bind 127.0.0.1:5000 --workers 4 --timeout 120 --worker-class gevent --worker-connections 1000 run:app
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    # Install systemd service
    sudo cp /tmp/ustam.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable ustam
    
    log_success "Systemd service configured"
}

setup_logrotate() {
    log_info "Setting up log rotation..."
    
    cat > /tmp/ustam_logrotate << EOF
$LOG_DIR/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0644 $USER $USER
    postrotate
        systemctl reload ustam
    endscript
}
EOF
    
    sudo cp /tmp/ustam_logrotate /etc/logrotate.d/ustam
    
    log_success "Log rotation configured"
}

setup_firewall() {
    log_info "Configuring firewall..."
    
    # Allow HTTP and HTTPS
    sudo ufw allow 'Nginx Full'
    
    # Allow SSH (if not already allowed)
    sudo ufw allow ssh
    
    # Enable firewall if not already enabled
    sudo ufw --force enable
    
    log_success "Firewall configured"
}

create_env_file() {
    log_info "Creating environment configuration..."
    
    if [ ! -f "$APP_DIR/backend/.env" ]; then
        cat > $APP_DIR/backend/.env << EOF
# Production Environment Variables
SECRET_KEY=$(openssl rand -base64 32)
JWT_SECRET_KEY=$(openssl rand -base64 32)
DEBUG=False
FLASK_ENV=production

# Database
DATABASE_URL=sqlite:///$DB_PATH

# Add your production settings here:
# MAIL_SERVER=smtp.gmail.com
# MAIL_PORT=587
# MAIL_USE_TLS=True
# MAIL_USERNAME=your-email@gmail.com
# MAIL_PASSWORD=your-app-password
# IYZICO_API_KEY=your-iyzico-api-key
# IYZICO_SECRET_KEY=your-iyzico-secret-key
# GOOGLE_MAPS_API_KEY=your-google-maps-api-key

EOF
        
        log_warning "Environment file created at $APP_DIR/backend/.env"
        log_warning "Please edit this file and add your production settings"
    fi
}

start_services() {
    log_info "Starting services..."
    
    # Start and enable services
    sudo systemctl start ustam
    sudo systemctl enable ustam
    
    # Restart Nginx
    sudo systemctl restart nginx
    
    log_success "Services started"
}

run_tests() {
    log_info "Running deployment tests..."
    
    # Test backend API
    if curl -f http://localhost:5000/api/categories > /dev/null 2>&1; then
        log_success "Backend API is responding"
    else
        log_error "Backend API is not responding"
        return 1
    fi
    
    # Test frontend
    if curl -f http://localhost > /dev/null 2>&1; then
        log_success "Frontend is responding"
    else
        log_error "Frontend is not responding"
        return 1
    fi
    
    log_success "All tests passed"
}

print_summary() {
    echo ""
    echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
    echo "===================================="
    echo ""
    echo "📍 Application Details:"
    echo "   • Frontend: http://your-domain.com"
    echo "   • Backend API: http://your-domain.com/api"
    echo "   • Database Viewer: python $APP_DIR/backend/database_viewer.py"
    echo ""
    echo "📁 Important Paths:"
    echo "   • Application: $APP_DIR"
    echo "   • Database: $DB_PATH"
    echo "   • Logs: $LOG_DIR"
    echo "   • Backups: $BACKUP_DIR"
    echo ""
    echo "🔧 Management Commands:"
    echo "   • Start: sudo systemctl start ustam"
    echo "   • Stop: sudo systemctl stop ustam"
    echo "   • Restart: sudo systemctl restart ustam"
    echo "   • Status: sudo systemctl status ustam"
    echo "   • Logs: sudo journalctl -u ustam -f"
    echo ""
    echo "⚙️  Next Steps:"
    echo "   1. Edit $APP_DIR/backend/.env with your production settings"
    echo "   2. Configure SSL certificates for HTTPS"
    echo "   3. Set up domain DNS records"
    echo "   4. Configure backup strategy"
    echo "   5. Set up monitoring and alerting"
    echo ""
    echo "🔑 Default Admin Credentials:"
    echo "   • Email: admin@ustam.com"
    echo "   • Password: UstamAdmin2024!"
    echo ""
    log_warning "Remember to change the default admin password!"
}

# Main deployment process
main() {
    log_info "Starting production deployment..."
    
    check_requirements
    create_directories
    backup_existing
    deploy_backend
    deploy_frontend
    setup_nginx
    setup_systemd
    setup_logrotate
    setup_firewall
    create_env_file
    start_services
    
    if run_tests; then
        print_summary
    else
        log_error "Deployment completed but some tests failed"
        log_error "Please check the logs and configuration"
        exit 1
    fi
}

# Run main function
main "$@"