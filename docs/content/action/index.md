---
sort: 3
---

# Action

An action is the single unit of work in Nikita. Technically, it is a simple JavaScript object consisting of well-defined properties as well as some specific properties related to each action. Such actions include writing a file in a given format, executing a shell command, or controlling the life cycle of a Unix service.

The most important and only required property is the [`handler` function](/current/action/handler), which does all the work. Handlers are designed to be stateless. They take some input information, do some work and send back some output information. They are executed sequentially, in the order of declaration. They may themselves call other actions to achieve their purpose. Thus, despite being executed sequentially, actions are organized as hierarchical trees.

The handler receives all the properties of the action as an argument. We call those properties [configuration](/current/action/config). They are available as `config` property and can define default values when declaring the action. Also, the user may overwrite any of the configuration properties. Thus, they are used to contextualize the handler.

Nikita's actions always return [Javascript Promise](https://nodejs.dev/learn/understanding-javascript-promises). To access the [action output](/current/action/output), you have to call an asynchronous function and "await" for the result of Promise.

Remember, in the end, an action is a JavaScript object with the mandatory property `handler`, and some configuration properties. Some properties are common to all Nikita actions, such as the [`shy`](/current/metadata/shy) or the [`relax`](/current/metadata/relax) [metadata properties](/current/metadata), or they can be specific to an action, such as the `target` configuration property of the [`nikita.file` action](/current/actions/file) indicating the path where the content is written.

## Composition

* [Config](/current/action/config/) (object)   
  Configuration properties are used to contextualize the handler function.
* [Handler](/current/action/handler/) (function, required)   
  Define the function that an action implements to get things done.
* [Output](/current/action/output/)   
  Action output is the result returned by Nikita's actions.
