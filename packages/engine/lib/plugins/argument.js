// Generated by CoffeeScript 2.5.1
/*
The `argument` plugin map an argument which is not an object into a configuration property.

*/
module.exports = function() {
  return {
    module: '@nikitajs/engine/src/plugins/argument',
    hooks: {
      'nikita:session:normalize': {
        handler: function(action) {
          if (action.hasOwnProperty('argument')) {
            action.metadata.argument_name = action.argument;
            return delete action.argument;
          }
        }
      },
      'nikita:session:action': {
        handler: function(action) {
          var base, name;
          if ((base = action.config)[name = action.metadata.argument_name] == null) {
            base[name] = action.metadata.argument;
          }
          return action;
        }
      }
    }
  };
};
