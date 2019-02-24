
# Changelog

## TODO

* misc.stat: type print unknown if discovery failed
* ssh: fix tests
* fix test/api/status "set status when sync is called in async" test

## Trunk

Breaking changes:
* domain: remove option and support

New features:
* file.download: http_headers and cookies with no cache
* file.types.krb5_conf: implement merge
* file.ini: new parse_bracket_then_curly
* file.types.krb5_conf: new action
* debug: print lines
* system.authconfig: new action
* file.cache: new cookies option
* lxd.config.set: implement new action
* tools.ssh.keygen: new action
* filetypes: new my_cnf action
* conditions: executed as actions
* conditions: support sudo
* service.install: add yay support
* lxd.config.set: new action
* lxd.config.device.exists: new action
* lxd.running: new action
* lxd: added network actions
* lxd.stop: new action
* lxd.start: new action
* locale_gen: force generation if boolean
* core env: working lxd prototype

Fix:
* status: more expressive tests
* file.stat: handle empty stdout
* file.hash: enrich error message
* file.download: honors sudo
* service.init: disable templating if no context
* cascade: implement cascaded options in callbacks
* file.cson: fix merging when target is missing
* keystore_add: use command instead of which
* file.hash: use command instead of which

Cleaup:
* core: remove unnecessary transmission of ssh

Management:
* tests: update ssh2-they
* core: latest dependencies

## Version 0.9.1

Breaking changes:
* package: rename scope to nikitajs
* fs.readFile: show exemple
* system.execute: cleanup temp file with arch chroot
* package: split package under a single monorepo
* misc.file: remove module
* file.cache: rename headers to http_headers to avoid conflict

New features:
* nikita: require all dependencies
* misc.file.type: print the file type given a mode
* handler: pass session to context
* file.cache: enforce hash

Fixes:
* core: clean up file with arch chroot
* file.cache: handle false ssh options

Management:
* events: isolate tests into api/events
* aspect: isolate tests into api/aspect
* doc: minor updates

## Version 0.8.1

New features:
* file.hash: predictable hash using sort
* log: honors debug when log is disabled
* system.execute.assert: honors execute options
* misc: export db and docker

Fixes:
* system.execute: clean up tmp file
* docker.cp: migrate to options as destructured assignment
* fs.mkdir: ensure macos compatiblity by using shortcut params
* java.keystore_add: dont copy certs unless ssh and local
* java.keystore_add: new tmpdir option
* file: preserve origin permissions on update
* fs.stat: macos compatibility
* file.cache: fix undefined status argument
* ldap: options as destructuring object
* file.download: ssh null replaced by false

Cleanup:
* test: filter all test with tags

Management:
* package: latest dependencies

## Version 0.8.0

Backward incompatibilities:

* misc.file: deprecate usage of hash and compare
* misc.glob: deprecated in favour of file.glob
* context: 1st arg of handlers with the options key
* service: option action renamed state
* service: values start, stop, restart renamed started, stopped and restarted

New features:
* options.depth: definable by user
* file.glob: new action
* file.hash: new action
* system.chown: use getent
* session: dont overwrite options when undefined
* service.install: new options pacman_flags and yaourt_flags

Fixes:
* session: remove unused condition while unstacking
* file.upload: refactor and use file.hash
* cascade: overwrite default values set in session
* options status: dont return undefined when false
* fs: disable log
* system.mkdir: removed zombie call to uid_gid
* options.log: true enabling/forcing logs
* file.types.etc_passwd.read: reduce log verbosity
* file.types.etc_group.read: reduce log verbosity
* misc.ini.stringify: handle boolean values
* misc.ini.stringify: fix eol for array values
* service: 2nd argument is not a callback
* ldap: 2nd argument is not a callback
* tools.iptables: 2nd arg is not a callback

Cleanup:
* package: update license field to reflect MIT
* log: remove log from cascade and parent usage
* fs.createWriteStream: code simplification
* env: emulate systemctl
* env: rename MECANO_TEST to NIKITA_TEST_MODULE
* misc.ini: isolate misc ini into its own module
* misc.ini: reorganize tests
* file.ini: isolate tests
* register: isolate registration into its own module

## Version 0.7.0

Backward incompatibilities:
* session: renamed from context
* actions: 2nd arg in callback is now an object
* file.types.etc_group.read: rename output params user_list ot users
* file.render: remove eco dependency

New features:
* system.info.disk: new action
* system.info.system: new action

Fixes:
* ssh: fix conflict with session options
* db: honors the port property

Cleanup and minor enhancements:
* ssh: test arguments
* cascade: test array when defined in action
* mysql: isolate tests into their container
* mariadb: isolate tests into their container
* krb5: isolate tests into their own container
* mysql: freeze version 5.7 to avoid authentication issues

Management:
* package: push to current branch
* package: use https url for issues
* misc.doc: remove unused module
* package: remove fs.realpath dependency
* wrap: remove ssh2-connect dependency
* package: remove backmeup, ftp and jsftp dependencies
* package: re-activate lock file
* package: latest dependencies

## Version 0.6.8

Backward incompatibilities:
* wrap: remove connection
* log: move options.log to nikita.log
* option depth: renaming, was total_depth
* option log: remove depth and header_depth
* option action: rename option, was type
* option debug: print to stderr
* log.cli: escape new line from color
* log.cli: print to stderr

New features:
* ssh.open: accept connection
* options headers: inject parent headers
* option parent: inject parent options
* option depth: pass depth to actions
* option get: ensure options are cloned
* log: new action
* option cascade: defined as a cascaded option
* option debug: accept stdout value
* array.flatten: depth limit as 2nd argument
* cwd: marked as propagated

Fixes:
* context: fix default param handler value
* ssh: no longer reference ssh2
* cascade: honored by get actions
* cascade: global, session and action merge

