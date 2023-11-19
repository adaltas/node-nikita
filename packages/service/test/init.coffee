
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

write_srv = ({config}) ->
  @file
    content: '''
    #!/bin/sh
    # Provides: srv
    # Description: {{description}}
    pid_file=/var/run/nikita_test
    start() {
        ( status ) && exit 0;
        nc -l 13370 1>/dev/null 2>/dev/null &
        echo $! > $pid_file
    }

    stop() {
        ( status ) || exit 0;
        kill `cat $pid_file`
        rm -rf $pid_file
    }
    status() {
        [ ! -e $pid_file ] && exit 1;
        pid=`cat $pid_file`
        kill -0 $pid
    }
    case "$1" in
        start) $1 ;;
        stop) $1 ;;
        status) $1 ;;
        *) echo $"Usage: $0 {start|stop|status}"; exit 2
    esac
    exit $?
    '''
  ,
    config

describe 'service.init.service', ->
  return unless test.tags.service_install

  they 'init file with target and source (default)', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.remove "#{tmpdir}/source/srv"
      await @call write_srv, target: "#{tmpdir}/source/srv"
      await @service.init
        source: "#{tmpdir}/source/srv"
        target: '/etc/init.d/srv'
      await @fs.assert '/etc/init.d/srv'
  
  they 'init file with source only (default)', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.remove '/etc/init.d/srv'
      await @call write_srv, target: "#{tmpdir}/source/srv"
      await @service.init
        source: "#{tmpdir}/source/srv"
      await @fs.assert '/etc/init.d/srv'
  
  they 'init file with source and name (default)', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.remove '/etc/init.d/srv_new'
      await @call write_srv, target: "#{tmpdir}/source/srv"
      await @service.init
        source: "#{tmpdir}/source/srv"
        name: 'srv_new'
      await @fs.assert '/etc/init.d/srv_new'
  
describe 'service.init.systemctl', ->
  return unless test.tags.service_systemctl

  they 'with systemctl systemd script', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $if_os: name: ['redhat','centos'], version: '7'
      $sudo: sudo
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @service.remove 'cronie'
      await @service.install 'cronie'
      await @fs.remove
        target: '/etc/init.d/crond'
      await @fs.remove
        target: '/usr/lib/systemd/system/crond.service'
      await @file
        content: '''
        [Unit]
        Description={{description}}
        After=auditd.service systemd-user-sessions.service time-sync.target

        [Service]
        EnvironmentFile=/etc/sysconfig/crond
        ExecStart=/usr/sbin/crond -n $CRONDARGS
        ExecReload=/bin/kill -HUP $MAINPID
        KillMode=process

        [Install]
        WantedBy=multi-user.target
        '''
        target: "#{tmpdir}/crond-systemd.hbs"
      {$status} = await @service.init
        source: "#{tmpdir}/crond-systemd.hbs"
        context: description: 'Command Scheduler Test 1'
        target: '/usr/lib/systemd/system/crond.service'
      $status.should.be.true()
      await @fs.assert '/usr/lib/systemd/system/crond.service'
      await @service.start
        name: 'crond'
