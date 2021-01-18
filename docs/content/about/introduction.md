---
title: Introduction
sort: 1
---

# Introduction

## Introduction

Automation is central when operating and scaling complex systems. The more servers and services there are to manage, the harder it gets for a team to fulfill their operational duties without proper automation in place.

## Purpose

Automation is a workforce multiplier that helps teams to manage ever growing infrastructure but it can do much more:

* Confidence   
  Provide the accuracy that no human could achieve.
* Consistency   
  Repeat the same process multiple times on multiple nodes with the same results.
* Refinement   
 Extend functionalities and improve reliability by incrementing the coverage of your processes.
* Center of focus   
  Liberate the minds and save time for more important engineering workforce.
* Productivity   
  Make processes faster with less room for mistakes.
* Continuous enhancement   
  Enable more safeguards over time in all stages of a process.
* Empowerment   
  Empower users to do otherwise difficult or impossible tasks in a self-service manner.
* Time to Market   
  Accelerate deployments for both users and system administrators, with shorter and fewer interruptions.

## Audience

A constant objective has been to optimize and facilitate the classical developer and operator workflow of writing, testing, versioning, configuring and deploying. Here's our approach:

* Write   
  Writing code should be easy. We didn't want to impose a new language, particularly a templating language. We choose the Node.js plateform because JavaScript is a widely adopted language, it is not too hard to learn otherwise and its package ecosystem is rich. Internally, we choose CoffeeScript over JavaScript for its expressivity and you are free to choose whichever language you like.
* Test   
  We carefully crafted a comprehensive and intuitive API. The code is easy is comprehend and it looks good. It make the writing of tests a pleasant experience, we hope you will agree with us.
* Versioning   
  In Nikita, everything is a file. No database to persist states, no agent to deploy and monitor, no server to expose any API. You could implement such dependencies but you are not forced to. Because everything is a file, it is very easy to version you source code with any SCM (Git, Mercurial...) and rely on NPM, the Node.js package manager, to package your code and its release versions.
* Configure   
  Passing configuration properties, whether it comes from a flat file, process argument or a database, is super easy, just pass a vanilla JavaScript object to your actions.
* Deploy   
  Because it only rely on files, deploy Nikita is easy. It can fully rely on version control and is quickly integrated to a CI/CD workflow if requested. There is nothing to install on the target machine and Nikita itself will not install anything either for its own purpose. On the host machine, only the Node.js engine to execute the code and NPM to deploy its dependency are expected.
