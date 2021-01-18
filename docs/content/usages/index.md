---
sort: 2
---

# Usage

The Nikita API is simple and concise. It also powerful and comes with a lot of functionalities. This section detail the subtleties of the API organized by topics. A lot of effort were made to illustrate each topic with clear examples.

## Recommendation

Before going through the documentation, you must be familiar with the core concept of Nikita described in the [tutorial](/about/tutorial/).

## Content

The topics of this section are organized by relevance, the first ones being considered as the most relevant ones. 

* [Call and user defined handlers](/usages/call/)   
  Nikita gives you the choice between calling your own function, which we call handlers, or calling an registered function by its name.
* [Sync and async execution](/usages/sync_async/)   
  The asynchronous nature of JavaScript coupled with how Nikita register new actions can be a little tricky for newcomers. Handlers can be written in both synchronous and asynchronous based on the presence of a callback argument in the handler signature. Moreover, it is possible to write a synchronous handler which schedules asynchronous actions.
* [Status](/usages/status/)   
  The status is an information indicating whether an action had any impact or not. It's meaning may differ from one action to another, for example: touching a file, modification of a configuration file, checking if a port is open, ...
* [Local and remote (SSH) execution](/usages/local_remote/)   
  Actions are designed to run transparently either locally or remotely through SSH. The tests are themselves written to run in both modes.
* [Conditions and assertions](/usages/conditions_assertions/)   
  Conditions and assertions are a set of configs available to every handlers to control and guaranty their execution.
* [Debugging and Logging](/usages/logging_debugging/)   
  Nikita provides multiple mechanisms to report, dive into the logs and intercept instructions. Most of them can be instantaneously activated and you are provided with simple building blocks to quickly write your own.
* [Events API](/usages/events/)   
  A Nikita session extends the [native Node.js Events API](https://nodejs.org/api/events.html). It provides a facility to listen to internal notification and know the current state of the program.
* [Control Flow](/usages/control_flow/)   
  Nikita run every actions sequentially. This behavior ensures there are no conflict between two commands executed simultaneously. Moreover, this sequential nature is aligned with SSH which execute one command at a time over a given connection.
* [Error handling](/usages/error/)   
  Nikita implements error management by following familiar [Node.js](https://nodejs.org) conventions. The handling of errors different slightly between synchronous and asynchronous functions.
