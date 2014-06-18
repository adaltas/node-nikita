
misc = require './index'
jsesc = require 'jsesc'

module.exports = iptables = 
  # add_properties: ['target', 'protocol', 'dport', 'in-interface', 'out-interface', 'source', 'destination']
  add_properties: ['-p', '-s', '-d', '-g', '-i', '-o', '-f', 'tcp|--dport'] # , '-j'
  # modify_properties: ['state', 'comment']
  modify_properties: [
    '-c', 'state|--state', 'comment|--comment'
    'tcp|--source-port', 'tcp|--sport', 'tcp|--destination-port', 'tcp|--dport', 'tcp|--tcp-flags', 'tcp|--syn', 'tcp|--tcp-option'
    'udp|--source-port', 'udp|--sport', 'udp|--destination-port', 'udp|--dport']
  commands: # Used to compute rulenum
    '-A': ['chain']
    '-D': ['chain']
    '-I': ['chain']
    '-R': ['chain']
    '-P': ['chain', 'target']
    '-L': true, '-S': true, '-F': true, '-Z': true, '-N': true, '-X': true, '-E': true
  parameters: ['-p', '-s', '-d', '-j', '-g', '-i', '-o', '-f', '-c']
  parameters_inverted:
    '--protocol': '-p', '--source': '-s', '--destination': '-d', '--jump': '-j'
    '--goto': '-g', '--in-interface': '-i', '--out-interface': '-o', 
    '--fragment': '-f', '--set-counters': '-c'
  protocols:
    tcp: ['--source-port', '--sport', '--destination-port', '--dport', '--tcp-flags', '--syn', '--tcp-option']
    udp: ['--source-port', '--sport', '--destination-port', '--dport']
    udplite: []
    icmp: []
    esp: []
    ah: []
    sctp: []
    all: []
  modules:
    state: ['--state']
    comment: ['--comment']
  cmd_args: (cmd, rule) ->
    for k, v of rule
      continue if ['chain', 'rulenum'].indexOf(k) isnt -1
      continue unless v?
      if match = /^([\w]+)\|([-\w]+)$/.exec k
        module = match[1]
        arg = match[2]
        cmd += " -m #{module}"
        cmd += " #{arg} #{v}"
      else
        cmd += " #{k} #{v}"
    cmd
  cmd_modify: (rule) ->
    rule.rulenum ?= 1
    iptables.cmd_args "iptables -R #{rule.chain} #{rule.rulenum}", rule
  cmd_add: (rule) ->
    rule.rulenum ?= 1
    iptables.cmd_args "iptables -I #{rule.chain} #{rule.rulenum}", rule
  cmd: (oldrules, newrules) ->
    cmds = []
    for newrule in newrules
      create = true
      # Get add properties present in new rule
      add_properties = misc.array.intersect iptables.add_properties, Object.keys newrule
      for oldrule in oldrules
        # Add properties are the same
        if misc.object.equals newrule, oldrule, add_properties
          create = false
          # Check if we need to update
          if not misc.object.equals newrule, oldrule, iptables.modify_properties
            # Remove the command
            for k, v of oldrule
              oldrule[k] = null if iptables.commands[k]
            cmds.push iptables.cmd_modify misc.merge oldrule, newrule
        # Add properties are different
      if create
        cmds.push iptables.cmd_add newrule
    cmds
  normalize: (rules) ->
    newrules = []
    for rule in rules
      newrule = {}
      # newrule.rulenum = rule.rulenum or 1
      # Search for commands and parameters
      for k, v of rule
        # Normalize value as string
        v = rule[k] = "#{v}" if typeof v is 'number'
        # Normalize key as shortname (eg "-k")
        if k is 'chain' or k is 'rulenum'
          # v = iptables.normalize v if nk is 'rulenum' and typeof v is 'object'
          # Final name, mark key as done
          nk = k
        else if k[0..1] is '--'
          nk = iptables.parameters_inverted[k]
        else if k[0] isnt '-'
          nk = iptables.parameters_inverted["--#{k}"]
        else if iptables.parameters.indexOf(k) isnt -1
          nk = k
        # Key has changed, replace it
        if nk
          newrule[nk] = v
          rule[k] = null
      # Add prototol specific options
      if protocol = newrule['-p']
        for k in iptables.protocols[protocol]
          if rule[k]
            newrule["#{protocol}|#{k}"] = rule[k]
            rule[k] = null
          else if rule[k[2..]]
            newrule["#{protocol}|#{k}"] = rule[k[2..]]
            rule[k[2..]] = null
      for k, v of rule
        continue unless v
        k = "--#{k}" unless k[0..1] is '--'
        for mk, mvs of iptables.modules
          for mv in mvs
            if k is mv
              newrule["#{mk}|#{k}"] = v
              rule[k] = null
      for k, v of newrule
        newrule[k] = jsesc v, quotes: 'double', wrap: true unless /^[A-Za-z0-9_\/-]+$/.test v
      newrules.push newrule
    newrules

  ###
  Parse the result of `iptables -S`
  ###
  parse: (stdout) ->
    rules = []
    command = null
    command_index = 1
    for line in stdout.split /\r\n|[\n\r\u0085\u2028\u2029]/g
      continue if line.length is 0
      command_index++
      rule = {}
      i = 0
      key = ''
      value = ''
      module = null
      while i <= line.length
        char = line[i]
        forceflush = i is line.length
        newarg = (i is 0 and char is '-') or line[(i-1)..i] is ' -'
        if newarg or forceflush
          if value
            value = value.trim()
            if key is '-m'
              module = value
            else
              key = "#{module}|#{key}" if module
              rule[key] = value
            # First key is a command
            if iptables.commands[key]
              if key isnt command
                command = key
                command_index = 1
              # Determine rule number
              rule.rulenum = command_index
              if Array.isArray iptables.commands[key]
                for v, j in value.split ' '
                  rule[iptables.commands[key][j]] = v
            key = ''
            value = ''
            break if forceflush
          key += char
          while (char = line[++i]) isnt ' ' # and line[i]?
            key += char
          if iptables.parameters.indexOf(key) isnt -1
            module = null
          continue
        if char is '"'
          while (char = line[++i]) isnt '"'
            value += char
          i++
          continue
        while (char = line[++i]) isnt '-' and i < line.length
          value += char
      rules.push rule
    rules



