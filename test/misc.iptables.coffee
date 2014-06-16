
should = require 'should'
iptables = if process.env.MECANO_COV then require '../lib-cov/misc/iptables' else require '../lib/misc/iptables'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'iptables', ->

  it 'cmd change in protocol', ->
    iptables.cmd([
      { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '-i': 'eth1', '-p': 'tcp', 'tcp|--dport': '88', '-j': 'ACCEPT' }
    ], [
      { chain: 'INPUT', '-j': 'ACCEPT', '-i': 'eth0', '-p': 'tcp', 'tcp|--dport': '88' }
    ]).should.eql [
      "iptables -I INPUT 1 -j ACCEPT -i eth0 -p tcp -m tcp --dport 88"
    ]

  it 'cmd change in comment', ->
    iptables.cmd([
      { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '-i': 'eth1', 'comment|--comment': '"kadmin daemon"', '-j': 'ACCEPT' }
    ], [
      { chain: 'INPUT', '-j': 'ACCEPT', '-i': 'eth1', 'comment|--comment': '"krb5kdc daemon"' }
    ]).should.eql [
      "iptables -R INPUT 1 -j ACCEPT -i eth1 -m comment --comment \"krb5kdc daemon\""
    ]

  it 'normalize', ->
    iptables.normalize([
      # Use shortcut for protocol
      { chain: 'INPUT', jump: 'ACCEPT', dport: 22, '-p': 'tcp' }
      # Use module arguments
      { chain: 'INPUT', jump: 'ACCEPT', dport: 88, protocol: 'udp', state: 'NEW', comment: 'krb5kdc daemon' }
    ]).should.eql [
      { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'tcp', 'tcp|--dport': '22' }
      { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'udp', 'udp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"' }
    ]

  it 'parse', ->
    iptables.parse("""
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

