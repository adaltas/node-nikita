import path from "node:path";
import dedent from "dedent";
import runner from "@nikitajs/lxd-runner";
const dirname = new URL(".", import.meta.url).pathname;

await runner({
  cwd: "/nikita/packages/service",
  container: "nikita-service-systemctl",
  logdir: path.resolve(dirname, "./logs"),
  cluster: {
    containers: {
      "nikita-service-systemctl": {
        image: "images:rockylinux/9",
        properties: {
          "environment.NIKITA_TEST_MODULE":
            "/nikita/packages/service/env/systemctl/test.coffee",
          "raw.idmap": process.env["NIKITA_LXD_IN_VAGRANT"]
            ? "both 1000 0"
            : `both ${process.getuid()} 0`,
        },
        disk: {
          nikitadir: {
            path: "/nikita",
            source:
              process.env["NIKITA_HOME"] || path.join(dirname, "../../../../"),
          },
        },
        ssh: {
          enabled: true,
        },
      },
    },
    provision_container: async function ({ config }) {
      await this.lxc.exec({
        $header: "Node.js",
        container: config.container,
        command: dedent`
          if command -v node ; then exit 42; fi
          dnf install -y tar
          curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
          . ~/.bashrc
          nvm install 16
        `,
        trap: true,
        code: [0, 42],
      });
      await this.lxc.exec({
        $header: 'SSH keys',
        container: config.container,
        command: dedent`
          mkdir -p /root/.ssh && chmod 700 /root/.ssh
          if [ ! -f /root/.ssh/id_ed25519 ]; then
            ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ''
            cat /root/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
          fi
        `,
        trap: true
      });
    },
  },
});
