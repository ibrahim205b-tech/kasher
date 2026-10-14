# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | ✅ Yes             |

## Reporting a Vulnerability

We take the security of **Restaurant POS** seriously. If you discover a security vulnerability, please **do not** open a public GitHub issue.

### How to Report

Please report vulnerabilities by:

1. Opening a **private security advisory** via GitHub's [Security tab](../../security/advisories/new)
2. Or emailing the maintainer directly (see your GitHub profile)

### What to Include

Please include the following in your report:
- A clear description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes or mitigations

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 7 days
- **Fix & disclosure**: Within 30 days (or as agreed upon)

## Security Considerations

This application:
- Stores all data **locally on-device** using SQLite — no cloud data transmission
- Does **not** require an internet connection for core POS functionality
- Does **not** collect telemetry, analytics, or personal data
- Bluetooth communication is limited to local thermal printer pairing only

## Scope

The following are **in scope** for vulnerability reports:
- Local database integrity issues
- Bluetooth communication vulnerabilities
- Insecure data storage
- Permission escalation issues

The following are **out of scope**:
- Issues in third-party Flutter packages (report to the package maintainer)
- Physical device security
- Network-level attacks (the app has no network access)
