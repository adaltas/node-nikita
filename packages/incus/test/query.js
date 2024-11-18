import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.query", function () {
  if (!test.tags.incus) return;

  describe("base options", function () {
    they("with path", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0",
          });
          $status.should.eql(true);
          data.api_version.should.eql("1.0");
        },
      );
    });

    they("with wait option", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0",
            wait: true,
          });
          $status.should.eql(true);
          data.api_version.should.eql("1.0");
        },
      );
    });

    they("with get request option", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0",
            request: "GET",
          });
          $status.should.eql(true);
          data.api_version.should.eql("1.0");
        },
      );
    });
  });

  describe("format", function () {
    they("format json", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0",
            request: "GET",
            format: "json",
          });
          $status.should.eql(true);
          (typeof data).should.be.eql("object");
        },
      );
    });

    they("format string", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0",
            request: "GET",
            format: "string",
          });
          $status.should.eql(true);
          (typeof data).should.be.eql("string");
        },
      );
    });
  });

  describe("requests", function () {
    they("stop a container with PUT request", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-query-1", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-query-1",
            start: true,
          });
          const { $status } = await this.incus.query({
            path: "/1.0/instances/nikita-query-1/state",
            request: "PUT",
            data: { action: "stop", force: true },
            wait: true,
          });
          $status.should.eql(true);
          const { running } = await this.incus.state.running({
            name: "nikita-query-1",
          });
          running.should.eql(false);
          await this.clean();
        },
      );
    });
  });

  describe("errors", function () {
    they("call a non-existing path", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0/unknown",
            code: [0, 1],
          });
          $status.should.eql(false);
          data.should.eql({});
        },
      );
    });

    they("call a non-existing path with string", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          const { $status, data } = await this.incus.query({
            path: "/1.0/unknown",
            format: "string",
            code: [0, 1],
          });
          $status.should.eql(false);
          data.should.eql("");
        },
      );
    });

    they("didn't add a path", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function () {
          return this.incus
            .query({
              request: "GET",
            })
            .should.be.rejectedWith(/^NIKITA_SCHEMA_VALIDATION_CONFIG:/);
        },
      );
    });
  });
});
