// Dependencies
import nikita from "@nikitajs/core";
import "@nikitajs/incus/register";
import "@nikitajs/log/register";

export default function ({ params }) {
  nikita({
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
      cwd: `${__dirname}/../../../assets`,
      command: `vagrant halt`,
    });
}
