
# `nikita.docker.tools.service`

Run a container in a service mode. This module is just a wrapper for
`docker.run`. It declares the same configuration with the exeception of the
properties `detach` and `rm` which respectively default to `true` and `false`.

Indeed, in a service mode, the container must be detached and NOT removed by default
after execution. 
