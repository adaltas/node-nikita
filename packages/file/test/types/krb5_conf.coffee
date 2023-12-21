
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.types.krb5_conf', ->
  return unless test.tags.posix

  they 'write content (default MIT Kerberos file)', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.krb5_conf
        target: "#{tmpdir}/krb5.conf"
        content:
          'logging':
            'default': 'SYSLOG:INFO:LOCAL1'
            'kdc': 'SYSLOG:NOTICE:LOCAL1'
            'admin_server': 'SYSLOG:WARNING:LOCAL1'
          'libdefaults':
            'dns_lookup_realm': false
            'dns_lookup_kdc': false
            'ticket_lifetime': '24h'
            'renew_lifetime': '7d'
            'forwardable': true
            'allow_weak_crypto': 'false'
            'clockskew': '300'
            'rdns': 'false'
          'realms': {}
          'domain_realm': {}
          'appdefaults':
            'pam':
              'debug': false
              'ticket_lifetime': 36000
              'renew_lifetime': 36000
              'forwardable': true
              'krb4_convert': false
          'dbmodules': {}
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/krb5.conf"
        content: """
        [logging]
         default = SYSLOG:INFO:LOCAL1
         kdc = SYSLOG:NOTICE:LOCAL1
         admin_server = SYSLOG:WARNING:LOCAL1

        [libdefaults]
         dns_lookup_realm = false
         dns_lookup_kdc = false
         ticket_lifetime = 24h
         renew_lifetime = 7d
         forwardable = true
         allow_weak_crypto = false
         clockskew = 300
         rdns = false

        [realms]

        [domain_realm]

        [appdefaults]
         pam = {
          debug = false
          ticket_lifetime = 36000
          renew_lifetime = 36000
          forwardable = true
          krb4_convert = false
         }

        [dbmodules]


        """
        trim: true

  they 'merge content (default FreeIPA file)', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.types.krb5_conf
        target: "#{tmpdir}/krb5.conf"
        content:
          'libdefaults':
            'default_realm': 'AU.ADALTAS.CLOUD'
            'dns_lookup_realm': false
            'dns_lookup_kdc': false
            'rdns': false
            'dns_canonicalize_hostname': false
            'ticket_lifetime': '24h'
            'forwardable': true
            'udp_preference_limit': 0
            'default_ccache_name': 'KEYRING:persistent:%{uid}'
          'domain_realm': {}
      {$status} = await @file.types.krb5_conf
        target: "#{tmpdir}/krb5.conf"
        content:
          'libdefaults':
            'default_ccache_name': 'FILE:/tmp/krb5cc_%{uid}'
        merge: true
      $status.should.be.true()
      {$status} = await @file.types.krb5_conf
        target: "#{tmpdir}/krb5.conf"
        content:
          'libdefaults':
            'default_ccache_name': 'FILE:/tmp/krb5cc_%{uid}'
        merge: true
      $status.should.be.false()
      await @fs.assert
        target: "#{tmpdir}/krb5.conf"
        content: """
        [libdefaults]
         default_realm = AU.ADALTAS.CLOUD
         dns_lookup_realm = false
         dns_lookup_kdc = false
         rdns = false
         dns_canonicalize_hostname = false
         ticket_lifetime = 24h
         forwardable = true
         udp_preference_limit = 0
         default_ccache_name = FILE:/tmp/krb5cc_%{uid}

        [domain_realm]

        """
        trim: true
  
  they 'test depth 2 curly braket', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/krb5.conf"
        content: """
        [realms]
         DOMAIN.COM = {
          kdc = krb5.domain.com:4603
         }

        [domain_realm]
         .domain.com = DOMAIN.COM
         domain.com = DOMAIN.COM

        [appdefaults]
         pam = {
          debug = false
         }

        [dbmodules]
        """
      await @file.types.krb5_conf
        target: "#{tmpdir}/krb5.conf"
        content:
          'realms':
            'DOMAIN2.COM': {
              'kdc': 'krb5.domain2.com:4603'
            }
        merge: true
      await @fs.assert
        target: "#{tmpdir}/krb5.conf"
        content: """
        [realms]
         DOMAIN.COM = {
          kdc = krb5.domain.com:4603
         }
         DOMAIN2.COM = {
          kdc = krb5.domain2.com:4603
         }

        [domain_realm]
         .domain.com = DOMAIN.COM
         domain.com = DOMAIN.COM

        [appdefaults]
         pam = {
          debug = false
         }

        [dbmodules]
        """
        trim: true
