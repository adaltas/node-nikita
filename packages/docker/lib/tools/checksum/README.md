
# `nikita.docker.tools.checksum`

Return the checksum of image:tag, if it exists. Note, there is no corresponding
native docker command.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if command was executed.
* `checksum`   
  Image cheksum if it exist, undefined otherwise.
