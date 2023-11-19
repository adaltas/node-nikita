import assert from "node:assert";
import nikita from "nikita";

describe("core", () => {
  it("load nikita", async () => {
    const { stdout } = await nikita.execute({
      command: "hostname",
    });
    assert(typeof stdout === "string");
  });
});
