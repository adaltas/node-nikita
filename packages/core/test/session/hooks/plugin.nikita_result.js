import nikita from "@nikitajs/core";
import session from "@nikitajs/core/session";
import history from "@nikitajs/core/plugins/history";
import position from "@nikitajs/core/plugins/metadata/position";
import test from "../../test.coffee";

// Test the construction of the session namespace stored in state

describe("session.plugins.session.result", function () {
  if (!test.tags.api) return;

  it("called from root session", async function () {
    let called = false;
    await session(
      {
        $plugins: [
          function () {
            return {
              hooks: {
                "nikita:result": async function (context, handler) {
                  await new Promise((resolved) => {
                    called = true;
                    setImmediate(resolved);
                  });
                  return handler;
                },
              },
            };
          },
        ],
      },
      () => {},
    );
    called.should.be.true();
  });

  it("called before action and children resolved", async function () {
    const stack = [];
    await session(
      {
        $plugins: [
          history,
          position,
          function () {
            return {
              hooks: {
                "nikita:result": async function ({ action }, handler) {
                  await new Promise((resolved) => {
                    stack.push(
                      "session:result:" + action.metadata.position.join(","),
                    );
                    setImmediate(resolved);
                  });
                  return handler;
                },
              },
            };
          },
        ],
      },
      async function () {
        stack.push("parent:handler:start");
        await this.call(() => {
          return new Promise((resolve) =>
            setImmediate(() => {
              stack.push("child:1");
              resolve();
            }),
          );
        });
        await this.call(() => {
          stack.push("child:2");
        });
        stack.push("parent:handler:end");
        return null;
      },
    );
    stack.should.eql([
      "parent:handler:start",
      "child:1",
      "session:result:0,0",
      "child:2",
      "session:result:0,1",
      "parent:handler:end",
      "session:result:0",
    ]);
  });

  it("session catch thrown error", async function () {
    await session({
      $plugins: [
        function () {
          return {
            hooks: {
              "nikita:result": async function () {
                throw Error("catchme");
              },
            },
          };
        },
      ],
    }).should.be.rejectedWith("catchme");
  });

  it("session catch rejected error", async function () {
    await session({
      $plugins: [
        function () {
          return {
            hooks: {
              "nikita:result": async function () {
                return Promise.reject(Error("catchme"));
              },
            },
          };
        },
      ],
    }).should.be.rejectedWith("catchme");
  });
});
