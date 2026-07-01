

# Changelog

## 0.2.1

### Changed

- Bundled `deploy_cert_hpe_comware.py` inside the Home Assistant app container.
- Updated the app runner to execute the bundled script from `/app/deploy_cert_hpe_comware.py`.
- Removed the requirement for users to manually place the Python script in `/config/scripts` before running the app.

## 0.2.0

### Changed

- Generalized the project from a fixed HPE 1950 two-switch deployment to a configurable HPE Comware deployment.
- Replaced fixed target choices with a configurable switch inventory.
- Changed switch selection from one target value to per-switch `enabled` settings.
- Changed the public add-on/app name to `HPE Comware Cert Deployer`.
- Changed the public add-on/app slug to `hpe_comware_cert_deployer`.
- Changed runner log path to `/config/scripts/hpe_comware_cert_deploy.log`.
- Changed runner status lines to `HPE COMWARE APP RUNNER SUCCESS/FAILED`.

### Added

- Added configurable certificate paths.
- Added configurable backup behavior.
- Added support for reading switch inventory from Home Assistant app options.
- Added support for passing `/data/options.json` from the app runner to the Python script.
- Added app log note pointing users to the dependency troubleshooting helper.

### Removed

- Removed hard-coded switch names, hostnames, IP addresses, and startup configuration filenames from the public script.
- Removed fixed target radio-button choices tied to the original deployment.

## 0.1.8

### Changed

- Renamed the private/local app display name to clarify that it deploys certificates to HPE 1950 switches.
- Kept the existing app slug unchanged in the private deployment to avoid breaking existing Home Assistant automation.

## 0.1.7

### Added

- Added a settings file for backup behavior.
- Added a setting to enable or disable local startup-config download/content verification.
- Added a setting to enable or disable on-switch startup-config backup creation.

### Changed

- Check mode now reports reduced assurance when startup-config download/content verification is disabled.

## 0.1.6

### Changed

- Updated the app runner so command output appears both in the Home Assistant app log and in the persistent log file.
- Improved app runner status logging.

## 0.1.5

### Added

- Added deploy mode: run check first, then apply only if check succeeds.
- Added explicit success/failure status lines for the app runner.

## 0.1.4

### Added

- Added startup configuration verification.
- Added checks for expected HTTPS/PKI configuration lines in the saved startup config.
- Added startup-config backup/download behavior for safety verification.

## 0.1.3

### Added

- Added certificate comparison between the local Home Assistant certificate and the certificate served by the switch HTTPS interface.
- Added logic to skip deployment when the served certificate already matches the local certificate.

## 0.1.2

### Added

- Added Comware PKI import flow.
- Added legacy PKCS#12 generation using OpenSSL `-legacy`.
- Added HTTPS SSL policy binding.

## 0.1.1

### Added

- Added SSH/SFTP support for legacy HPE/Comware SSH algorithms.
- Added basic switch command execution support.

## 0.1.0

### Added

- Initial proof-of-concept Home Assistant app runner.
- Added basic `check` and `apply` modes.
