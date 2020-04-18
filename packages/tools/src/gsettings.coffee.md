
# `nikita.system.gsettings`

GSettings configuration tool

## Example

require('nikita').system.gsettings({
  properties: {
    'org.gnome.desktop.input-sources': 'xkb-options': '[\'ctrl:swap_lalt_lctl\']'
  }
})

    module.exports = ({options}) ->
      options.properties = options.argument if options.argument?
      options.properties ?= {}
      for path, properties of options.properties
        for key, value of properties
          @system.execute """
          gsettings get #{path} #{key} | grep -x "#{value}" && exit 3
          gsettings set #{path} #{key} "#{value}"
          """, code_skipped: 3
