
should = require 'should'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'misc', ->

  scratch = test.scratch @

  describe 'array', ->

    it 'intersect', ->
      misc.array.intersect(['a', 'c', 'd'], ['e', 'd', 'c']).should.eql ['c', 'd']
      misc.array.intersect(['a', 'c', 'd'], []).should.eql []
      misc.array.intersect([], ['e', 'd', 'c']).should.eql []

  describe 'string', ->

    it 'hash', ->
      md5 = misc.string.hash "hello"
      md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  describe 'iptables', ->

    it 'cmd change in protocol', ->
      misc.iptables.cmd([
        { chain: 'INPUT', '-j': 'ACCEPT', '-i': 'eth0', '-p': 'tcp', 'tcp|--dport': '88' }
      ], [
        { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '-i': 'eth1', '-p': 'tcp', 'tcp|--dport': '88', '-j': 'ACCEPT' }
      ]).should.eql [
        "iptables -I INPUT 1 -j ACCEPT -i eth0 -p tcp -m tcp --dport 88"
      ]

    it 'cmd change in comment', ->
      misc.iptables.cmd([
        { chain: 'INPUT', '-j': 'ACCEPT', '-i': 'eth0', 'comment|--comment': '"krb5kdc daemon"' }
      ], [
        { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '-i': 'eth1', 'comment|--comment': '"kadmin daemon"', '-j': 'ACCEPT' }
      ]).should.eql [
        "iptables -I INPUT 1 -j ACCEPT -i eth0 -m comment --comment \"krb5kdc daemon\""
      ]

    it 'normalize', ->
      misc.iptables.normalize([
        # Use shortcut for protocol
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, '-p': 'tcp' }
        # Use module arguments
        { chain: 'INPUT', jump: 'ACCEPT', dport: 88, protocol: 'udp', state: 'NEW', comment: 'krb5kdc daemon' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'tcp', 'tcp|--dport': '22' }
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'udp', 'udp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"' }
      ]

    it 'parse', ->
      misc.iptables.parse("""
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
      -A INPUT -p icmp -j ACCEPT 
      -A INPUT -i lo -j ACCEPT 
      -A INPUT -p tcp -m tcp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT 
      -A INPUT -p udp -m udp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT 
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
      -A INPUT -j REJECT --reject-with icmp-host-prohibited 
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """).should.eql [
        { rulenum: 1, '-P': 'INPUT ACCEPT', chain: 'INPUT', target: 'ACCEPT' }
        { rulenum: 2, '-P': 'FORWARD ACCEPT', chain: 'FORWARD', target: 'ACCEPT' }
        { rulenum: 3, '-P': 'OUTPUT ACCEPT', chain: 'OUTPUT', target: 'ACCEPT' }
        { rulenum: 1, '-A': 'INPUT', chain: 'INPUT', 'state|--state': 'RELATED,ESTABLISHED', '-j': 'ACCEPT' }
        { rulenum: 2, '-A': 'INPUT', chain: 'INPUT', '-p': 'icmp', '-j': 'ACCEPT' }
        { rulenum: 3, '-A': 'INPUT', chain: 'INPUT', '-i': 'lo', '-j': 'ACCEPT' }
        { rulenum: 4, '-A': 'INPUT', chain: 'INPUT', '-p': 'tcp', 'tcp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"', '-j': 'ACCEPT' }
        { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '-p': 'udp', 'udp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"', '-j': 'ACCEPT' }
        { rulenum: 6, '-A': 'INPUT', chain: 'INPUT', '-p': 'tcp', 'state|--state': 'NEW', 'tcp|--dport': '22', '-j': 'ACCEPT' }
        { rulenum: 7, '-A': 'INPUT', chain: 'INPUT', '-j': 'REJECT', '--reject-with': 'icmphostprohibited' }
        { rulenum: 8, '-A': 'FORWARD', chain: 'FORWARD', '-j': 'REJECT', '--reject-with': 'icmphostprohibited' }
      ]


  describe 'object', ->

    describe 'equals', ->

      it 'compare two objects', ->
        misc.object.equals({a: '1', b: '2'}, {a: '1', b: '2'}).should.be.true
        misc.object.equals({a: '1', b: '1'}, {a: '2', b: '2'}).should.be.false
        misc.object.equals({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.be.true
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'c']).should.be.true
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'b']).should.be.false

  describe 'pidfileStatus', ->

    they 'give 0 if pidfile math a running process', (ssh, next) ->
      fs.writeFile ssh, "#{scratch}/pid", "#{process.pid}", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 0
          next()

    they 'give 1 if pidfile does not exists', (ssh, next) ->
      misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql 1
        next()

    they 'give 2 if pidfile exists but match no process', (ssh, next) ->
      fs.writeFile ssh, "#{scratch}/pid", "666666666", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 2
          next()

  describe 'args', ->

    it 'accept 2 arguments', ->
      [goptions, options, callback] = misc.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ]
      goptions.should.eql parallel: true
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'accept 3 arguments', ->
      [goptions, options, callback] = misc.args [
        {parallel: 1}
        option_a: 'a', option_b: 'b'
        -> #do sth
      ]
      goptions.should.eql parallel: 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'overwrite default global options', ->
      [goptions, options, callback] = misc.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ], parallel: 1
      goptions.parallel.should.equal 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

  describe 'options', ->

    they 'default not_if_exists to destination if false', (ssh, next) ->
      misc.options
        ssh: ssh
        not_if_exists: true
        destination: __dirname
      , (err, options) ->
        return next err if err
        options[0].not_if_exists[0].should.eql __dirname
        next()






