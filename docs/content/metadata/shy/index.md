---
navtitle: shy
---

# Metadata `shy`

The `shy` metadata disables modification of the parent action [status](/current/usages/status/) depending on the child action status where `shy` is activated.

* Type: `boolean`
* Default: `false`

By default, the status of an action will be `true` if at least one of the child action has a status of `true`. 

Sometimes, some child actions are not relevant to indicate a change of the parent action status. There are multiple reasons for this. For example, a child action has no impact, like checking prerequisites, or the change of the parent status is assumed by another sibling action.

## Usage

The `shy` metadata is a boolean. The value is `false` by default. Set the value to `true` if you wish to activate the metadata.

`embed:metadata/shy/samples/usage.js`

### Status in action's output

The action's output contains the status of the execution no matter if the `shy` metadata is activated or not.

`embed:metadata/shy/samples/output.js`
