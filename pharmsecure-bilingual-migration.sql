-- PharmSecure Bilingual Migration
ALTER TABLE users ADD COLUMN IF NOT EXISTS language VARCHAR(5) DEFAULT 'en';

CREATE TABLE IF NOT EXISTS pharmacy_config (
    id SERIAL PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_fr VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    UNIQUE(name_en, name_fr)
);

CREATE TABLE IF NOT EXISTS translations (
    id SERIAL PRIMARY KEY,
    resource_type VARCHAR(50) NOT NULL,
    resource_id INTEGER NOT NULL,
    language VARCHAR(5) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(resource_type, resource_id, language, field_name)
);

CREATE TABLE IF NOT EXISTS i18n_keys (
    id SERIAL PRIMARY KEY,
    key_name VARCHAR(100) UNIQUE NOT NULL,
    en TEXT NOT NULL,
    fr TEXT NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO pharmacy_config (name_en, name_fr, address, phone, email)
VALUES ('PharmSecure Pharmacy', 'Pharmacie PharmSecure', 'Accra, Ghana', '+233XXXXXXXXXX', 'contact@pharmsecure.com')
ON CONFLICT DO NOTHING;

INSERT INTO i18n_keys (key_name, en, fr, category) VALUES
('dashboard.title', 'Dashboard', 'Tableau de Bord', 'dashboard'),
('pos.title', 'Point of Sale', 'Point de Vente', 'pos'),
('common.save', 'Save', 'Enregistrer', 'common'),
('common.logout', 'Logout', 'Déconnexion', 'common')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS pharmacy_config_audit (
    id SERIAL PRIMARY KEY,
    config_id INTEGER REFERENCES pharmacy_config(id),
    changed_by INTEGER REFERENCES users(id),
    change_type VARCHAR(50),
    old_value TEXT,
    new_value TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_translations_resource ON translations(resource_type, resource_id, language);
CREATE INDEX IF NOT EXISTS idx_i18n_keys_category ON i18n_keys(category);
CREATE INDEX IF NOT EXISTS idx_users_language ON users(language);

COMMIT;
