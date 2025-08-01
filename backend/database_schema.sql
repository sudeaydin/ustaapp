-- ================================================
-- USTAM APP - PRODUCTION DATABASE SCHEMA
-- ================================================
-- Created: 2024
-- Purpose: Complete database schema for Ustam application

-- Enable foreign key constraints (SQLite)
PRAGMA foreign_keys = ON;

-- ================================================
-- USERS TABLE - Base user information
-- ================================================
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('customer', 'craftsman', 'admin')),
    
    -- Profile fields
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    profile_image VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    
    -- Status fields
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    
    -- Location
    city VARCHAR(100),
    district VARCHAR(100),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    email_verified_at TIMESTAMP,
    phone_verified_at TIMESTAMP,
    
    -- Indexes
    UNIQUE(email),
    UNIQUE(phone)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_city ON users(city);
CREATE INDEX idx_users_active ON users(is_active);

-- ================================================
-- CATEGORIES TABLE - Service categories
-- ================================================
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    name_en VARCHAR(100),
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(255),
    color VARCHAR(7),
    image_url VARCHAR(255),
    
    -- SEO fields
    meta_title VARCHAR(160),
    meta_description VARCHAR(320),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    
    -- Statistics
    total_jobs INTEGER DEFAULT 0,
    total_craftsmen INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_active ON categories(is_active);
CREATE INDEX idx_categories_featured ON categories(is_featured);
CREATE INDEX idx_categories_sort ON categories(sort_order);

-- ================================================
-- CUSTOMERS TABLE - Customer profiles
-- ================================================
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE NOT NULL,
    
    -- Customer specific fields
    company_name VARCHAR(255),
    tax_number VARCHAR(20),
    billing_address TEXT,
    
    -- Preferences
    preferred_contact_method VARCHAR(20) DEFAULT 'phone' CHECK (preferred_contact_method IN ('phone', 'email', 'sms', 'app')),
    notification_preferences TEXT, -- JSON string
    
    -- Statistics
    total_jobs INTEGER DEFAULT 0,
    total_spent DECIMAL(12, 2) DEFAULT 0.00,
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_customers_user_id ON customers(user_id);

-- ================================================
-- CRAFTSMEN TABLE - Craftsman profiles
-- ================================================
CREATE TABLE IF NOT EXISTS craftsmen (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE NOT NULL,
    
    -- Business info
    business_name VARCHAR(255),
    business_type VARCHAR(50) DEFAULT 'individual' CHECK (business_type IN ('individual', 'company')),
    tax_number VARCHAR(20),
    license_number VARCHAR(50),
    description TEXT,
    
    -- Pricing
    hourly_rate DECIMAL(10, 2),
    min_job_price DECIMAL(10, 2),
    travel_cost DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Service area
    service_radius INTEGER DEFAULT 10, -- km
    serves_weekends BOOLEAN DEFAULT TRUE,
    emergency_service BOOLEAN DEFAULT FALSE,
    
    -- Ratings and statistics
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    total_jobs INTEGER DEFAULT 0,
    completion_rate DECIMAL(5, 2) DEFAULT 0.00,
    response_time_avg INTEGER DEFAULT 0, -- minutes
    
    -- Status
    is_available BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    verification_level VARCHAR(20) DEFAULT 'none' CHECK (verification_level IN ('none', 'basic', 'verified', 'premium')),
    
    -- Availability
    working_hours TEXT, -- JSON string for working hours
    unavailable_dates TEXT, -- JSON string for unavailable dates
    
    -- Documents
    portfolio_images TEXT, -- JSON array of image URLs
    certificates TEXT, -- JSON array of certificate URLs
    insurance_document VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP,
    verified_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_craftsmen_user_id ON craftsmen(user_id);
CREATE INDEX idx_craftsmen_city ON craftsmen((SELECT city FROM users WHERE users.id = craftsmen.user_id));
CREATE INDEX idx_craftsmen_rating ON craftsmen(average_rating);
CREATE INDEX idx_craftsmen_available ON craftsmen(is_available);
CREATE INDEX idx_craftsmen_verified ON craftsmen(is_verified);
CREATE INDEX idx_craftsmen_featured ON craftsmen(is_featured);

-- ================================================
-- CRAFTSMAN_CATEGORIES - Many-to-many relationship
-- ================================================
CREATE TABLE IF NOT EXISTS craftsman_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    craftsman_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    experience_years INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (craftsman_id) REFERENCES craftsmen(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE(craftsman_id, category_id)
);

CREATE INDEX idx_craftsman_categories_craftsman ON craftsman_categories(craftsman_id);
CREATE INDEX idx_craftsman_categories_category ON craftsman_categories(category_id);

-- ================================================
-- SERVICES TABLE - Specific services offered
-- ================================================
CREATE TABLE IF NOT EXISTS services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    craftsman_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price_type VARCHAR(20) DEFAULT 'hourly' CHECK (price_type IN ('hourly', 'fixed', 'quote')),
    price DECIMAL(10, 2),
    duration_estimate INTEGER, -- minutes
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (craftsman_id) REFERENCES craftsmen(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

CREATE INDEX idx_services_craftsman ON services(craftsman_id);
CREATE INDEX idx_services_category ON services(category_id);
CREATE INDEX idx_services_active ON services(is_active);

-- ================================================
-- JOBS TABLE - Job requests and assignments
-- ================================================
CREATE TABLE IF NOT EXISTS jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Basic info
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    assigned_craftsman_id INTEGER,
    
    -- Location
    location VARCHAR(200) NOT NULL,
    city VARCHAR(100),
    district VARCHAR(100),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Job details
    budget_min DECIMAL(10, 2),
    budget_max DECIMAL(10, 2),
    final_price DECIMAL(10, 2),
    urgency VARCHAR(20) DEFAULT 'normal' CHECK (urgency IN ('low', 'normal', 'high', 'urgent')),
    
    -- Scheduling
    preferred_date DATE,
    preferred_time_start TIME,
    preferred_time_end TIME,
    flexible_timing BOOLEAN DEFAULT TRUE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('draft', 'open', 'assigned', 'in_progress', 'completed', 'approved', 'paid', 'cancelled', 'disputed')),
    
    -- Images and attachments
    images TEXT, -- JSON array of image URLs
    attachments TEXT, -- JSON array of attachment URLs
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_at TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    approved_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    expires_at TIMESTAMP,
    
    -- Metadata
    view_count INTEGER DEFAULT 0,
    quote_count INTEGER DEFAULT 0,
    
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_craftsman_id) REFERENCES craftsmen(id) ON DELETE SET NULL
);

