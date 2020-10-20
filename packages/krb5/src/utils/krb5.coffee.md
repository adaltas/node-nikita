
# Miscellaneous kerberos functions

    module.exports = krb5 =
      kinit: (config) ->
        cmd = "kinit"
        if config.keytab is true then " -k"
        else if config.keytab and typeof config.keytab is 'string' then cmd += " -kt #{config.keytab}"
        else if config.password then cmd = "echo #{config.password} | #{cmd}"
        else throw Error "Incoherent config: expects one of keytab or password"
        cmd += " #{config.principal}"
        cmd = krb5.su config, cmd
      su: (config, cmd) ->
        cmd = "su - #{config.uid} -c '#{cmd}'" if config.uid
        cmd
