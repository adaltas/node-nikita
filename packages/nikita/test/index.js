import assert from "node:assert";
import nikita from "nikita";

describe("core", function () {
  it("load nikita", async function () {
    const { stdout } = await nikita.execute({
      command: "hostname",
    });
    assert(typeof stdout === "string");
  });
});
