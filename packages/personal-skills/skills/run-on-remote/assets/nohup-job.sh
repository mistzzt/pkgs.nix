#!/bin/sh
# Managed nohup jobs for the run-on-remote skill; protocol in references/nohup.md.
# Run in the remote project directory, normally piped over ssh:
#   cat nohup-job.sh - <<'EOF' | ssh <host> 'cd <dest> && bash -s -- start <run-id>'
#   <command>
#   EOF
#   ssh <host> 'cd <dest> && bash -s -- status <run-id>' < nohup-job.sh
set -eu

usage() {
    echo 'usage: start <run-id> (command follows this script on stdin) | status <run-id>' >&2
    exit 2
}

report_status() {
    if test -f "$run_dir/exit-code"; then
        echo "finished, exit code $(cat "$run_dir/exit-code")"
    elif test -f "$run_dir/pid" && kill -0 "$(cat "$run_dir/pid")" 2>/dev/null; then
        echo 'apparently running (PID check only)'
    elif test -f "$run_dir/exit-code"; then
        # The job finished between the two checks above.
        echo "finished, exit code $(cat "$run_dir/exit-code")"
    else
        echo 'unknown: process is absent and no exit code was recorded'
    fi
}

start_job() {
    umask 077
    mkdir -p "$(pwd)/.remote-runs"
    if ! mkdir "$run_dir" 2>/dev/null; then
        echo "run ID '$run_id' already used; choose a fresh ID, never reuse one" >&2
        exit 2
    fi
    printf '%s\n' "$cmd" > "$run_dir/command"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$run_dir/started-at"
    : > "$run_dir/stdout.log"
    : > "$run_dir/stderr.log"

    # The wrapper deliberately has no set -e: exit-code must be recorded on failure too.
    # shellcheck disable=SC2016 # the wrapper expands its own positional parameters
    nohup sh -c '
run_dir=$1
cmd=$2
: > "$run_dir/ready.$$" || exit 125
mv "$run_dir/ready.$$" "$run_dir/ready" || exit 125
sh -c "$cmd"
status=$?
date -u +%Y-%m-%dT%H:%M:%SZ > "$run_dir/finished-at"
printf "%s\n" "$status" > "$run_dir/exit-code.$$"
mv "$run_dir/exit-code.$$" "$run_dir/exit-code"
exit "$status"
' "remote-job:$run_id" "$run_dir" "$cmd" \
        </dev/null >"$run_dir/stdout.log" 2>"$run_dir/stderr.log" &

    job_pid=$!
    printf '%s\n' "$job_pid" > "$run_dir/pid"

    attempt=0
    while ! test -f "$run_dir/ready" && ! test -f "$run_dir/exit-code"; do
        if ! kill -0 "$job_pid" 2>/dev/null; then
            sleep 1
            # A fast-exiting job may have signaled between the checks above.
            if test -f "$run_dir/ready" || test -f "$run_dir/exit-code"; then
                break
            fi
            echo "launch failed before the wrapper became ready; inspect $run_dir/stderr.log" >&2
            exit 1
        fi
        attempt=$((attempt + 1))
        if test "$attempt" -ge 30; then
            echo "readiness not confirmed after 30s; run ID $run_id is consumed" >&2
            echo 'the job may still start: check status, never relaunch without it' >&2
            exit 1
        fi
        sleep 1
    done

    printf '%s\n' "$run_id"
}

main() {
    test "$#" -eq 2 || usage
    mode=$1
    run_id=$2

    case $run_id in
        *[!A-Za-z0-9._-]*|'')
            echo "invalid run ID '$run_id': use only letters, digits, dot, underscore, dash" >&2
            exit 2
            ;;
    esac

    # Absolute so state files land in the launch directory no matter who cds later.
    run_dir=$(pwd)/.remote-runs/$run_id

    case $mode in
        status)
            if ! test -d "$run_dir"; then
                echo "no run directory $run_dir: wrong directory, host, or run ID" >&2
                exit 2
            fi
            report_status
            ;;
        start)
            # The command is the remainder of stdin, untouched by any shell layer.
            cmd=$(cat)
            if test -z "$cmd"; then
                echo 'no command on stdin: append it after the script text' >&2
                exit 2
            fi
            start_job
            ;;
        *)
            usage
            ;;
    esac
}

# Keep this the last line: in start mode the command payload follows it on stdin.
main "$@"; exit
