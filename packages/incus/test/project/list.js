import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.project.list", function () {
  if (!test.tags.incus) return;

  they("list all projects", async function ({ ssh }) {
    const projects = await nikita({ ssh: ssh })
      .incus.project.list()
      .then(({ projects }) => projects.map((project) => project.name));
    projects.should.be.an.Array();
    projects.should.containEql("default");
  });
});
