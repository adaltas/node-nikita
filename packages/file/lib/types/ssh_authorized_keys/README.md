
# `nikita.file.types.ssh_authorized_keys`

Note, due to the restrictive permission imposed by sshd on the parent directory,
this action will not attempt to create nor modify the parent directory and will
throw an Error if it does not exists.
