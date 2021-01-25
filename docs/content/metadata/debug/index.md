
# Metadata `debug`

The `debug` metadata print detailed logs to the standard error output (`stderr`). It provides a quick and convenient solution to understand the various actions called, what they do and in which order.

* Type: `boolean`
* Default: `false`

The information thrown by the `debug` metadata is similar to the output of the [logging](/current/usages/loging_debugging/) facilities. So when shall debugging be used versus logging? The `debug` metadata is for developers who wish to punctually see on their shell what going on inside. The logging facilities are meant to be constantly activated.

## Usage

### Activating debugging

Activating debugging is easy, simply pass the `debug` metadata with a value set as `true`:

`embed:metadata/debug/samples/activate.js`

Of course, it is possible to activate debugging to the overall Nikita session by passing the metadata globally at session creation:

`embed:metadata/debug/samples/activate_globally.js`

### Redirecting output to stdout

Set the value to `stdout` if you wish to print debugging information to the standard output (`stdout`):

`embed:metadata/debug/samples/stdout.js`