Cleanup and minor enhancements:
* option cascade: test false value in action
* attempt: new test
* event end: new test
* event handled: write tests
* file.assert: isolate tests and fix buffer usage
* context: refactor arguments conversion to actions
* context: simplify options cloning
* context: remove deprecation about destination and local_source
* fs.createWriteStream: normalize error with missing parent directory
* src: ensure target paths are absolute over SSH

Management:
* travis: test against Node.js versions 8 and 10
* changelog: organize messages by group
* package: latest dependencies

## Version 0.6.7

* fs.createWriteStream: new implementation
* events: emit error and end
* system.user: catch error on reading etc/passwd
* fs.createReadStream: new sample and test
* file etc_passwrd: read sample
* system.limits: add sample
* fs: new createReadStream action
* system.cgroups: prepare store remove by cgroups in callback
* fs.mkdir: fix uid/gid ingored options
* store: move from options to context
* uid gid: externalize reading to etc_passwd and etc_group
* test: limit usage of ssh2-fs
* fs: set default argument to target
* sudo: start working on new option
* conditions: fix test after latest ssh move to action
* file.assert: handle root uid and gid
* file.assert: new trim option
* assert: remove connection
* docker: fix tests
* file.yaml: remove callback style

## Version 0.6.5

* system.chown: handle uid and gid 0
* system.execute: enforce target
* registry: registered handle non enumerable properties
* ssh: move from options to action

## Version 0.6.4

* get: new option to call synchronuous
* context: isolate internal state variables
* registry: isolate registry functions from nikita
* promise: synchronous handler may return a promise
* api: remove lazy registry in favor of return undefined unless property exists
* registry: get takes flatten and depracted options
* api: rename then as next to avoid conflict with promise #125
* package: fix npm test command
* mod: persistent configuration
* system.copy: create target parent directory
* tools.sysctl: honors backup
* file.cache: coffee esthetic
* package: update jsftp

## Version 0.6.3

* package: publishing workflow
* copy: fix multiple callback on error
* repos: auto confirmation in repolist after repo creation
* merge: duplicate arrays
* mod: new system.mod action
* kv: fix log enter in get
* ssh: improve log messages
* misc: merge buffer
* keystore: use sha1 instead of md5
* ssh_authorized_keys: new action
* tests: update mocha coffee registration
* service.init: pass empty context to render unless provided
* package: use coffescript v2
* render: ensure context is provided
* db: support mariadb engine
* log: improve and simplify CLI coloration
* api: fix aspect when call co-jointly
* db: rename postgres engine to postgresql
* connection: assert accept servers and server
* options: rename wait to sleep
* misc: isolate array functions
* service: new assert action with installed, started and stopped options
* system.copy: better fix
* system.copy: fixed parseInt
* docker: doc cleanup #119
* misc: merge support null as first argument
* rubygem: source support glob expression
* rubygem: improve test suport and resilience
* rubygem: new fetch, install and remove actions
* progragation: fix multi level propagation
* context: disable ssh auto connect if no_ssh is enabled
* system.copy: honors uid, gid, mode or preserve ownership and permissions #117
* system.copy: refactor current source code #116
* sysctl: handle empty line in merge
* sysctl: hande equal sign in comment
* ssh: allow root bootstraping if ssh is an object
* test: use skip for non applyable tests
* chmod: refactor in no callback style
* misc.mode.compare: fix after multi mode comparaison
* file.assert: accept an array of modes
* test: upgrade mocha by using promise
* propagation: prevent context option to propagate
* propagation: rename from propagated_option, refactor as object
* file.assert: validate file types
* context: end honoring promise
* package: npm lock file
* doc: migrate to nikita-www and clean up
* cron: test now passing on centos7 [bug]
* service: replace `which` by `command -v` [enhancement]
* test: rename disable_service_start to disable_service_systemctl [enhancement]
* docker centos7: update docker installation [enhancement]
* sysctl: new action [feature]
* file: set permission for backup (security fix)
* repo: fix and refactor gpg verify [bug]

## Version 0.6.2

* disabled: emit lifecycle event
* package: latest dependencies
* test: remove unrequired timeout
* cron: disabled by default, enable in docker
* file ini: value as array in stringify_then_curly
* ssh root: fix new connection after reboot
* option retry: unlimited if true
* file.types.ceph_conf: add file type for ceph configuration file
* group: handle root gid "0"
* keystore add: handle CA certs chain
* execute assert: new action
* file assert: minor improvements
* log cli: shy dislay no status change
* log cli: dont display disabled and failed conditions
* user: create parent directory
* test: use promise in bootstrap test
* file assert: uid & gid ownerships
* backup: support cmd
* keystore add: create parent directories if not exists
* tools.repo: add update option
* copy: print source and target stat logs
* compress: externalize utils functions
* keystore add: create parent directories
* service.init: reload daemon when file changed on disk
* tools.repo: refactor to support remote download
* context: introduce promise
* connection wait: fix errors
* file: fix typo and lower eof log level
* log: global options with log_csv, log_fs, log_md and log_stream
* file.assert: content as a regexp
* src: remove usage of new while creating error instances
* system.mkdir: use target in error messages
* java.keystore_add: cacert not required
* system.remove: log removed files
* chown: fix and test stat option
* src: 2 spaces md list indentation
* chown: complete refactoring
* compress and extract: support bz2 tests on centos7
* conditions: support redhat in unless_os
* context: load modules relative to process cwd
* ping: call it and receive pong
* wait.execute: pass std_log options
* execute: std_log options not disabled if undefined or null
* download: fix file based checksum validation
* java.keystore: detect if keystore exists
* condition: fix Red Hat detection
* file.properties: add exemple
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

Not yet imported!
