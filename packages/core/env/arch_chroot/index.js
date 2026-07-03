#!node
import path from "node:path";
import sh from "dedent";
import runner from "@nikitajs/incus-runner";
const __dirname = new URL(".", import.meta.url).pathname;

runner({
  cwd: "/nikita/packages/core",
  container: "nikita-core-ssh",
  logdir: path.resolve(__dirname, "./logs"),
  cluster: {
    // project: {
    //   name: "nikita",
    // },
    containers: {
      "nikita-core-archlinux": {
        image: "images:archlinux/current",
        properties: {
          "environment.NIKITA_TEST_MODULE":
            "/nikita/packages/core/env/arch_linux/test.coffee",
          "environment.HOME": "/home/source", // Fix, Incus doesnt set HOME with --user
          "raw.idmap":
            process.env["NIKITA_INCUS_IN_VAGRANT"] ?
              "both 1000 1234"
            : `both ${process.getuid()} 1234`,
          // "raw.idmap":
          //   process.env["NIKITA_INCUS_IN_VAGRANT"] ?
          //     "both 1000 1234"
          //   : `both ${process.getuid()} 1234`,
        },
        disk: {
          nikitadir: {
            path: "/nikita",
            source:
              process.env["NIKITA_HOME"] ||
              path.join(__dirname, "../../../../"),
          },
        },
        // project: "nikita",
        ssh: {
          enabled: true,
        },
      },
    },
    provision_container: async function ({ config }) {
      await this.incus.exec({
        $header: "Dependencies",
        container: config.container,
        command: sh`
          # System update
          pacman --noconfirm -Syu
          # Package dependencies
          pacman --noconfirm -S procps grep which sed zip git
        `,
      });
      await this.incus.exec({
        $header: "Node.js",
        container: config.container,
        command: sh`
          yum install -y tar
          if command -v node ; then exit 42; fi
          curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
          . ~/.bashrc
          nvm install 22
        `,
        trap: true,
        code: [0, 42],
      });
      await this.incus.exec({
        $header: "SSH keys",
        container: config.container,
        command: sh`
          mkdir -p /root/.ssh && chmod 700 /root/.ssh
          if [ ! -f /root/.ssh/id_ed25519 ]; then
            ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ''
            cat /root/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
          fi
        `,
        trap: true,
      });
    },
  },
});
