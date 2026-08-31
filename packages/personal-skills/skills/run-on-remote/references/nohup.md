# Long-running remote tasks with nohup

Use this protocol for unattended commands that should survive an ordinary broken ssh connection. Continue to use foreground ssh for short commands, and use `tmux` instead when the user needs an interactive terminal they can reattach to.

`nohup` only protects the command from a hangup signal. A reliable detached launch must also redirect standard input, standard output, and standard error so the process does not retain the ssh connection.

## Before the first run

Store job state in `.remote-runs/<run-id>/` under the remote project directory. Add `.remote-runs/` to the project's `.gitignore` before launching a job; otherwise `just mirror` can delete logs or state for a running job.

Choose and record a unique, descriptive run ID on the local host before opening the launch ssh session, for example `test-20260830T153000Z-12345`. Knowing the ID before launch lets a later session recover the job even if ssh disconnects before the launch response arrives. Never reuse a directory, because stale exit files can make a new job appear complete.

Run the launch block in the remote project directory. For an agent-driven invocation, pipe the block to `ssh <host> bash -s` when its quoting is too complex for a single quoted ssh command.

## Start

Set `run_id` to the value already recorded on the local host. Set the command after the wrapper arguments. This example starts `cargo test`:

```bash
set -eu
umask 077
run_id="<run-id-chosen-locally>"
run_dir=".remote-runs/$run_id"
mkdir -p .remote-runs
mkdir "$run_dir"
printf '%s\n' 'cargo test' > "$run_dir/command"
date -u +%Y-%m-%dT%H:%M:%SZ > "$run_dir/started-at"
: > "$run_dir/stdout.log"
: > "$run_dir/stderr.log"

nohup sh -c '
run_dir=$1
shift
ready_tmp="$run_dir/ready.$$"
printf '%s' '' > "$ready_tmp" || exit 125
mv "$ready_tmp" "$run_dir/ready" || exit 125
finish() {
    status=$1
    date -u +%Y-%m-%dT%H:%M:%SZ > "$run_dir/finished-at"
    tmp="$run_dir/exit-code.$$"
    printf "%s\n" "$status" > "$tmp"
    mv "$tmp" "$run_dir/exit-code"
    exit "$status"
}
"$@"
finish "$?"
' "remote-job:$run_id" "$run_dir" cargo test \
    </dev/null \
    >"$run_dir/stdout.log" \
    2>"$run_dir/stderr.log" &

job_pid=$!
printf '%s\n' "$job_pid" > "$run_dir/pid"

attempt=0
while ! test -f "$run_dir/ready"; do
    if ! kill -0 "$job_pid" 2>/dev/null; then
        printf '%s\n' 'launch failed before the wrapper became ready' >&2
        exit 1
    fi
    attempt=$((attempt + 1))
    if test "$attempt" -ge 5; then
        printf '%s\n' 'launch readiness timed out' >&2
        exit 1
    fi
    sleep 1
done

printf '%s\n' "$run_id"
```

The exclusive `mkdir` makes a duplicate run ID fail before launch. The readiness file proves that the detached wrapper started before the block reports success. The final line confirms the previously chosen run ID; report it so later ssh sessions can address the same job.

Pass commands as separate arguments to the wrapper when possible. If the task needs shell syntax such as pipelines or redirections, make the final arguments `sh -c '<command>'` and record that exact command in the `command` file.

The wrapped command must remain in the foreground until its work is complete. Do not add a trailing `&`, select a daemonizing mode, or use this protocol to start a service; the exit-code file records completion of the foreground command only.

## Check status

Run this in the remote project directory with the recorded run ID:

```bash
run_dir=".remote-runs/<run-id>"
if test -f "$run_dir/exit-code"; then
    printf 'finished, exit code %s\n' "$(cat "$run_dir/exit-code")"
elif test -f "$run_dir/pid" && kill -0 "$(cat "$run_dir/pid")" 2>/dev/null; then
    printf '%s\n' 'apparently running (PID check only)'
else
    printf '%s\n' 'unknown, process is absent and no exit code was recorded'
fi
```

Treat the exit-code file as authoritative. The process disappearing without that file can mean a reboot, forced termination, or another failure that bypassed the wrapper. Do not report success in that state.

## Read logs

Read the current output without attaching to the process:

```bash
tail -n 200 ".remote-runs/<run-id>/stdout.log"
tail -n 200 ".remote-runs/<run-id>/stderr.log"
```

Use `tail -f` only as an observer. Disconnecting from a log-following ssh session does not affect the detached job.

## Wait for completion

Poll with separate ssh calls when possible, because one broken observation session should not obscure the job's state. On each poll, check for `exit-code`, then check the PID. Stop and report an unknown result if neither indicates a completed or running job.

After `exit-code` appears, read it and report the relevant log tail. A nonzero code is a remote task failure, not an ssh failure.

## Cancellation

Do not kill the recorded PID automatically. Plain `nohup` provides neither durable process identity nor process-tree supervision. A stale PID can identify an unrelated process, and killing only the wrapper can leave its child running while producing a misleading result.

When cancellation can be required, choose `systemd-run`, a scheduler, or another supervisor before launch. Treat an externally terminated `nohup` job without an exit-code file as unknown.

## Limitations

- PID files can become stale, and PIDs can eventually be reused. The exit-code file remains the source of truth for completed jobs.
- Host reboot does not restart the job. Absence of both a live PID and an exit-code file is an unknown result.
- Host policy can terminate all user processes at logout even when they ignore `SIGHUP`. Use the host's service manager or scheduler on such systems.
- `nohup` provides no resource limits, queueing, restart policy, or process-tree cleanup.
- Do not sync or mirror changing source files over a job that assumes an immutable working tree. Use a separate checkout or run directory when that matters.
