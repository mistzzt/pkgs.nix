# Host files and subtree justfiles import this file and override host/dest.
set allow-duplicate-variables := true

host := env("REMOTE_HOST", "<ssh-alias>")
dest := "<remote-dir>"
flags := "--exclude='.git/' --filter=':- .gitignore'"

# Push local changes; never deletes on the remote.
sync:
    rsync -avz {{flags}} {{justfile_directory()}}/ {{host}}:{{dest}}/

# --delete-after honors the .gitignore files delivered by this same run.
# A push that also deletes remote files gone locally; run after deletions/renames.
mirror:
    rsync -avz --delete-after {{flags}} {{justfile_directory()}}/ {{host}}:{{dest}}/

# Fetch named artifacts back; newer-wins, never deletes.
pull +paths:
    rsync -avzuR {{ prepend(host + ":" + dest + "/./", paths) }} {{justfile_directory()}}/

# Interactive shell for the user, landing in the repo. Claude composes plain ssh instead.
login:
    ssh -t {{host}} 'cd {{dest}} && exec $SHELL -l'

# One recipe per confirmed task; single quotes parse the same in any login shell
# (backslashes excepted; see the skill's Running notes):
# test:
#     ssh {{host}} 'cd {{dest}} && cargo test'
