// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (!config.server?.length) {
      log("WARN", "No connection to wait for.");
      return;
    }
    // Validate servers
    config.interval = Math.round(config.interval / 1000);
    let quorum_target = config.quorum;
    if (quorum_target && quorum_target === true) {
      quorum_target = Math.ceil(config.server.length / 2);
    } else if (quorum_target == null) {
      quorum_target = config.server.length;
    }
    if (!(config.timeout > 0)) {
      // Note, the option is not tested and doesnt seem to work from a manual test
      config.timeout = 0;
    }
    try {
      // Note, dedent failed to escape `host="\${address%%:*}"`
      // It output  `\${` instead of `${`
      // Selected solution is to separate `$` from `{` with `${''}`
      await this.execute({
        bash: true,
        command: dedent`
          function compute_md5 {
            echo $1 | openssl md5 | sed 's/^.* \([a-z0-9]*\)$/\1/g'
          }
          addresses=( ${config.server
            .map(({ host, port }) => "'" + host + "':'" + port + "'")
            .join(" ")})
          timeout=${config.timeout || ""}
          md5=\`compute_md5 $${""}{addresses[@]}\`
          randdir="${config.randdir || ""}"
          if [ -z $randir ]; then
            # shm and shmfs is also known as tmpfs
            # Provide in-memory temporary file storage
            if [ -w /dev/shm ]; then
              randdir="/dev/shm/$md5"
            else
              randdir="/tmp/$md5"
            fi
          fi
          quorum_target=${quorum_target}
          echo "[INFO] randdir is: $randdir"
          mkdir -p $randdir
          echo 3 > $randdir/signal
          echo '' > $randdir/quorum
          function get_time {
            # Return the time since epoch in millisecond
            # Note, date +%N doesn't work on MacOS, using Python instead
            # \`date +%s%N | cut -b1-13\` prints \`1652694375N\`
            if command -v python >/dev/null 2>&1; then
              python -c 'import time; print(int(time.time() * 1000))'
            else
              date +%s000
            fi
          }
          function remove_randdir {
            for address in "$${""}{addresses[@]}" ; do
              host="$${""}{address%%:*}"
              port="$${""}{address##*:}"
              rm -f $randdir/\`compute_md5 $host:$port\`
            done
          }
          function check_quorum {
            quorum_current=\`wc -l < $randdir/quorum\`
            echo "[DEBUG] Check if $quorum_current gt $quorum_target"
            if [ $quorum_current -ge $quorum_target ]; then
              echo '[INFO] Quorum is reached'
              remove_randdir
            fi
          }
          function wait_connection {
            local host=$1
            local port=$2
            local randfile4conn=$3
            local count=0
            echo "[DEBUG] Start wait for $host:$port"
            isopen="echo > '/dev/tcp/$host/$port'"
            touch "$randfile4conn"
            while [[ -f "$randfile4conn" ]] && ! \`bash -c "$isopen" 2>/dev/null\`; do
              # Exit if timeout signal is broadcasted by any child 
              if [[ $(< $randdir/signal) == '2' ]]; then exit; fi
              ((count++))
              echo "[DEBUG] Connection failed to $host:$port on attempt $count" >&2
              echo "[INFO] timeout is $timeout" >&2
              if [ ! -z "$timeout" ]; then
                current_time=\`get_time\`
                (( $start_time+$timeout > $current_time )) && echo 2 > $randdir/signal
              fi
              sleep ${config.interval}
            done
            if [[ -f "$randfile4conn" ]]; then
              echo "[DEBUG] Connection ready to $host:$port"
            fi
            echo $host:$port >> $randdir/quorum
            check_quorum
            if [ "$count" -gt "0" ]; then
              echo "[WARN] Status is now active, count is $count"
              echo 0 > $randdir/signal
            fi
          }
          start_time=\`get_time\`
          # Block until all connections are open
          for address in "$${""}{addresses[@]}" ; do
            host="$${""}{address%%:*}"
            port="$${""}{address##*:}"
            randfile4conn=$randdir/\`compute_md5 $host:$port\`
            wait_connection $host $port $randfile4conn &
          done
          wait
          # Clean up
          signal=\`cat $randdir/signal\`
          remove_randdir
          echo "[INFO] Exit code is $signal"
          exit $signal
        `,
        code: [0, 3],
        stdin_log: false,
      });
    } catch (error) {
      if (error.exit_code === 2) {
        throw utils.error("NIKITA_TCP_WAIT_TIMEOUT", [
          `timeout reached after ${config.timeout}ms.`,
        ]);
      }
      throw error;
    }
  },
  hooks: {
    on_action: function ({ config }) {
      if (config.server) {
        if (Array.isArray(config.server)) {
          config.server = utils.array.flatten(config.server);
        } else {
          config.server = [config.server];
        }
      }
      const extract_servers = (config) => {
        if (typeof config === "string") {
          const [host, port] = config.split(":");
          config = {
            host: host,
            port: port,
          };
        }
        if (!config.host || !config.port) {
          return [];
        }
        if (config.host) {
          if (!Array.isArray(config.host)) {
            config.host = [config.host];
          }
        }
        if (config.port) {
          if (!Array.isArray(config.port)) {
            config.port = [config.port];
          }
        }
        return (config.host || [])
          .map((host) =>
            (config.port || []).map((port) => ({
              host: host,
              port: port,
            }))
          )
          .flat(Infinity);
      };
      const servers = extract_servers(config);
      if (config.server) {
        for (const server of config.server) {
          servers.push(...extract_servers(server));
        }
      }
      config.server = utils.array.flatten(servers);
    },
  },
  metadata: {
    definitions: definitions,
  },
};