CREATE INDEX idx_jobs_customer ON jobs(customer_id);
CREATE INDEX idx_jobs_craftsman ON jobs(assigned_craftsman_id);
CREATE INDEX idx_jobs_category ON jobs(category_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_city ON jobs(city);
CREATE INDEX idx_jobs_created ON jobs(created_at);
CREATE INDEX idx_jobs_budget ON jobs(budget_min, budget_max);

-- ================================================
-- QUOTES TABLE - Craftsman quotes for jobs
-- ================================================
CREATE TABLE IF NOT EXISTS quotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id INTEGER NOT NULL,
    craftsman_id INTEGER NOT NULL,
    
    -- Quote details
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    estimated_duration INTEGER, -- hours
    materials_included BOOLEAN DEFAULT FALSE,
    warranty_period INTEGER DEFAULT 0, -- days
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),
    
    -- Validity
    valid_until TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    rejected_at TIMESTAMP,
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (craftsman_id) REFERENCES craftsmen(id) ON DELETE CASCADE,
    UNIQUE(job_id, craftsman_id)
);

CREATE INDEX idx_quotes_job ON quotes(job_id);
CREATE INDEX idx_quotes_craftsman ON quotes(craftsman_id);
CREATE INDEX idx_quotes_status ON quotes(status);
CREATE INDEX idx_quotes_created ON quotes(created_at);

-- ================================================
-- MESSAGES TABLE - Communication system
-- ================================================
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Participants
    sender_id INTEGER NOT NULL,
    recipient_id INTEGER NOT NULL,
    
    -- Message content
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
    
    -- Related entities
    job_id INTEGER,
    quote_id INTEGER,
    
    -- Attachments
    attachments TEXT, -- JSON array
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_deleted_by_sender BOOLEAN DEFAULT FALSE,
    is_deleted_by_recipient BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE SET NULL,
    FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE SET NULL
);

CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_job ON messages(job_id);
CREATE INDEX idx_messages_created ON messages(created_at);
CREATE INDEX idx_messages_unread ON messages(recipient_id, is_read);

-- ================================================
-- REVIEWS TABLE - Customer reviews for craftsmen
-- ================================================
CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id INTEGER UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL,
    craftsman_id INTEGER NOT NULL,
    
    -- Review content
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    
    -- Review aspects
    quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    value_rating INTEGER CHECK (value_rating >= 1 AND value_rating <= 5),
    
    -- Status
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Response
    craftsman_response TEXT,
    response_date TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (craftsman_id) REFERENCES craftsmen(id) ON DELETE CASCADE
);

