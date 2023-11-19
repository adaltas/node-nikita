
// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions ={
  network: {
    http: {
      '': '@nikitajs/network/http',
      'wait': '@nikitajs/network/http/wait'
    },
    tcp: {
      'assert': '@nikitajs/network/tcp/assert',
      'wait': '@nikitajs/network/tcp/wait'
    }
  }
};

await registry.register(actions)
