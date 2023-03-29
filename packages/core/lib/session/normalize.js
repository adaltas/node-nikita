
const properties = [
  'context', 'handler', 'hooks', 'metadata', 'config',
  'parent', 'plugins', 'registry', 'run', 'scheduler', 'state'
];

module.exports = function(action) {
  if (Array.isArray(action)) {
    return action.map(function(action) {
      return module.exports(action);
    });
  }
  return action;
};
