---
title: Events API
sort: 6
---

# Events API

## Introduction

A Nikita session extends the [native Node.js Events API](https://nodejs.org/api/events.html). It provides a facility to listen to internal notification and know the current state of the program.

## Usage

Listening to events with the Node.js API is quite simple with the `on(event, handler)`. The "handler" argument is the function provided by the user to catch events. 

It is not recommended to call the `emit` function directly but instead your are encouraged to call the `nikita.log` function which will associate the "type" property with the event of the same name.

## Available events

The existing events provide you with multiple entry points to catch information across the entire session life cycle:

- `lifecycle`   
  It indicates execution directives which may occur at different steps of the action life cycle. it uses the "message" property as a code to define what is happening. The following values exists: `disabled_false`, `disabled_true`, `conditions_passed`, `conditions_failed`. The handler function is called with a `log` argument.
- `text`   
  It is the default event when the function `log` is called. The handler function is called with a `log` argument.
- `header`   
  It is throw before an action is called if it contains the `header` metadata.
- `stdin`   
  It represents some stdin content, used for example by the `system.execute` action to provide the script being executed.
- `diff`   
  It represents content modification, used for example by the `file` action.
- `handled`   
  It is emitted once an handler has completed, whether it failed or was successful, and before calling the callback.
- `stdout_stream`   
  It is a stream input reader receiving stdout content, used for example by the `system.execute` action to send stdout output from the executed command.
- `stderr_stream`   
  It is a stream input reader receiving stderr content, used for example by the `system.execute` action to send stderr output from the executed command.
- `end`   
  It is throw if no error occured when no more action are scheduled for execution.
- `error`   
  It is thrown when an error occurred.

The majority of the user handler is called with a single `log` argument. It is an object with the following keys:
