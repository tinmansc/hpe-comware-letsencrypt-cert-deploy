# HPE Comware Certificate Sync for Home Assistant

Deploy Let's Encrypt TLS certificates from Home Assistant to HPE 1950 Series / Comware switches using SSH, SFTP, OpenSSL, and native Comware PKI import.

## Origin Story

This project was developed because the author refused to let a printer, which was working perfectly, have a self-signed certificate.

Things escalated.

## What This Does

This project automates certificate deployment to HPE 1950 Series / Comware switches.

It can:

- read the current Let's Encrypt certificate from Home Assistant
- compare it to the certificate currently served by the switch HTTPS UI
- upload certificate/chain/key material using SFTP
- generate/import a legacy PKCS#12 bundle accepted by HPE 1950 switches
- import CA and local certificates into a Comware PKI domain
- bind the PKI domain to the HTTPS SSL server policy
- restart switch HTTP/HTTPS services in the required order
- verify the live served certificate before saving configuration
- save and verify the startup configuration

## Tested Hardware / Firmware

This project has currently only been verified on the following HPE 1950 Series / Comware 7 devices:

| Device | Model | Comware release | Status |
|---|---|---:|---|
| HPE 1950 24G 2SFP+ 2XGT PoE+ | JG962A | R3507P08 | Verified |
| HPE 1950 24G 2SFP+ 2XGT | JG960A | R3507P09 | Verified |

Both devices run:

- HPE Comware Software Version 7.1.070
- Bootrom Version 147
- Extended CLI mode available via `xtd-cli-mode`

Other HPE 1950 models, other Comware releases, and other HPE/Aruba/3Com-derived switches may work, but have not been tested.

## Start With Check Mode

WARNING **Before using this project to deploy anything, run `check` mode first!** WARNING

This applies even if your switch model and firmware are listed as tested.

`check` mode verifies connectivity, SSH behavior, startup configuration selection, startup file existence, certificate status, and whether the script can safely inspect the target.

Do not skip this step.

A successful `check` run does not guarantee that every future deployment will succeed, but a failed `check` run is a strong signal that `apply` should not be used yet.

## Modes

### `check`

Safe preflight mode.

Use this before any deployment. It verifies connectivity, certificate status, Comware command behavior, startup configuration safety, and backup/download access.

### `deploy`

Recommended normal automation mode.

Runs `check` first. If and only if `check` succeeds, it runs the apply path. This is the preferred mode for Home Assistant automation.

### `apply`

Direct apply mode.

Runs the deployment path. The Python script still performs internal checks, but this mode is intended for users who already understand the environment and have previously validated it with `check`.

Most users should use `deploy`, not `apply`, for unattended automation.

## Where the Certificate Is Saved

The uploaded PKCS#12 file is used during certificate import. It is not directly referenced by the saved switch configuration afterward.

For example, this file may be uploaded to the switch:

    flash:/pki/hpe-1950-fullchain-legacy.p12

The script then imports it into the Comware PKI domain:

    pki import domain hp-1950 p12 local filename flash:/pki/hpe-1950-fullchain-legacy.p12

After import, Comware stores the certificate and private key in the switch PKI store. The saved configuration does not normally say "use this P12 filename."

Instead, the persistent configuration references the PKI domain and SSL policy, such as:

    pki domain hp-1950
    ssl server-policy hp-1950
     pki-domain hp-1950
    ip https ssl-server-policy hp-1950
    ip https enable

In other words:

- the P12 file is a staging/import file
- the imported certificate/key live in the switch PKI store
- the saved startup configuration remembers the PKI domain and HTTPS SSL policy
- the P12 filename itself is not expected to appear in the startup `.cfg` file

This is why the script verifies saved configuration lines for the PKI domain and HTTPS SSL policy, not the original P12 filename.

## Safety Model

This project intentionally uses a slow, verification-heavy workflow.

Do not skip the checkpoints. After each step, compare the output to the expected result before continuing. If the output is surprising, stop and investigate before running the next command.

## Known Harmless Messages

### `s6-rc: warning: service s6rc-oneshot-runner is marked as essential`

This may appear when the Home Assistant app container exits after a successful run. It comes from the Home Assistant base image/s6 supervisor layer, not from the certificate deployment script.

Use the app's own final status line to determine whether the deployment succeeded or failed:

    HPE 1950 APP RUNNER SUCCESS

or:

    HPE 1950 APP RUNNER FAILED

If the app log shows `HPE 1950 APP RUNNER SUCCESS`, then the `s6-rc: warning: ...` shutdown warning is not considered a deployment failure.

## Versioning Policy

This project uses small version bumps for any code, runtime behavior, app configuration, or deployment behavior change.

Documentation-only edits do not require a version bump.

Every versioned change should have a matching entry in `CHANGELOG.md`.

## Runtime Dependencies

When using the Home Assistant app/add-on, these dependencies are installed inside the app container by the included Dockerfile.

The Python script requires:

- Python 3
- PyYAML
- pexpect
- OpenSSL
- OpenSSH client
- sshpass
- curl

On Alpine-based systems, these are provided by packages similar to:

    python3
    py3-yaml
    py3-pexpect
    openssl
    openssh-client
    sshpass
    curl

Note: the Home Assistant Terminal add-on/container may not have the same Python packages as this app container. For example, importing the script directly from the Terminal environment may fail if `pexpect` is not installed there. That does not necessarily mean the app container is missing it.

Dependency helper note:

`tools/check_dependencies.sh` is a shell script, not a Python script.

Run it like this:

    ./tools/check_dependencies.sh

or:

    sh ./tools/check_dependencies.sh

Do not run it like this:

    python3 tools/check_dependencies.sh

For troubleshooting CLI/manual environments, use `tools/check_dependencies.sh`. The Home Assistant app container installs its own dependencies, so the helper is mostly for diagnostics and non-app usage.
