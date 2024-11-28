import nikita from "@nikitajs/core";
import test from "../../test.coffee";
import "should";

describe("plugins.tools.schema.coercion", function () {
  if (!test.tags.api) return;

  describe("integer", function () {
    it("from string", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_string: {
                  type: ["number", "string"],
                  coercion: true,
                },
              },
            },
          },
          from_string: "123",
        },
        function ({ config }) {
          config.from_string.should.eql(123);
        },
      );
    });
  });

  describe("number", function () {
    it("from string", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_string: {
                  type: ["number", "string"],
                  coercion: true,
                },
              },
            },
          },
          from_string: "1.23",
        },
        function ({ config }) {
          config.from_string.should.eql(1.23);
        },
      );
    });

    it("from string (invalid)", function () {
      return nikita({
        $definitions: {
          config: {
            type: "object",
            properties: {
              from_string: {
                type: ["number", "string"],
                coercion: true,
              },
            },
          },
        },
        from_string: "abc",
      }).should.be.rejectedWith(
        [
          "NIKITA_SCHEMA_VALIDATION_CONFIG:",
          "one error was found in the configuration of root action:",
          "#/definitions/config/properties/from_string/coercion config/from_string",
          "fail to convert string to number,",
          'value is "abc".',
        ].join(" "),
      );
    });

    it("dont conflict with object", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_object: {
                  type: ["number", "object"],
                  coercion: true,
                },
              },
            },
          },
          from_object: { key: "value" },
        },
        function ({ config }) {
          config.from_object.should.eql({ key: "value" });
        },
      );
    });
  });

  describe("string", function () {
    it("from boolean", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_boolean_false: {
                  type: ["string", "boolean"],
                  coercion: true,
                },
                from_boolean_true: {
                  type: ["string", "boolean"],
                  coercion: true,
                },
              },
            },
          },
          from_boolean_false: false,
          from_boolean_true: true,
        },
        function ({ config }) {
          config.from_boolean_false.should.eql("");
          config.from_boolean_true.should.eql("1");
        },
      );
    });

    it("from integer and number", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_integer: {
                  type: ["string", "integer"],
                  coercion: true,
                },
                from_number: {
                  type: ["string", "number"],
                  coercion: true,
                },
              },
            },
          },
          from_integer: 123,
          from_number: 1.23,
        },
        function ({ config }) {
          config.from_integer.should.eql("123");
          config.from_number.should.eql("1.23");
        },
      );
    });

    it("dont conflict with instanceof", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_string: {
                  oneOf: [
                    {
                      type: ["string", "number"],
                      coercion: true,
                    },
                    {
                      instanceof: "Buffer",
                    },
                  ],
                },
              },
            },
          },
          from_string: "ok",
        },
        function ({ config }) {
          config.from_string.should.eql("ok");
        },
      );
    });
  });

  describe("boolean", function () {
    it("from string", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_string_empty: {
                  type: ["boolean", "string"],
                  coercion: true,
                },
                from_string_filled: {
                  type: ["boolean", "string"],
                  coercion: true,
                },
              },
            },
          },
          from_string_empty: "",
          from_string_filled: "ok",
        },
        function ({ config }) {
          config.from_string_empty.should.be.false();
          config.from_string_filled.should.be.true();
        },
      );
    });

    it("from number", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_number_0: {
                  type: ["boolean", "number"],
                  coercion: true,
                },
                from_number_1: {
                  type: ["boolean", "number"],
                  coercion: true,
                },
              },
            },
          },
          from_number_0: 0,
          from_number_1: 1,
        },
        function ({ config }) {
          config.from_number_0.should.be.false();
          config.from_number_1.should.be.true();
        },
      );
    });

    it("from array (invalid)", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_array: {
                  type: ["boolean", "array"],
                  coercion: true,
                },
              },
            },
          },
          from_array: [0],
        },
        function ({ config }) {
          config.from_array.should.eql([0]);
        },
      );
    });
  });

  describe("array", function () {
    it("from string and object", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_string_empty: {
                  type: ["array", "string"],
                  coercion: true,
                },
                from_string_filled: {
                  type: ["array", "string"],
                  coercion: true,
                },
                from_object: {
                  type: ["array", "object"],
                  coercion: true,
                },
              },
            },
          },
          from_string_empty: "",
          from_string_filled: "ok",
          from_object: { key: "value" },
        },
        function ({ config }) {
          config.from_string_empty.should.eql([""]);
          config.from_string_filled.should.eql(["ok"]);
          config.from_object.should.eql([{ key: "value" }]);
        },
      );
    });

    it("with types", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                to_integer_from_string: {
                  type: "array",
                  coercion: true,
                  items: {
                    type: ["integer", "string"],
                    coercion: true,
                  },
                },
                to_boolean_false_from_string: {
                  type: "array",
                  coercion: true,
                  items: {
                    type: ["boolean", "string"],
                    coercion: true,
                  },
                },
                to_boolean_true_from_string: {
                  type: "array",
                  coercion: true,
                  items: {
                    type: ["boolean", "string"],
                    coercion: true,
                  },
                },
                to_boolean_true_from_integer: {
                  type: "array",
                  coercion: true,
                  items: {
                    type: ["boolean", "integer"],
                    coercion: true,
                  },
                },
                to_string_from_integer: {
                  type: "array",
                  coercion: true,
                  items: {
                    type: ["string", "integer"],
                    coercion: true,
                  },
                },
                to_string_from_boolean: {
                  type: "array",
                  coercion: true,
                  items: {
                    type: ["string", "boolean"],
                    coercion: true,
                  },
                },
              },
            },
          },
          to_integer_from_string: "744",
          to_boolean_false_from_string: "",
          to_boolean_true_from_string: "744",
          to_boolean_true_from_integer: 1,
          to_string_from_integer: 744,
          to_string_from_boolean: true,
        },
        function ({ config }) {
          config.to_integer_from_string.should.eql([744]);
          config.to_boolean_false_from_string.should.eql([false]);
          config.to_boolean_true_from_string.should.eql([true]);
          config.to_boolean_true_from_integer.should.eql([true]);
          config.to_string_from_integer.should.eql(["744"]);
          config.to_string_from_boolean.should.eql(["1"]);
        },
      );
    });

    it("array shouldnt be altered", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_array: {
                  type: ["array"],
                  coercion: true,
                },
              },
            },
          },
          from_array: ["ok"],
        },
        function ({ config }) {
          config.from_array.should.eql(["ok"]);
        },
      );
    });

    it("forward coerced value to items and apply keyword", function () {
      return nikita(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                from_string: {
                  type: ["array", "string"],
                  coercion: true,
                  items: {
                    type: ["string", "integer"],
                    filemode: true,
                  },
                },
              },
            },
          },
          from_string: "744",
        },
        function ({ config }) {
          config.from_string.should.eql([0o0744]);
        },
      );
    });
  });
});
