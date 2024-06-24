import path from "node:path";
import dedent from "dedent";
import runner from "@nikitajs/incus-runner";
const __dirname = new URL(".", import.meta.url).pathname;

runner({
  cwd: "/nikita/packages/system",
  container: "nikita-system-cgroups",
  logdir: path.resolve(__dirname, "./logs"),
  cluster: {
    containers: {
      "nikita-system-cgroups": {
        vm: true,
        image: "images:ubuntu/20.04",
        properties: {
          "environment.NIKITA_TEST_MODULE":
            "/nikita/packages/system/env/cgroups/test.coffee",
          "raw.idmap": process.env["NIKITA_INCUS_IN_VAGRANT"]
            ? "both 1000 0"
            : `both ${process.getuid()} 0`,
        },
        disk: {
          nikitadir: {
            path: "/nikita",
            source:
              process.env["NIKITA_HOME"] ||
              path.join(__dirname, "../../../../"),
          },
        },
        ssh: {
          enabled: false,
        },
      },
    },
    provision_container: async function ({ config }) {
      await this.incus.exec({
        $header: "Node.js",
        container: config.container,
        command: dedent`
          if command -v node ; then exit 42; fi
          curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
          . ~/.bashrc
          nvm install 22
          # NVM is sourced from ~/.bashrc which is not loaded in non interactive mode
          echo '. /root/.nvm/nvm.sh' >> /root/.profile
        `,
        trap: true,
        code: [0, 42],
      });
      await this.incus.exec({
        $header: "SSH keys",
        container: config.container,
        command: dedent`
          mkdir -p /root/.ssh && chmod 700 /root/.ssh
          if [ ! -f /root/.ssh/id_ed25519 ]; then
            ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ''
            cat /root/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
          fi
        `,
        trap: true,
      });
      await this.incus.exec({
        $header: "Package",
        container: config.container,
        // command: 'yum install -y libcgroup-tools'
        command: "apt update -y && apt install -y cgroup-tools",
      });
      return await this.incus.exec({
        $header: "cgroup configuration",
        container: config.container,
        // Ubuntu specific, centos/7 didn't require it
        command: dedent`
          cp -rp \
            /usr/share/doc/cgroup-tools/examples/cgsnapshot_blacklist.conf \
            /etc/cgsnapshot_blacklist.conf
        `,
      });
    },
  },
}).catch(function (err) {
  return console.error(err);
});
