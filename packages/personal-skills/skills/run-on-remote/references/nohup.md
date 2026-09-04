# Long-running remote tasks with nohup

Use this protocol for unattended commands that should survive an ordinary broken ssh connection. Continue to use foreground ssh for short commands, and use `tmux` instead when the user needs an interactive terminal they can reattach to.

`nohup` only protects the command from a hangup signal. A reliable detached launch must also redirect standard input, standard output, and standard error so the process does not retain the ssh connection. This skill's `assets/nohup-job.sh` implements that launch plus status checks. Pipe it over ssh as shown below instead of re-transcribing its logic, for the same reason the rsync recipes stay in `remote.just`: the shell in it is load-bearing, and a transcription slip can silently produce a job that never records its exit code. `<skill-dir>` in the commands below is this skill's directory, the one containing SKILL.md.

## Protocol

Job state lives in `.remote-runs/<run-id>/` under the remote project directory: the recorded `command`, `pid`, `started-at`, `stdout.log`, and `stderr.log`, plus `finished-at` and `exit-code` on completion.

Before the first job, add `.remote-runs/` to a `.gitignore` at or below the sync root, the directory the `just` recipes transfer. rsync's gitignore filter never reads ignore files above the transfer root, so with a subtree sync scope an entry in the repo-root `.gitignore` does not protect the remote state, and `just mirror` would delete a running job's logs and exit code.

Choose and record a unique, descriptive run ID on the local host before opening the launch ssh session, for example `test-20260830T153000Z-12345`. Use only letters, digits, dots, underscores, and dashes; the script rejects anything else. Knowing the ID before launch lets a later session recover the job even if ssh disconnects before the launch response arrives.

A run ID is consumed the moment a launch is attempted, even one that reports failure. Never reuse it, and never relaunch under a new ID until a status check has established what happened to the consumed one; otherwise two copies of the workload can run concurrently.

## Start

```bash
cat <skill-dir>/assets/nohup-job.sh - <<'EOF' | ssh <host> 'cd <dest> && bash -s -- start <run-id>'
<command>
EOF
```

The command is not an ssh argument: it follows the script on stdin and is read there as raw bytes, so no shell on either side parses it. Quotes, `$`, backslashes, pipelines, redirections, and multiple lines need no escaping, and expansion happens exactly once, remotely under `sh -c` in the project directory. Keep the heredoc delimiter quoted (`<<'EOF'`) so the local shell also leaves the command alone. The command is recorded verbatim in the `command` file.

On success the script confirms the detached wrapper signaled readiness and prints the run ID; report the ID so later ssh sessions can address the same job. On failure it prints which state the run ID is in and what to do next.

The wrapped command must remain in the foreground until its work is complete. Do not add a trailing `&`, select a daemonizing mode, or use this protocol to start a service; the exit-code file records completion of the foreground command only.

## Check status

```bash
ssh <host> 'cd <dest> && bash -s -- status <run-id>' \
    < <skill-dir>/assets/nohup-job.sh
```

Three job states are reported: `finished, exit code N`, `apparently running (PID check only)`, and `unknown`. A missing run directory is an error instead of a state and means the wrong directory, host, or run ID. The exit-code file is the only completion signal: `unknown` means the process is gone without one, from a reboot, forced termination, or another failure that bypassed the wrapper, and it is not success. A nonzero code is a remote task failure, not an ssh failure.

## Read logs

Read the current output without attaching to the process:

```bash
tail -n 200 ".remote-runs/<run-id>/stdout.log"
tail -n 200 ".remote-runs/<run-id>/stderr.log"
```

Use `tail -f` only as an observer. Disconnecting from a log-following ssh session does not affect the detached job.

## Cancellation

Do not kill the recorded PID on the user's behalf. Plain `nohup` provides no process-tree supervision: a stale PID can identify an unrelated process, and killing only the wrapper leaves its child running while status reports `unknown`.

## Limitations

- Host policy can terminate all user processes at logout even when they ignore `SIGHUP`. Use the host's service manager or scheduler on such systems.
- Do not sync or mirror changing source files over a job that assumes an immutable working tree. Use a separate checkout or run directory when that matters.
