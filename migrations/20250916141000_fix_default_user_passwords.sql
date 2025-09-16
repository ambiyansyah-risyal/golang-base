-- +goose Up
-- +goose StatementBegin
-- Fix the password hashes for default users
-- The previous migration had incorrect bcrypt hashes
UPDATE users 
SET password = '$2a$12$IK7lRggngpoyuroNNsx5FOgJHLzgqKNwoQb3uSh/DMbIl3FrPTpES' -- Correct hash for 'admin123'
WHERE email IN ('admin@example.com', 'user@example.com')
AND password = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeilvUi5NTCg0n56W'; -- Old incorrect hash
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Revert to the previous (incorrect) hash
UPDATE users 
SET password = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeilvUi5NTCg0n56W' -- Old hash
WHERE email IN ('admin@example.com', 'user@example.com')
AND password = '$2a$12$IK7lRggngpoyuroNNsx5FOgJHLzgqKNwoQb3uSh/DMbIl3FrPTpES'; -- Current correct hash
-- +goose StatementEnd