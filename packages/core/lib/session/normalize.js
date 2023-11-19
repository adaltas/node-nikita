
export default function(action) {
  if (Array.isArray(action)) {
    return action.map(async function(action) {
      return (await import(action)).default;
    });
  }
  return action;
};
