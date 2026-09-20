# Project TAB security guide

Project TAB records exercise decisions, participant identities, internal response gaps, evidence links and facilitator notes. Treat the platform as a sensitive security-management system.

## Before production use

1. Set `TAB_ADMIN_PASSWORD` to a unique password of at least 14 characters before first start.
2. Put the service behind a TLS-terminating reverse proxy. Set `TAB_SECURE_COOKIES=true` after HTTPS is active.
3. Restrict network access to trusted administrative and participant networks or an authenticated access proxy.
4. Store the SQLite database on encrypted storage and include it in protected backups.
5. Create named facilitator accounts and stop using the bootstrap administrator for routine exercises.
6. Review the supplied scenarios before use. Adapt organizations, systems, roles, legal deadlines and inject claims to the exercise's approved scope.

The standard local launcher binds to `127.0.0.1`, so other devices cannot connect. The `-AllowLAN` option deliberately changes the listener to all local interfaces; use it only on a trusted private network and stop Project TAB when the exercise ends.

## Implemented controls

- Scrypt password hashing with a unique salt per account.
- Opaque 256-bit session tokens; only SHA-256 token hashes are stored.
- HTTP-only, SameSite session cookies, with optional `Secure` enforcement.
- Role-based access for administrators, facilitators, observers and participants.
- Exercise-scoped participant sessions and non-sequential identifiers.
- Same-origin checks for browser mutations.
- Parameterized SQLite statements and request-size limits.
- Login throttling per source address.
- Server-enforced replacement of bootstrap and administrator-issued temporary passwords.
- Content Security Policy, clickjacking protection and MIME-sniffing protection.
- Server-side audit records for authentication, administration and exercise operations.
- Facilitator-only notes and expected actions are removed from participant API responses.

## Operational limitations

- Version 1.1 uses local credentials; SAML/OIDC integration is not included.
- Evidence is registered as metadata or a URL. Binary evidence upload and malware-safe storage are deliberately not included.
- SQLite provides reliable single-instance persistence, not active-active clustering.
- Database encryption is an infrastructure responsibility.
- Login throttling is in memory and resets when the process restarts.
- Project TAB is an exercise platform, not a production incident-management or evidence-forensics system.

## Reverse-proxy notes

When a trusted reverse proxy supplies the real client IP through `X-Forwarded-For`, set `TAB_TRUST_PROXY=true`. Do not enable it when clients can reach Project TAB directly and spoof that header.

Terminate TLS at the proxy, redirect HTTP to HTTPS, set `TAB_SECURE_COOKIES=true`, and limit request bodies to 1 MB or less.

## Backups

For a consistent local backup, stop Project TAB and copy the complete `data` folder. For an online SQLite backup, use SQLite's backup facility rather than copying only the main database while write-ahead logging is active. Container users can stop the container and copy the complete `/app/data` volume.

Test restoration periodically. A backup is not useful until its restore procedure is proven.

## Reporting a vulnerability

Do not include real credentials, participant information or sensitive exercise evidence in a public issue. Send the maintainer a minimal reproduction through an approved private channel.
