// Dependencies
import dedent from "dedent";
import utils from '@nikitajs/core/utils'
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (config.srv_name == null) {
      config.srv_name = config.name;
    }
    config.name = [config.name];
    // Assert a Package is installed
    if (config.installed != null) {
      const {packages} = await this.service.installed();
      const notInstalled = config.name.filter( pck => !packages.includes(pck));
      if (notInstalled.length) {
        throw utils.error("NIKITA_SERVICE_ASSERT_NOT_INSTALLED", [
          notInstalled.length > 1
            ? `services ${notInstalled
                .map(JSON.stringify)
                .join(", ")} are not installed.`
            : `service ${JSON.stringify(notInstalled[0])} is not installed.`,
        ]);
      }
    }
    // Assert a Service is started or stopped
    // Note, this doesnt check wether a service is installed or not.
    if (!((config.started != null) || (config.stopped != null))) {
      return;
    }
    try {
      const {$status} = await this.execute({
        command: dedent`
        ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/* /etc/init.d/* 2>/dev/null | grep -w "${config.srv_name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status ${config.srv_name} || exit 3
          elif command -v service >/dev/null 2>&1; then
            service ${config.srv_name} status || exit 3
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
        `,
        code: [0, 3]
      });
      if (config.started != null) {
        if (config.started && !$status) {
          throw Error(`Service Not Started: ${config.srv_name}`);
        }
        if (!config.started && $status) {
          throw Error(`Service Started: ${config.srv_name}`);
        }
      }
      if (config.stopped != null) {
        if (config.stopped && $status) {
          throw Error(`Service Not Stopped: ${config.srv_name}`);
        }
        if (!config.stopped && !$status) {
          throw Error(`Service Stopped: ${config.srv_name}`);
        }
      }
    } catch (error) {
      if (error.exit_code === 2) {
        throw Error("Unsupported Loader");
      }
      throw error
    }
  },
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
