#!/usr/bin/env sh

# Dependency checker for hpe-comware-letsencrypt-cert-deploy.
#
# Default behavior:
#   - checks required commands
#   - checks required Python modules
#   - prints suggested install commands
#   - does not modify the system
#
# Optional behavior:
#   ./tools/check_dependencies.sh --install
#
# The --install mode attempts to install missing dependencies using the
# detected package manager. Use it only if you understand what it will run.

set -u

INSTALL_MODE="false"

if [ "${1:-}" = "--install" ]; then
    INSTALL_MODE="true"
elif [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Usage:"
    echo "  ./tools/check_dependencies.sh"
    echo "  ./tools/check_dependencies.sh --install"
    exit 0
elif [ "${1:-}" != "" ]; then
    echo "Unknown option: $1"
    echo "Use --help for usage."
    exit 2
fi

REQUIRED_COMMANDS="python3 openssl ssh sftp sshpass curl"
REQUIRED_PYTHON_MODULES="yaml pexpect"

MISSING_COMMANDS=""
MISSING_MODULES=""

echo "===== HPE Comware Cert Deployer dependency check ====="
echo

echo "Checking required commands..."
for cmd in $REQUIRED_COMMANDS; do
    if command -v "$cmd" >/dev/null 2>&1; then
        found="$(command -v "$cmd")"
        echo "  PASS command: $cmd -> $found"
    else
        echo "  FAIL command: $cmd not found"
        MISSING_COMMANDS="$MISSING_COMMANDS $cmd"
    fi
done

echo
echo "Checking required Python modules..."
for module in $REQUIRED_PYTHON_MODULES; do
    if python3 -c "import $module" >/dev/null 2>&1; then
        echo "  PASS python module: $module"
    else
        echo "  FAIL python module: $module not found"
        MISSING_MODULES="$MISSING_MODULES $module"
    fi
done

echo

if [ -z "$MISSING_COMMANDS" ] && [ -z "$MISSING_MODULES" ]; then
    echo "Result: PASS"
    echo "All required commands and Python modules were found."
    exit 0
fi

echo "Result: FAIL"
echo "Some dependencies are missing."
echo

if [ -n "$MISSING_COMMANDS" ]; then
    echo "Missing commands:$MISSING_COMMANDS"
fi

if [ -n "$MISSING_MODULES" ]; then
    echo "Missing Python modules:$MISSING_MODULES"
fi

echo
echo "Suggested corrective action:"
echo

INSTALL_CMD=""

if command -v apk >/dev/null 2>&1; then
    INSTALL_CMD="apk add --no-cache python3 py3-yaml py3-pexpect openssl openssh-client sshpass curl"
    echo "Detected Alpine/apk."
    echo "Suggested command:"
    echo "  $INSTALL_CMD"

elif command -v apt-get >/dev/null 2>&1; then
    INSTALL_CMD="apt-get update && apt-get install -y python3 python3-yaml python3-pexpect openssl openssh-client sshpass curl"
    echo "Detected Debian/Ubuntu apt."
    echo "Suggested command:"
    echo "  sudo $INSTALL_CMD"

elif command -v dnf >/dev/null 2>&1; then
    INSTALL_CMD="dnf install -y python3 python3-PyYAML python3-pexpect openssl openssh-clients sshpass curl"
    echo "Detected Fedora/RHEL dnf."
    echo "Suggested command:"
    echo "  sudo $INSTALL_CMD"

elif command -v yum >/dev/null 2>&1; then
    INSTALL_CMD="yum install -y python3 python3-PyYAML python3-pexpect openssl openssh-clients sshpass curl"
    echo "Detected RHEL/CentOS yum."
    echo "Suggested command:"
    echo "  sudo $INSTALL_CMD"

elif command -v pkg >/dev/null 2>&1; then
    INSTALL_CMD="pkg install -y python3 py311-yaml py311-pexpect openssl openssh-portable sshpass curl"
    echo "Detected FreeBSD pkg."
    echo "Suggested command:"
    echo "  sudo $INSTALL_CMD"
    echo
    echo "Note: Python package names may vary by FreeBSD version."

else
    echo "Could not detect a supported package manager."
    echo
    echo "Install these manually:"
    echo "  commands: python3 openssl ssh sftp sshpass curl"
    echo "  Python modules: PyYAML pexpect"
    echo
    echo "Python modules can often be installed with:"
    echo "  python3 -m pip install PyYAML pexpect"
fi

echo
echo "Important Home Assistant note:"
echo "  The Home Assistant app/add-on container installs its own dependencies."
echo "  Your Terminal add-on/container may not have the same packages."
echo "  A failure here does not automatically mean the app container will fail."
echo

if [ "$INSTALL_MODE" = "true" ]; then
    if [ -z "$INSTALL_CMD" ]; then
        echo "--install requested, but no supported package manager was detected."
        exit 1
    fi

    echo "--install requested."
    echo "About to run:"
    echo "  $INSTALL_CMD"
    echo
    echo "Press Ctrl+C now to cancel, or wait 10 seconds to continue."
    sleep 10

    # shellcheck disable=SC2086
    $INSTALL_CMD
    exit $?
fi

echo "No changes were made."
echo "To attempt automatic installation, run:"
echo "  ./tools/check_dependencies.sh --install"

exit 1