CREATE INDEX idx_reviews_craftsman ON reviews(craftsman_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_reviews_job ON reviews(job_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created ON reviews(created_at);

-- ================================================
-- PAYMENTS TABLE - Payment transactions
-- ================================================
CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Transaction details
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    job_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    craftsman_id INTEGER NOT NULL,
    
    -- Payment amounts
    amount DECIMAL(12, 2) NOT NULL,
    platform_fee DECIMAL(12, 2) DEFAULT 0.00,
    craftsman_amount DECIMAL(12, 2) NOT NULL,
    
    -- Payment details
    payment_method VARCHAR(50) NOT NULL,
    payment_provider VARCHAR(50) DEFAULT 'iyzico',
    currency VARCHAR(3) DEFAULT 'TRY',
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'disputed')),
    
    -- Provider response
    provider_transaction_id VARCHAR(100),
    provider_response TEXT, -- JSON
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    failed_at TIMESTAMP,
    refunded_at TIMESTAMP,
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (craftsman_id) REFERENCES craftsmen(id) ON DELETE CASCADE
);

CREATE INDEX idx_payments_transaction ON payments(transaction_id);
CREATE INDEX idx_payments_job ON payments(job_id);
CREATE INDEX idx_payments_customer ON payments(customer_id);
CREATE INDEX idx_payments_craftsman ON payments(craftsman_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created ON payments(created_at);

-- ================================================
-- NOTIFICATIONS TABLE - System notifications
-- ================================================
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    
    -- Notification content
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    
    -- Related entities
    related_id INTEGER,
    related_type VARCHAR(50),
    
    -- Actions
    action_url VARCHAR(500),
    action_data TEXT, -- JSON
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    
    -- Delivery channels
    send_push BOOLEAN DEFAULT TRUE,
    send_email BOOLEAN DEFAULT FALSE,
    send_sms BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    sent_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_created ON notifications(created_at);

-- ================================================
-- SYSTEM SETTINGS TABLE - Application settings
-- ================================================
CREATE TABLE IF NOT EXISTS system_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    type VARCHAR(20) DEFAULT 'string' CHECK (type IN ('string', 'integer', 'float', 'boolean', 'json')),
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_settings_key ON system_settings(key);

-- ================================================
-- AUDIT LOG TABLE - System audit trail
-- ================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INTEGER,
    old_values TEXT, -- JSON
    new_values TEXT, -- JSON
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- ================================================
-- INITIAL DATA INSERTS
-- ================================================

-- Insert default system settings
INSERT OR IGNORE INTO system_settings (key, value, description, type, is_public) VALUES
('app_name', 'Ustam', 'Application name', 'string', true),
('app_version', '1.0.0', 'Application version', 'string', true),
('maintenance_mode', 'false', 'Maintenance mode status', 'boolean', true),
('platform_fee_rate', '0.05', 'Platform fee rate (5%)', 'float', false),
('min_job_price', '50.00', 'Minimum job price', 'float', true),
('max_job_price', '10000.00', 'Maximum job price', 'float', true),
('currency', 'TRY', 'Default currency', 'string', true),
('timezone', 'Europe/Istanbul', 'Default timezone', 'string', true),
('max_file_size', '10485760', 'Maximum file size in bytes (10MB)', 'integer', true),
('allowed_file_types', '["jpg", "jpeg", "png", "pdf", "doc", "docx"]', 'Allowed file types', 'json', true);

-- Insert default categories
INSERT OR IGNORE INTO categories (name, name_en, slug, description, icon, color, sort_order) VALUES
('Elektrikçi', 'Electrician', 'elektrikci', 'Elektrik tesisatı kurulum ve onarım hizmetleri', '⚡', '#f59e0b', 1),
('Tesisatçı', 'Plumber', 'tesisatci', 'Su, doğalgaz ve ısıtma tesisatı hizmetleri', '🔧', '#3b82f6', 2),
('Boyacı', 'Painter', 'boyaci', 'İç ve dış cephe boyama hizmetleri', '🎨', '#ef4444', 3),
('Marangoz', 'Carpenter', 'marangoz', 'Ahşap işleri ve mobilya yapım-onarım', '🔨', '#8b5cf6', 4),
('Temizlik', 'Cleaning', 'temizlik', 'Ev, ofis ve inşaat sonrası temizlik', '🧹', '#10b981', 5),
('Bahçıvan', 'Gardener', 'bahcivan', 'Bahçe düzenleme ve peyzaj hizmetleri', '🌱', '#22c55e', 6),
('Klima Teknisyeni', 'AC Technician', 'klima', 'Klima montaj, bakım ve onarım', '❄️', '#06b6d4', 7),
('Cam Ustası', 'Glazier', 'cam', 'Cam kesim, montaj ve onarım hizmetleri', '🪟', '#84cc16', 8),
('Fayansçı', 'Tiler', 'fayansci', 'Fayans, seramik ve mozaik döşeme', '🔲', '#f97316', 9),
('Nakliyeci', 'Mover', 'nakliye', 'Ev ve ofis taşıma hizmetleri', '🚚', '#6b7280', 10);

-- ================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ================================================

-- Update timestamps trigger for users
CREATE TRIGGER IF NOT EXISTS update_users_timestamp 
    AFTER UPDATE ON users
    FOR EACH ROW
BEGIN
    UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for categories
CREATE TRIGGER IF NOT EXISTS update_categories_timestamp 
    AFTER UPDATE ON categories
    FOR EACH ROW
BEGIN
    UPDATE categories SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for customers
CREATE TRIGGER IF NOT EXISTS update_customers_timestamp 
    AFTER UPDATE ON customers
    FOR EACH ROW
BEGIN
    UPDATE customers SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for craftsmen
CREATE TRIGGER IF NOT EXISTS update_craftsmen_timestamp 
    AFTER UPDATE ON craftsmen
    FOR EACH ROW
BEGIN
    UPDATE craftsmen SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for jobs
CREATE TRIGGER IF NOT EXISTS update_jobs_timestamp 
    AFTER UPDATE ON jobs
    FOR EACH ROW
BEGIN
    UPDATE jobs SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for quotes
CREATE TRIGGER IF NOT EXISTS update_quotes_timestamp 
    AFTER UPDATE ON quotes
    FOR EACH ROW
BEGIN
    UPDATE quotes SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for reviews
CREATE TRIGGER IF NOT EXISTS update_reviews_timestamp 
    AFTER UPDATE ON reviews
    FOR EACH ROW
BEGIN
    UPDATE reviews SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update timestamps trigger for payments
CREATE TRIGGER IF NOT EXISTS update_payments_timestamp 
    AFTER UPDATE ON payments
    FOR EACH ROW
BEGIN
    UPDATE payments SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update craftsman rating when review is added/updated
CREATE TRIGGER IF NOT EXISTS update_craftsman_rating_after_review
    AFTER INSERT ON reviews
    FOR EACH ROW
BEGIN
    UPDATE craftsmen 
    SET 
        average_rating = (
            SELECT AVG(rating) 
            FROM reviews 
            WHERE craftsman_id = NEW.craftsman_id
        ),
        total_reviews = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE craftsman_id = NEW.craftsman_id
        )
    WHERE id = NEW.craftsman_id;
