// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/network/utils";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    if (config.principal && !config.password) {
      throw Error(
        "Required Option: `password` is required if principal is provided"
      );
    }
    if ((config.method === "POST" || config.method === "PUT") && !config.data) {
      throw Error(
        "Required Option: `data` is required with POST and PUT requests"
      );
    }
    if (config.data != null && typeof config.data !== "string") {
      if (config.http_headers["Accept"] == null) {
        config.http_headers["Accept"] = "application/json";
      }
      if (config.http_headers["Content-Type"] == null) {
        config.http_headers["Content-Type"] = "application/json";
      }
      config.data = JSON.stringify(config.data);
    }
    if (config.http_headers == null) {
      config.http_headers = [];
    }
    if (config.cookies == null) {
      config.cookies = [];
    }
    const output = {
      body: [],
      data: void 0,
      http_version: void 0,
      headers: {},
      status_code: void 0,
      status_message: void 0,
      type: void 0,
    };
    try {
      const { stdout } = await this.execute({
        command: dedent`
          ${
            !config.principal
              ? ""
              : [
                  "echo",
                  config.password,
                  "|",
                  "kinit",
                  config.principal,
                  ">/dev/null",
                ].join(" ")
          }
          command -v curl >/dev/null || exit 90
          ${[
            "curl",
            config.timeout
              ? `--max-time '${Math.max(config.timeout / 1000)}'`
              : void 0,
            "--include", // Include protocol headers in the output (H/F)
            "--silent", // Dont print progression to stderr
            config.fail ? "--fail" : void 0,
            !config.cacert && config.url.startsWith("https:")
              ? "--insecure"
              : void 0,
            config.cacert ? "--cacert #{config.cacert}" : void 0,
            config.negotiate ? "--negotiate -u:" : void 0,
            config.location ? "--location" : void 0,
            ...Object.keys(config.http_headers).map(
              (header) =>
                `--header ${esa(header + ": " + config.http_headers[header])}`
            ),
            ...config.cookies.map((cookie) => `--cookie ${esa(cookie)}`),
            config.target ? `-o ${config.target}` : void 0,
            config.proxy ? `-x ${config.proxy}` : void 0,
            config.method !== "GET" ? `-X ${config.method}` : void 0,
            config.data
              ? `--data ${esa(config.data)}`
              : void 0,
            `${config.url}`,
          ].join(" ")}
        `,
        trap: true,
      });
      output.raw = stdout;
      let done_with_header = false;
      for (const line of utils.string.lines(stdout)) {
        if (output.body.length === 0 && /^HTTP\/[\d.]+ \d+/.test(line)) {
          done_with_header = false;
          output.headers = {};
          const [http_version, status_code, ...status_message] =
            line.split(" ");
          output.http_version = http_version.slice(5);
          output.status_code = parseInt(status_code, 10);
          output.status_message = status_message.join(" ");
          continue;
        } else if (line === "") {
          done_with_header = true;
          continue;
        }
        if (!done_with_header) {
          const [name, ...value] = line.split(":");
          output.headers[name.trim()] = value.join(":").trim();
        } else {
          output.body.push(line);
        }
      }
    } catch (err) {
      const code = utils.curl.error(err.exit_code);
      if (code) {
        throw utils.error(code, [
          `the curl command exited with code \`${err.exit_code}\`.`,
        ]);
      } else if (err.exit_code === 90) {
        throw utils.error("NIKITA_NETWORK_DOWNLOAD_CURL_REQUIRED", [
          "the `curl` command could not be found",
          "and is required to perform HTTP requests,",
          "make sure it is available in your `$PATH`.",
        ]);
      } else {
        throw err;
      }
    }
    await this.fs.chmod({
      $if: config.target && config.mode,
      mode: config.mode,
    });
    await this.fs.chown({
      $if: (config.target && config.uid != null) || config.gid != null,
      target: config.target,
      uid: config.uid,
      gid: config.gid,
    });
    if (/^application\/json(;|$)/.test(output.headers["Content-Type"])) {
      output.type = "json";
    }
    output.body = output.body.join("");
    switch (output.type) {
      case "json":
        output.data = JSON.parse(output.body);
    }
    return output;
  },
  metadata: {
    definitions: definitions,
  },
};
