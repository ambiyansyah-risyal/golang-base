# Security Guidelines

## Database Credential Management

### Development Environment

For local development, database credentials are managed through environment variables:

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env file to set secure credentials
nano .env
```

### Environment Variables

The following environment variables are used for database connections:

| Variable | Description | Default | Production Notes |
|----------|-------------|---------|------------------|
| `DB_HOST` | Database host | `localhost` | Use private network endpoints |
| `DB_PORT` | Database port | `5432` | Use non-standard ports if possible |
| `DB_USER` | Database username | `user` | Use least-privilege accounts |
| `DB_PASSWORD` | Database password | `password` | **Must be changed in production!** |
| `DB_NAME` | Database name | `golang_base` | Use descriptive, secure naming |
| `DB_SSLMODE` | SSL connection mode | `disable` | **Must be `require` in production!** |

### Production Deployment Security

#### 1. Credential Management
- **Never commit real credentials to version control**
- Use environment variables or secrets management systems
- Rotate credentials regularly (at least quarterly)
- Use strong, unique passwords (minimum 20 characters)

#### 2. Network Security
- Enable SSL/TLS: Set `DB_SSLMODE=require`
- Use private network connections
- Implement IP whitelisting
- Consider using connection pooling with authentication

#### 3. Database Security
- Create dedicated database users with minimal privileges
- Disable default accounts (postgres, root, etc.)
- Enable audit logging
- Regular security updates

#### 4. Secrets Management Options

**Docker Compose (Development)**
```yaml
services:
  app:
    environment:
      - DB_HOST=${DB_HOST}
      - DB_PASSWORD=${DB_PASSWORD}
    env_file:
      - .env
```

**Kubernetes (Production)**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  DB_PASSWORD: <base64-encoded-password>
---
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_PASSWORD
```

**AWS Secrets Manager**
```bash
# Store secret
aws secretsmanager create-secret \
  --name "golang-base/db-credentials" \
  --description "Database credentials for golang-base" \
  --secret-string '{"password":"your-secure-password"}'

# In your application, retrieve using AWS SDK
```

**HashiCorp Vault**
```bash
# Store secret
vault kv put secret/golang-base/db password="your-secure-password"

# In your application, retrieve using Vault API
```

### Migration Security

When running database migrations:

```bash
# Load environment variables first
source .env

# Or export them explicitly (for production scripts)
export DB_PASSWORD="your-secure-password"

# Run migrations
make migrate-up
```

### Security Checklist

- [ ] Changed default database credentials
- [ ] Enabled SSL/TLS for database connections
- [ ] Created dedicated database user with minimal privileges
- [ ] Set up credential rotation schedule
- [ ] Implemented secrets management system
- [ ] Configured audit logging
- [ ] Set up monitoring and alerting
- [ ] Documented credential recovery procedures
- [ ] Tested backup and restore procedures
- [ ] Reviewed and updated security policies

### Security Incident Response

If credentials are compromised:

1. **Immediate Actions**
   - Rotate all affected credentials immediately
   - Check audit logs for unauthorized access
   - Assess scope of potential data breach

2. **Investigation**
   - Review access logs
   - Identify affected systems and data
   - Document timeline of events

3. **Recovery**
   - Update all systems with new credentials
   - Monitor for continued unauthorized access
   - Update security measures to prevent recurrence

4. **Documentation**
   - Document lessons learned
   - Update security procedures
   - Conduct post-incident review

### Additional Resources

- [OWASP Database Security](https://owasp.org/www-project-cheat-sheets/cheatsheets/Database_Security_Cheat_Sheet.html)
- [PostgreSQL Security Documentation](https://www.postgresql.org/docs/current/security.html)
- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [Kubernetes Secrets Documentation](https://kubernetes.io/docs/concepts/configuration/secret/)