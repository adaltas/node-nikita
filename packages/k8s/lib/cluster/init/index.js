
import definitions from "./schema.json" assert { type: "json" };
// Action
export default {
    handler: async function() {
        //const configValue = Object.entries(config.config).map(([key, value]) => `--config ${key}=${value}`).join(` `)
        console.log("configValue")
    },
    metadata: {
        definitions: definitions
    }
};