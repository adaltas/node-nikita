
# `nikita.service.assert`

Assert service information and status.

The option "action" takes 3 possible values: "start", "stop" and "restart". A 
service will only be restarted if it leads to a change of status. Set the value 
to "['start', 'restart']" to ensure the service will be always started.
