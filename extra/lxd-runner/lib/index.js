import path from "node:path";
import { shell } from "shell";
import nikita from "@nikitajs/core";
import "@nikitajs/log/register";
import "@nikitajs/lxd/register";

export default function (config) {
  return shell({
    name: "nikita-test-runner",
    description: `Execute test inside the LXD environment.`,
    options: {
      container: {
        default: `${config.container}`,
        description: `Name of the container.`,
        required: !config.container,
      },
      cwd: {
        default: `${config.cwd}`,
        description: `Absolute path inside the container to use as the working directory.`,
        required: !config.cwd,
      },
      debug: {
        default: false,
        type: "boolean",
        description: `Instantiate the Nikita session in debug mode.`,
      },
      logdir: {
        default: `${config.logdir}`,
        description: `Directory were to store the logs.`,
      },
    },
    commands: {
      delete: {
        description: `Delete a container container.`,
        options: {
          force: {
            type: "boolean",
            shortcut: "f",
            description: `Force the container removal even if it is started.`,
          },
        },
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "delete.md"),
            })
            .call("@nikitajs/lxd-runner/delete", {
              ...config,
              ...params,
            });
        },
      },
      enter: {
        description: `Open a prompt running inside the container.`,
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "enter.md"),
            })
            .call("@nikitajs/lxd-runner/enter", {
              ...config,
              ...params,
            });
        },
      },
      exec: {
        description: `Execute a command inside the container console.`,
        main: "cmd",
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "exec.md"),
            })
            .call("@nikitajs/lxd-runner/exec", {
              ...config,
              ...params,
            });
        },
      },
      state: {
        description: `Print machine state and information.`,
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "exec.md"),
            })
            .call("@nikitajs/lxd-runner/state", {
              ...config,
              ...params,
            });
        },
      },
      run: {
        description: `Start and stop the container and execute all the tests.`,
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "run.md"),
            })
            .call("@nikitajs/lxd-runner/run", {
              ...config,
              ...params,
            });
        },
      },
      start: {
        description: `Start the container.`,
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "start.md"),
            })
            .call("@nikitajs/lxd-runner/start", {
              ...config,
              ...params,
            });
        },
      },
      stop: {
        description: `Stop the container.`,
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "stop.md"),
            })
            .call("@nikitajs/lxd-runner/stop", {
              ...config,
              ...params,
            });
        },
      },
      test: {
        description: `Execute all the tests, does not start and stop the containers, see \`run\`.`,
        handler: function ({ params }) {
          return nikita({
            $debug: params.debug,
          })
            .log.cli({
              pad: {
                host: 20,
                header: 60,
              },
            })
            .log.md({
              filename: path.resolve(params.logdir, "test.md"),
            })
            .call("@nikitajs/lxd-runner/test", {
              ...config,
              ...params,
            });
        },
      },
    },
  }).route();
}
