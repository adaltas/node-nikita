
/*
Plugin `@nikitajs/core/plugins/tools/dig`

The plugin export a `dig` function which is used to traverse all the executed
action prior to the current action.

It works similarly to `walk`. However, while `walk` only traverse the parent
hierarchy of actions, `dig` walk the all tree of actions. Like `walk`, it start
with the most recently executed action to the first executed action, the root
action.

*/

import each from 'each';
import utils from '@nikitajs/core/utils';

const dig_down = async function(action, digger) {
  const results = [];
  await each(action.children.reverse(), async (child) =>
    results.push(...(await dig_down(child, digger)))
  )
  if (action.siblings) {
    await each(action.siblings.reverse(), async (sibling) =>
      results.push(...(await dig_down(sibling, digger)))
    )
  }
  const precious = await digger(action);
  if (precious !== undefined) {
    results.push(precious);
  }
  return results;
};

const dig_up = async function(action, digger) {
  const results = [];
  const precious = await digger(action);
  if (precious !== void 0) {
    results.push(precious);
  }
  if (action.siblings) {
    await each(action.siblings.reverse(), async (sibling) =>
      results.push(...(await dig_down(sibling, digger)))
    )
  }
  if (action.parent) {
    results.push(...(await dig_up(action.parent, digger)));
  }
  return results;
};

const validate = function(action, args) {
  let finder;
  if (args.length === 1) {
    // User only provides a finder function
    [finder] = args;
  } else if (args.length === 2) {
    // User provides a finder function with a starting action
    [action, finder] = args;
  } else {
    if (!action) {
      throw utils.error('TOOLS_DIG_INVALID_ARGUMENT', [
        'action signature is expected to be',
        '`finder` or `action, finder`',
        `got ${JSON.stringify(args)}`
      ]);
    }
  }
  if (!action) {
    throw utils.error('TOOLS_DIG_ACTION_FINDER_REQUIRED', [
      'argument `action` is missing and must be a valid action'
    ]);
  }
  if (!finder) {
    throw utils.error('TOOLS_DIG_FINDER_REQUIRED', [
      'argument `finder` is missing and must be a function'
    ]);
  }
  if (typeof finder !== 'function') {
    throw utils.error('TOOLS_DIG_FINDER_INVALID', [
      'argument `finder` is missing and must be a function'
    ]);
  }
  return [action, finder];
};

export default {
  name: '@nikitajs/core/plugins/tools/dig',
  hooks: {
    'nikita:action': function(action) {
      // Register function
      if (action.tools == null) {
        action.tools = {};
      }
      action.tools.dig = async function() {
        let [act, finder] = validate(action, arguments);
        return (await dig_up(act, finder));
      };
    }
  }
};
