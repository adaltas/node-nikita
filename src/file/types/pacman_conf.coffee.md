
`nikita.file.types.pacman_conf`

pacman is a package manager utility for Arch Linux. The file is usually located 
in "/etc/pacman.conf".

## Source Code

    module.exports = (options) ->
      @file.ini
        stringify: misc.ini.stringify_single_key
      , options

## Dependencies

    misc = require '../../misc'
