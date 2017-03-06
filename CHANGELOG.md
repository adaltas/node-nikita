
# Changelog

## Trunk

* misc.glob: only used command #79
* service: split activation between install & start #78
* service: throw err if loader not detected #77
* test: fix creation of test config file #76
* docker: test against archlinux #73
* system.execute: bash explicitly defined by its option #75
* file: support pacman conf #74
* service: remove all ref to option.store and rewrite all this mess #72

## Version 0.6.1

* backup: start complete rewrite #71
* debug: print stdin and better filter on printable logs #70 
* docker: clean up node.js downloaded archive #69
* system discover: support oracle and cache not enabled by default #68
* docker rh: pass hash test by installing openssl #67
* docker ubuntu: install java to support tests #66
* misc.file.hash: support for sha256 digest #65
* kv: shared key/value store with events #64
* tempfs: fix test when not executed on centos #63
* samples: update mkdir #62
* test: fix travis #60
* execute: execute a file in bash if target #61
* execute: move to system namespace #59
* cache: move to file namespace #58
* package: clean lib before coffee generation #57
* compress: code simplification #56
* compress: move to tools namespace #55
* backup: move to tools namespace #54
* registry: api documentation #53
* deprecate: new function honoring Node.js native usage #52
* extract: move to system namespace #51
* file.assert: honor option error with exist, hash and mode #50
* file.assert: new option not #49
* remove: move to system namespace #48
* file.assert: validate file mode #47
* file.assert: validate signature with sha1 and md5 #46
* copy: move to system namespace #45
* link: move to system namespace #44
* git: move to tools namespace #43
* move: move to file namespace #42
* render: move to file namespace #41
* src: normalize titles #40
* wait: rename wait/time to wait #39
* touch: move to system namespace #38
* mkdir: move to system namespace #37
* cgroups: move to system namespace #36
* chmod: move to system namespace #35
* chown: move to system namespace #34
* group: move to system namespace #33
* user: move to system namespace #32
* iptables: move to tools namespace #31
* conditions: more descriptive message #30
* package: rename to nikita #29
* changelog: time to be serious #28
* package: fix bug and repo url #27
* disable: Introduce new option "disable" #26

## Version 0.6.0
