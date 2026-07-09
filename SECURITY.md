# Security Policy

Sudonym is historical wallet software and has not been audited as a current release. Do not use it with meaningful funds or production personal data without a current dependency review, threat model, and independent security audit.

## Secrets and local configuration

- Never commit populated `.env` files, Firebase configuration, service-account JSON, signing certificates, private keys, macaroons, wallet data, or provider credentials.
- Use Application Default Credentials or workload identity for Google Cloud access.
- Keep production values in a managed secret store and inject them at runtime.
- Treat mobile and web client configuration as public. Restrict Firebase and OAuth clients by application ID, signing certificate, domain, and API scope.
- Use a server-side OAuth exchange for any provider credential that must remain confidential.

## Reporting a vulnerability

Do not disclose a vulnerability or credential in a public issue. Contact the repository owner privately through their GitHub profile with a minimal reproduction and affected component.

If a credential is committed, revoke or rotate it first, remove it from every Git ref and release artifact, and have collaborators re-clone the sanitized repository.
