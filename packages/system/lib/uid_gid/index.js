// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    if (typeof config.uid === "string") {
      const { user } = await this.system.user.read({
        target: config.passwd_target,
        uid: config.uid,
      });
      config.uid = user.uid;
      config.default_gid = user.gid;
    }
    if (typeof config.gid === "string") {
      const { group } = await this.system.group.read({
        target: config.group_target,
        gid: config.gid,
      });
      config.gid = group.gid;
    }
    return {
      uid: config.uid,
      gid: config.gid,
      default_gid: config.default_gid,
    };
  },
  hooks: {
    on_action: function ({ config }) {
      if (typeof config.uid === "string" && /^\d+$/.test(config.uid)) {
        config.uid = parseInt(config.uid, 10);
      }
      if (typeof config.gid === "string" && /^\d+$/.test(config.gid)) {
        config.gid = parseInt(config.gid, 10);
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
