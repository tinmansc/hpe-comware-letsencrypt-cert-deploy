# Security Policy

## Reporting a Security Issue

If you discover a security problem in this project, please do **not** open a public GitHub issue with exploit details, private keys, passwords, switch configurations, or sensitive network information.

Instead, contact the maintainer privately:

    55678618+tinmansc@users.noreply.github.com

Please include:

- a short description of the issue
- which file or feature is affected
- steps to reproduce, if safe to share
- whether the issue could expose credentials, private keys, certificates, switch configuration, or management access
- any suggested mitigation, if known

Do not include real private keys, production passwords, or full sensitive switch configurations unless specifically requested through a safer channel.

## Supported Versions

This project is experimental and currently maintained as a learning/home-lab project.

Only the latest version on the `main` branch is actively maintained.

| Version | Supported |
|---|---|
| latest `main` | Yes |
| older commits/tags | No |

## Security Scope

Security-sensitive areas include:

- handling of TLS private keys
- handling of Home Assistant `/ssl` certificate files
- switch login credentials
- SSH/SFTP command execution
- Comware PKI import commands
- saved startup configuration backups
- logs that may contain hostnames, IP addresses, or switch configuration details

## Known Security Notes

This project may download or create switch startup configuration backups. Those files can contain sensitive management details.

Do not commit real logs, private keys, certificate bundles, switch backups, or `secrets.yaml` files to GitHub.

The included `.gitignore` attempts to exclude common sensitive file types, but users are responsible for reviewing changes before committing.

Recommended review commands before pushing:

    git status
    git diff --cached
    grep -Rni "BEGIN .*PRIVATE KEY\|PRIVATE KEY-----" .
    grep -Rni "password\|secret\|token" .

## Disclosure Expectations

This is a small home-lab project, not a commercial product.

I will do my best to respond to responsible security reports, but response times may vary.
