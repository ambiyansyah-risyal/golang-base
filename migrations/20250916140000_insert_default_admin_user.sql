-- +goose Up
-- +goose StatementBegin
-- Insert default admin user
-- Password: admin123 (bcrypt hashed with cost 12)
-- NOTE: Change this password immediately after first login in production!
INSERT INTO users (
    email, 
    password, 
    first_name, 
    last_name, 
    role, 
    active,
    created_at,
    updated_at
) VALUES (
    'admin@example.com',
    '$2a$12$IK7lRggngpoyuroNNsx5FOgJHLzgqKNwoQb3uSh/DMbIl3FrPTpES', -- bcrypt hash of 'admin123'
    'System',
    'Administrator',
    'admin',
    true,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING; -- Prevent duplicate insertion if migration is run multiple times

-- Insert default regular user for testing
INSERT INTO users (
    email, 
    password, 
    first_name, 
    last_name, 
    role, 
    active,
    created_at,
    updated_at
) VALUES (
    'user@example.com',
    '$2a$12$IK7lRggngpoyuroNNsx5FOgJHLzgqKNwoQb3uSh/DMbIl3FrPTpES', -- bcrypt hash of 'admin123'
    'Test',
    'User',
    'user',
    true,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING; -- Prevent duplicate insertion if migration is run multiple times
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Remove default users (only if they haven't been modified)
-- This removes users only if they still have the default password hash
DELETE FROM users 
WHERE email = 'admin@example.com' 
AND password = '$2a$12$IK7lRggngpoyuroNNsx5FOgJHLzgqKNwoQb3uSh/DMbIl3FrPTpES';

DELETE FROM users 
WHERE email = 'user@example.com' 
AND password = '$2a$12$IK7lRggngpoyuroNNsx5FOgJHLzgqKNwoQb3uSh/DMbIl3FrPTpES';
-- +goose StatementEnd