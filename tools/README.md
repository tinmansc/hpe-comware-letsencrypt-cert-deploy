# Tools

This folder contains helper scripts for setup, testing, and troubleshooting.

## Dependency Check Helper

The repository includes a helper script:

    tools/check_dependencies.sh

Run it from the repository root with:

    ./tools/check_dependencies.sh

Or, if you are already inside the `tools` directory, run:

    ./check_dependencies.sh

You can also run it explicitly with `sh`:

    sh ./tools/check_dependencies.sh

Do not run it with Python:

    python3 tools/check_dependencies.sh

That will fail because `check_dependencies.sh` is a shell script, not a Python script.

## What It Checks

The script checks for required commands and Python modules, reports what is missing, and prints a suggested install command when it recognizes the package manager.

It checks for commands such as:

    python3
    openssl
    ssh
    sftp
    sshpass
    curl

It also checks for Python modules such as:

    yaml
    pexpect

## Automatic Installation

By default, the script does not change the system.

To attempt automatic installation:

    ./tools/check_dependencies.sh --install

Review the suggested command before using `--install`.

## Home Assistant Note

The Home Assistant app/add-on container installs its own dependencies.

The Home Assistant Terminal add-on/container may not have the same packages. A dependency check failure in Terminal does not automatically mean the app container is missing that dependency.
