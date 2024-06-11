// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  ssh: false,
  handler: function ({ config, tools: { events } }) {
    // Events
    const close = function () {
      if (config.end) {
        return config.stream.close();
      }
    };
    events.on("diff", function (log) {
      if (!config.serializer.diff) {
        return;
      }
      const data = config.serializer.diff(log);
      if (data != null) {
        return config.stream.write(data);
      }
    });
    events.on("nikita:action:start", async function () {
      if (!config.serializer["nikita:action:start"]) {
        return;
      }
      const data = await config.serializer["nikita:action:start"].apply(
        null,
        arguments
      );
      if (data != null) {
        return config.stream.write(data);
      }
    });
    events.on("nikita:action:end", function () {
      if (!config.serializer["nikita:action:end"]) {
        return;
      }
      const data = config.serializer["nikita:action:end"].apply(null, arguments);
      if (data != null) {
        return config.stream.write(data);
      }
    });
    events.on("nikita:resolved", function ({ action }) {
      if (config.serializer["nikita:resolved"]) {
        const data = config.serializer["nikita:resolved"].apply(null, arguments);
        if (data != null) {
          config.stream.write(data);
        }
      }
      return close();
    });
    events.on("nikita:rejected", function ({ action }) {
      if (config.serializer["nikita:rejected"]) {
        const data = config.serializer["nikita:rejected"].apply(null, arguments);
        if (data != null) {
          config.stream.write(data);
        }
      }
      return close();
    });
    events.on("text", function (log) {
      if (!config.serializer.text) {
        return;
      }
      const data = config.serializer.text(log);
      if (data != null) {
        return config.stream.write(data);
      }
    });
    events.on("stdin", function (log) {
      if (!config.serializer.stdin) {
        return;
      }
      const data = config.serializer.stdin(log);
      if (data != null) {
        return config.stream.write(data);
      }
    });
    events.on("stdout_stream", function (log) {
      if (!config.serializer.stdout_stream) {
        return;
      }
      const data = config.serializer.stdout_stream(log);
      if (data != null) {
        return config.stream.write(data);
      }
    });
  },
  metadata: {
    definitions: definitions,
  },
};
