import path from "node:path";
import { shell } from "shell";
import nikita from "@nikitajs/core";
import "@nikitajs/log/register";
import "@nikitajs/incus/register";

export default function (config) {
  return shell({
    name: "nikita-test-runner",
    description: `Execute test inside the Incus environment.`,
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
            .call("@nikitajs/incus-runner/delete", {
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
            .call("@nikitajs/incus-runner/enter", {
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
            .call("@nikitajs/incus-runner/exec", {
              ...config,
              ...params,
            });
        },
      },
      state: {
        description: `Print machine state and information.`,
        handler: async function ({ params }) {
          const { state } = await nikita({
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
            .call("@nikitajs/incus-runner/state", {
              ...config,
              ...params,
            });
          setImmediate(() => {
            process.stdout.write(
              state === "NOT_CREATED" ?
                "Container is not created."
              : `State could not be found, found ${state}.`,
            );
            process.stdout.write("\n");
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
            .call("@nikitajs/incus-runner/run", {
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
            .call("@nikitajs/incus-runner/start", {
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
            .call("@nikitajs/incus-runner/stop", {
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
            .call("@nikitajs/incus-runner/test", {
              ...config,
              ...params,
            });
        },
      },
    },
  }).route();
}
