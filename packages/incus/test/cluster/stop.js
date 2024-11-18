import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.cluster.stop", function () {
  if (!test.tags.incus) return;

  they("stop a running cluster", function ({ ssh }) {
    this.timeout(-1); // yum install take a lot of time
    const cluster = {
      networks: {
        nktincuspub: {
          "ipv4.address": "10.10.40.1/24",
          "ipv4.nat": true,
          "ipv6.address": "none",
        },
      },
      containers: {
        "nikita-cluster-stop-1": {
          image: `images:${test.images.alpine}`,
          nic: {
            eth0: {
              name: "eth0",
              nictype: "bridged",
              parent: "nktincuspub",
            },
          },
        },
        "nikita-cluster-stop-2": {
          image: `images:${test.images.alpine}`,
          nic: {
            eth0: {
              name: "eth0",
              nictype: "bridged",
              parent: "nktincuspub",
            },
          },
        },
      },
    };

    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register(["clean"], async function () {
          await this.incus.cluster.delete({ ...cluster, force: true });
        });
        await this.clean();
        await this.incus.cluster(cluster);
        await this.wait({ time: 200 });
        const { $status } = await this.incus.cluster.stop({
          ...cluster,
          wait: true,
        });
        $status.should.be.true();
        const { state: state1 } = await this.incus.state({
          name: "nikita-cluster-stop-1",
        });
        state1.status.should.eql("Stopped");
        const { state: state2 } = await this.incus.state({
          name: "nikita-cluster-stop-2",
        });
        state2.status.should.eql("Stopped");
        await this.clean();
      },
    );
  });
});
