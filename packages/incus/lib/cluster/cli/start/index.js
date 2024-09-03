// Dependencies
import path from "node:path";
import dedent from "dedent";
import nikita from "@nikitajs/core";
import "@nikitajs/incus/register";
import "@nikitajs/log/register";

const key = path.relative(
  process.cwd(),
  `${__dirname}/../../../assets/.vagrant/machines/default/virtualbox/private_key`,
);

export default async function ({ params }) {
  await nikita({
    $debug: params.debug,
  })
    .log.cli({
      pad: {
        host: 20,
        header: 60,
      },
    })
    .log.md({
      basename: "start",
      basedir: params.log,
      archive: false,
      $if: params.log,
    })
    .execute({
      $header: "Dependencies",
      $unless_exec: "vagrant plugin list | egrep '^vagrant-vbguest '",
      command: `vagrant plugin install vagrant-vbguest`,
    })
    .execute({
      $header: "Vagrant",
      cwd: `${__dirname}/../../../assets`,
      command: `vagrant up`,
    })
    .execute({
      $header: "LXC remote",
      command: dedent`
      incus remote add nikita 127.0.0.1:8443 --accept-certificate --password secret
      incus remote switch nikita
    `,
    })
    .execute({
      $header: "LXC remote (update)",
      // todo: use condition for `incus ls`
      command: dedent`incus ls || {
        incus remote switch local
        incus remote remove nikita
        incus remote add nikita --accept-certificate --password secret 127.0.0.1:8443
        incus remote switch nikita
      }
    `,
    })
    .call(function () {
      return {
        $disabled: true,
        command: `ssh -i ${key} -qtt -p 2222 vagrant@127.0.0.1 -- "cd /nikita && bash"\n`,
        stdin: process.stdin,
        stderr: process.stderr,
        stdout: process.stdout,
      };
    })
    .call(function () {
      ({
        $header: "Connection",
      });
      return process.stdout.write(
        `ssh -i ${key} -qtt -p 2222 vagrant@127.0.0.1 -- "cd /nikita && bash"\n`,
      );
    });
}
