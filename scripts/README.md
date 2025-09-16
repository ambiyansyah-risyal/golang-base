# Migration: Insert Default Admin User

## Overview

This migration (`20250916140000_insert_default_admin_user.sql`) creates two default users for the application:

1. **Admin User**: `admin@example.com` with role `admin`
2. **Test User**: `user@example.com` with role `user`

## Security Considerations

⚠️ **IMPORTANT SECURITY WARNING** ⚠️

Both default users have the password: `admin123`

**YOU MUST CHANGE THESE PASSWORDS IMMEDIATELY IN PRODUCTION!**

## Default Credentials

### Admin User
- **Email**: `admin@example.com`
- **Password**: `admin123`
- **Role**: `admin`
- **Name**: System Administrator

### Test User  
- **Email**: `user@example.com`
- **Password**: `admin123`
- **Role**: `user`
- **Name**: Test User

## Running the Migration

To apply this migration:

```bash
# For local development
make migrate-up

# For Docker environment
make docker-migrate-up
```

To rollback this migration:

```bash
# For local development  
make migrate-down

# For Docker environment
make docker-migrate-down
```

## Generating Custom Password Hashes

If you want to create users with different passwords, use the password hash generator:

```bash
# Option 1: Direct script usage
cd scripts
go run generate_password_hash.go "your_secure_password_here"

# Option 2: Use the Makefile target (recommended)
make generate-password-hash PASSWORD="your_secure_password_here"
```

This will output a bcrypt hash that you can use in SQL migrations or manual user creation.

## Production Setup Checklist

- [ ] Change the default admin password immediately after first login
- [ ] Change the default test user password or delete the account
- [ ] Consider using environment variables for initial admin credentials
- [ ] Set up proper password policies in your application
- [ ] Enable multi-factor authentication for admin accounts
- [ ] Review and audit all user accounts regularly

## Migration Safety Features

- Uses `ON CONFLICT (email) DO NOTHING` to prevent duplicate users if migration runs multiple times
- The rollback only removes users if they still have the default password hash (prevents accidental deletion of modified accounts)
- Timestamps are set to the current time when the migration runs

## Next Steps

After running this migration:

1. Start your application: `make run` or `make docker-run`
2. Navigate to the login page
3. Log in with the admin credentials above
4. **Immediately change the password**
5. Set up additional admin users as needed
6. Delete or modify the test user account

## Technical Details

- Password hashing: bcrypt with cost factor 12
- Hash format: Standard bcrypt hash starting with `$2a$12$`
- Database: PostgreSQL with GORM-compatible schema
- Migration tool: Goose