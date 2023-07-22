
# `nikita.network.http.wait`

Check if one or multiple hosts listen one or multiple ports periodically over an
HTTP connection and continue once all the connections succeed. Status will be
set to "false" if the user connections succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Return

Status is set to "true" if the first connection attempt was a failure and the 
connection finaly succeeded.
