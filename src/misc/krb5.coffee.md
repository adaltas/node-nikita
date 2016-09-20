
# Miscellaneous kerberos functions

## kinit

    krb5 = module.exports

    module.exports.kinit = (options) ->
      cmd = "kinit"
      if options.keytab is true then " -k" 
      else if options.keytab and typeof options.keytab is 'string' then cmd += " -kt #{options.keytab}"
      else if options.password then cmd = "echo #{options.password} | #{cmd}"
      else throw Error "Incoherent options: expects one of keytab or password"
      cmd += " #{options.principal}"
      cmd = krb5.su options, cmd
    
    module.exports.su = (options, cmd) ->
      cmd = "su - #{options.uid} -c '#{cmd}'" if options.uid
      cmd
