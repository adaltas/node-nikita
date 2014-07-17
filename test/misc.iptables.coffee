
should = require 'should'
iptables = if process.env.MECANO_COV then require '../lib-cov/misc/iptables' else require '../lib/misc/iptables'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'iptables', ->

  describe 'normalize', ->

    it 'normalize with shortcut for protocol', ->
      iptables.normalize([ # Nothing to do 
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, '-p': 'tcp' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'tcp', 'tcp|--dport': '22' }
      ]
    it 'normalize with full name for protocol', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, protocol: 'tcp' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'tcp', 'tcp|--dport': '22' }
      ]
    it 'normalize with full name for in-interface', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-i': 'lo' }
      ]
    it 'normalize with full option for protocol', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, '--protocol': 'tcp' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'tcp', 'tcp|--dport': '22' }
      ]
    it 'normalize with full name without its module prefix (see state and comment)', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 88, '-p': 'udp', state: 'NEW', comment: 'krb5kdc daemon' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'udp', 'udp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"' }
      ]
    it 'normalize with full option without its module prefix (comment)', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 88, '-p': 'tcp', '--comment': 'My comment' }
      ]).should.eql [
        { chain: 'INPUT', '-j': 'ACCEPT', '-p': 'tcp', 'tcp|--dport': '88', 'comment|--comment': '"My comment"' }
      ]
    it 'preserve input', ->
      rules = [{ chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network' }]
      JSON.stringify(iptables.normalize rules).should.eql JSON.stringify(iptables.normalize rules)

  describe 'parse', ->

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

    it 'parse empty lines', ->
      iptables.parse('\n-P INPUT ACCEPT\n').should.eql [ { rulenum: 1, '-P': 'INPUT ACCEPT', chain: 'INPUT', target: 'ACCEPT' } ]

  describe 'cmd', ->

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
        "iptables -R INPUT 5 -i eth1 -m comment --comment \"krb5kdc daemon\" -j ACCEPT"
      ]

    it 'parse and detect a change', ->
      oldrules = iptables.parse """
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
      """
      iptables.cmd(oldrules, iptables.normalize [
        chain: 'INPUT', jump: 'ACCEPT', dport: 88, '-p': 'tcp', '--comment': 'krb5kdc daemon'
      ]).should.eql [ 'iptables -R INPUT 4 -p tcp -m tcp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT' ]

    it 'compare minus sign (IPTable silently remove minus sign)', ->
      oldrules = iptables.parse """
      -A INPUT -p tcp -m tcp --dport 389 -m state --state NEW -m comment --comment "LDAP (non-secured)" -j ACCEPT 
      -A INPUT -p tcp -m tcp --dport 636 -m state --state NEW -m comment --comment "LDAP (secured)" -j ACCEPT
      """
      iptables.cmd(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', dport: 389, protocol: 'tcp', state: 'NEW', comment: "LDAP (non-secured)" }
        { chain: 'INPUT', jump: 'ACCEPT', dport: 636, protocol: 'tcp', state: 'NEW', comment: "LDAP (secured)" }
      ]).should.eql []

    it 'compare comment without any special char', ->
      oldrules = iptables.parse """
      -A INPUT -p udp -m udp --dport 53 -m state --state NEW -m comment --comment "Named" -j ACCEPT 
      -A INPUT -p tcp -m tcp --dport 53 -m state --state NEW -m comment --comment "Named" -j ACCEPT 
      """
      iptables.cmd(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', dport: 53, protocol: 'tcp', state: 'NEW', comment: "Named" }
        { chain: 'INPUT', jump: 'ACCEPT', dport: 53, protocol: 'udp', state: 'NEW', comment: "Named" }
      ]).should.eql []

  describe 'position', ->

    it 'insert rule after match', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
      -A INPUT -p icmp -j ACCEPT 
      -A INPUT -i lo -j ACCEPT 
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
      -A INPUT -j REJECT --reject-with icmp-host-prohibited 
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited 
      """
      iptables.cmd(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network', after: {'in-interface': 'lo', jump: 'ACCEPT' } }
      ]).should.eql ['iptables -I INPUT 4 -j ACCEPT -s 10.10.10.0/24 -m comment --comment "Local Network"']
      # console.log iptables.cmd(oldrules, rules)

    it 'insert rule before match', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
      -A INPUT -p icmp -j ACCEPT 
      -A INPUT -i lo -j ACCEPT 
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
      -A INPUT -j REJECT --reject-with icmp-host-prohibited 
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited 
      """
      iptables.cmd(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network', before: {'in-interface': 'lo', jump: 'ACCEPT' } }
      ]).should.eql ['iptables -I INPUT 3 -j ACCEPT -s 10.10.10.0/24 -m comment --comment "Local Network"']
      # console.log iptables.cmd(oldrules, rules)




