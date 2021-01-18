---
title: Action
sort: 3
---

# Action

An action is the single unit of work in Nikita. Technically, it is a simple JavaScript object consisting of well defined properties as well as some specific properties related to each action. Such actions include writing a file in a given format, executing a shell command or controlling the life cycle of a Unix service.

The most important and only required option is the `handler` function, which does all the work. Handlers are designed to be stateless. They take some input information, do some work and send back some output information. They are executed sequentially, in the order of declaration. They may themselves call other actions to achieve their purpose. Thus, despite being executed sequentially, actions are organized as hierarchical trees.

The handler receives all the properties of an action as an argument. We call those properties options. They can define default values when declaring the action and the user may overwrite any of the properties. Thus, options are used to contextualize the handler.

The handler may be completed with a `callback` function which will be called once the handler has been executed. The callback is used to be notified when an action has complete or has failed. It also provides information such as an error object if one occurred, the status of the action or any additional information sent by the handler.

Remember, in the end, an action is an JavaScript object with the mandatory property "handler", and some optional properties. Some properties are common to all Nikita actions, such as the "callback" or the "retry" options, or they can be specific to an action, such as the "target" option if the `nikita.file` action indicating the path where the content is written.

## Composition

* [`options`](/action/options/) (object)   
  Properties used to contextualise the handler function.
* [`handler`](/action/handler/) (function, required)   
  Define the function that an action implements to get things done.
* [`callback`](/action/callback/) (function, required)   
  Callbacks provides a solution to catch error, retrieve status information and extract data.
* [`metadata`](/metadata/) (function, required)   
  Properties shared by all the actions and used to alter the execution flow.
* [`cascade`](/action/cascade/) (object|array, optional)   
  Propagates an option and its value to every child actions.