END;

-- Update job count when job is completed
CREATE TRIGGER IF NOT EXISTS update_job_counts_after_completion
    AFTER UPDATE ON jobs
    FOR EACH ROW
    WHEN NEW.status = 'completed' AND OLD.status != 'completed'
BEGIN
    -- Update customer total jobs
    UPDATE customers 
    SET total_jobs = total_jobs + 1
    WHERE id = NEW.customer_id;
    
    -- Update craftsman total jobs
    UPDATE craftsmen 
    SET total_jobs = total_jobs + 1
    WHERE id = NEW.assigned_craftsman_id;
    
    -- Update category total jobs
    UPDATE categories 
    SET total_jobs = total_jobs + 1
    WHERE id = NEW.category_id;
END;

-- ================================================
-- VIEWS FOR COMMON QUERIES
-- ================================================

-- View for active craftsmen with user details
CREATE VIEW IF NOT EXISTS v_active_craftsmen AS
SELECT 
    c.*,
    u.first_name,
    u.last_name,
    u.email,
    u.phone,
    u.profile_image,
    u.city as user_city,
    u.district as user_district,
    u.is_verified as user_verified,
    u.created_at as user_created_at
FROM craftsmen c
JOIN users u ON c.user_id = u.id
WHERE u.is_active = 1 AND c.is_available = 1;

-- View for job listings with related data
CREATE VIEW IF NOT EXISTS v_job_listings AS
SELECT 
    j.*,
    c.name as category_name,
    c.icon as category_icon,
    cu.user_id as customer_user_id,
    u.first_name as customer_first_name,
    u.last_name as customer_last_name,
    cr.business_name as craftsman_business_name,
    cr.average_rating as craftsman_rating
FROM jobs j
JOIN categories c ON j.category_id = c.id
JOIN customers cu ON j.customer_id = cu.id
JOIN users u ON cu.user_id = u.id
LEFT JOIN craftsmen cr ON j.assigned_craftsman_id = cr.id;

-- ================================================
-- PERFORMANCE OPTIMIZATION
-- ================================================

-- Analyze tables for query optimization
ANALYZE;

-- ================================================
-- SCHEMA COMPLETE
-- ================================================