// Dependencies
import utils from '@nikitajs/core/utils'
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    const images = await this.docker.tools
      .execute({
        format: "jsonlines",
        command: [
          "images",
          "--format '{{json .}}'",
          ...Object.keys(config.filters || []).map(
            (property) => {
              const value = config.filters[property];
              if (typeof value === 'string') {
                return '--filter ' + esa(property) + "=" + esa(value)
              }else if(typeof value === 'boolean'){
                return '--filter ' + esa(property) + "=" + esa(value ? 'true' : 'false')
              }else {
                throw utils.error('NIKITA_DOCKER_IMAGES_FILTER', [
                  'Unsupported filter value type,',
                  'expect a string or a boolean value,',
                  "got ${JSON.stringify(property)}."
                ])
              }
            }
          ),
        ].filter(Boolean).join(' '),
      })
      .then(({ data }) => data);
    return {
      count: images.length,
      images: images,
    };
  },
  metadata: {
    shy: true,
    definitions: definitions
  },
};
