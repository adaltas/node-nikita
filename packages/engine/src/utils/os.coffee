
path = require 'path'

module.exports =
  ###
  Shell command to print archictecture, OS name and version release to stdout.
  The following plateform are supported:
  * RH6 (RedHat, CentOS, Oracle)
  * RH7 (RHEL, CentOS, Oracle)
  * Ubuntu/Debian
  * Arch Linux
  ###
  os: """
    ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    # Red Hat and CentOS
    if [ -f /etc/redhat-release ]; then
      # CentOS: 'CentOS release 6.8 (Final)'
      # RedHat: 'Red Hat Enterprise Linux AS release 3 (Taroon)'
      # Oracle: todo
      OS=`cat /etc/redhat-release | sed 's/^\\(Red \\)\\?\\([A-Za-z]*\\).*/\\1\\2/'`
      VERSION=`cat /etc/redhat-release | sed 's/.* \\([0-9]\\)\\(\\(\\.*[0-9]\\)*\\) .*/\\1\\2/'`
    # Debian and Ubuntu
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VERSION=$DISTRIB_RELEASE
    # Arch Linux
    elif uname -r | egrep 'ARCH$' >/dev/null; then
        OS=arch
        VERSION=`uname -r | sed 's/\\(.*\\)-ARCH/\\1/'`
    else
      exit 2
    fi
    OS=`echo $OS | tr '[:upper:]' '[:lower:]'`
    echo -n "$ARCH|$OS|$VERSION"
    """
  whoami: ({ssh, platform = process.platform} = {}) ->
    return ssh.config.username if ssh
    return process.env['USERPROFILE'].split(path.win32.sep)[2] if /^win/.test platform
    return process.env['USER'] if process.env['USER']
    return process.env['HOME'].split('/')[1] if /^\/root$/.test process.env['HOME']
    return process.env['HOME'].split('/')[2] if /^\/home\/[^\/]+$/.test process.env['HOME']
  
