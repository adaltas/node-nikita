// Dependencies
import shell from "shell";
import start from "./start.js";
import stop from "./stop.js";

shell({
  name: "incusvmhost",
  description: "Incus VM host based on Virtual Box",
  commands: {
    start: {
      description: "Start the cluster",
      options: {
        debug: {
          type: "boolean",
          shortcut: "b",
          description: "Print debug output",
        },
        log: {
          type: "string",
          description: "Path to the directory storing logs.",
        },
      },
      handler: start,
    },
    stop: {
      description: "Stop the cluster",
      options: {
        debug: {
          type: "boolean",
          shortcut: "b",
          description: "Print debug output",
        },
        log: {
          type: "string",
          description: "Path to the directory storing logs.",
        },
      },
      handler: stop,
    },
  },
}).route();
