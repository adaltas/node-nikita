
# Changelog

## Trunk

* db.user: trap any error
* database: default mysql charset as utf8
* system.tmpfs: remove system.discover and fix status not modifed
* tools.repo: support http(s) protocol for source
* tools.repo: convert ugly test to unit test
* tools.repo: fix documentation
* tools.repo: repo udpate disabled by default
* tools.repo: fix path resolution
* ldap.user: discard SASL passwords
* java.keystore_add: chwon and chmod support
* service: disable stdin log for installed and outpdated
* file.properties: internal parse fn take source as first argument
* krb5.addprinc: dont pass header to child action
* ldap.add: enforce auto detection of first attribute
* conditions: normalize redhat name
* system discover: default to shy
* ldap schema: refactor
* ldap index: refactor
* database: create user with grant options
* service.init: daemon-reload based on loader only and not system.discover
* disable repo test for archlinux, ubuntu test environment
* tools.repo: add tools action to push repo file for packet manager closes #104
* file.types.yum_repo: add action to write repo file to yum format
* file.ini: complete rewrite and add source options support
* misc.ini.stringify: add escape option
* misc.regexp.esace: add example
* startup: improve error message
* misc.db: surround password by quotes
* misc.db: engine, host and username now required
* misc.db: cmd now optianal, stronger argument parsing
* properties: status detection based on diff
* properties: new comment option #103
* conditions: new if_os and unless_os #102
* ini: fix header, dont pass options to write
* options: handle user home in source and target #101
* uid_gid: fix intrusive determination of gid #100
* chown: name as main argument
* user.remove: new action #99
* system.user: isolate and refactor #98
* ssh root: fix log messages
* docker: latest node 6.10.1
* tempfs: remove unused dependencies
* group: write tests #97
* group.remove: new action #96
* group: isolate and refactor #95
* ssh.root: improve logs
* ini: detect platform if local otherwise unix styles #94
* cson: new file writer #93
* execute: support sudo #92
* service: re-introduce outdated and installed options
* context: fix error message for unregistered middleware
* service.startup: update-rc support for ubuntu #91
* service startup: refactoring and chroot support #90
* pacman_conf: target default path and rootdir support #89
* locale_gen: new file types action #88
* file: fix log information #87
* src: enforce line ending with git #83
* service: support arch-chroot in install, start, status, stop #86
* user: support arch-chroot #85
* execute: suport arch-chroot commands #84
* execute: option dirty leave temp file as is #82 
* service: support pacman #81
* travis: test with node 7 #80
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
