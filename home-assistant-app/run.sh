#!/usr/bin/with-contenv sh

set -u

LOG="/config/scripts/hpe_comware_cert_deploy.log"
SCRIPT="/app/deploy_cert_hpe_comware.py"
OPTIONS_FILE="/data/options.json"

log_line() {
    echo "$*" | tee -a "$LOG"
}

run_and_log() {
    DESC="$1"
    shift

    TMP="/tmp/hpe_comware_runner_command_output.log"

    log_line "$DESC"
    log_line "Command: $*"

    set +e
    "$@" > "$TMP" 2>&1
    RC=$?
    set -e

    cat "$TMP" | tee -a "$LOG"
    rm -f "$TMP"

    if [ "$RC" -ne 0 ]; then
        log_line "$DESC failed with rc=$RC"
        return "$RC"
    fi

    log_line "$DESC succeeded"
    return 0
}

set -e

log_line "===== $(date '+%Y-%m-%d %H:%M:%S') HPE COMWARE APP RUNNER START ====="

MODE="$(python3 - <<'PY'
import json
with open("/data/options.json", "r") as f:
    print(json.load(f).get("mode", "deploy"))
PY
)"

log_line "Mode: $MODE"
log_line "Options file: $OPTIONS_FILE"
log_line "PATH: $PATH"
log_line "openssl: $(command -v openssl || true)"
log_line "ssh: $(command -v ssh || true)"
log_line "sftp: $(command -v sftp || true)"
log_line "sshpass: $(command -v sshpass || true)"
log_line "Dependency troubleshooting helper: see tools/check_dependencies.sh in the project repository."

RESULT=0

if [ "$MODE" = "check" ]; then
    log_line "Running CHECK only."
    run_and_log "CHECK" python3 "$SCRIPT" --options-file "$OPTIONS_FILE" --check || RESULT=$?

elif [ "$MODE" = "apply" ]; then
    log_line "Running APPLY only. Note: the Python script also performs its own internal checks."
    run_and_log "APPLY" python3 "$SCRIPT" --options-file "$OPTIONS_FILE" --apply || RESULT=$?

elif [ "$MODE" = "deploy" ]; then
    log_line "Running DEPLOY mode: CHECK first, then APPLY only if CHECK succeeds."

    log_line "----- DEPLOY STEP 1: CHECK -----"
    if run_and_log "DEPLOY STEP 1: CHECK" python3 "$SCRIPT" --options-file "$OPTIONS_FILE" --check; then
        log_line "----- DEPLOY STEP 1 RESULT: CHECK PASSED -----"
        log_line "----- DEPLOY STEP 2: APPLY -----"

        if run_and_log "DEPLOY STEP 2: APPLY" python3 "$SCRIPT" --options-file "$OPTIONS_FILE" --apply; then
            log_line "----- DEPLOY STEP 2 RESULT: APPLY PASSED -----"
            RESULT=0
        else
            RESULT=$?
            log_line "----- DEPLOY STEP 2 RESULT: APPLY FAILED rc=$RESULT -----"
        fi
    else
        RESULT=$?
        log_line "----- DEPLOY STEP 1 RESULT: CHECK FAILED rc=$RESULT -----"
        log_line "Apply was skipped because check failed."
    fi

else
    log_line "Invalid mode: $MODE"
    RESULT=2
fi

if [ "$RESULT" -eq 0 ]; then
    log_line "===== $(date '+%Y-%m-%d %H:%M:%S') HPE COMWARE APP RUNNER SUCCESS ====="
else
    log_line "===== $(date '+%Y-%m-%d %H:%M:%S') HPE COMWARE APP RUNNER FAILED rc=$RESULT ====="
fi

exit "$RESULT"
