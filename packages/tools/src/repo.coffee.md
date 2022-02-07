
# `nikita.tools.repo`

Setup packet manager repository. Only support yum for now.

## Example

```js
const {$status} = await nikita.tools.repo({
  source: '/tmp/centos.repo',
  clean: 'CentOs*'
})
console.info(`Repo was updated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'content':
            type: ['string', 'object']
            description: '''
            Content to write inside the repository definition file.
            '''
          'clean':
            type: 'string'
            description: '''
            Globing expression used to match replaced files. When relative, the
            path is resolved to the parent target directory which is
            '/etc/yum.repos.d' when the target is a filename.
            '''
          'gpg_dir':
            type: 'string'
            default: '/etc/pki/rpm-gpg'
            description: '''
            Directory storing GPG keys.
            '''
          'gpg_key':
            type: 'string'
            description: '''
            Import specified key into the gpg_dir specified, downloads
            the file if it's an url.
            '''
          'local':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/local'
            default: false
          'source':
            type: 'string'
            description: '''
            The source file containing the repository definition file.
            '''
          'target':
            type: 'string'
            description: '''
            Path of the repository definition file, relative to
            '/etc/yum.repos.d'.
            '''
          'update':
            type: 'boolean'
            default: false
            description: '''
            Run yum update enabling only the ids present in repo file.
            '''
          'verify':
            type: 'boolean'
            default: true
            description: '''
            Download the PGP keys if it's enabled in the repo file, keys are by
            default placed inside "/etc/pki/rpm-gpg" defined by the gpg_dir option
            and the filename is derivated from the url.
            '''
        oneOf: [
          required: ['content']
        ,
          required: ['source']
        ]

## Handler

    handler = ({config, ssh, tools: {log, path}}) ->
      # TODO wdavidw 180115, target should be mandatory and not default to the source filename
      config.target ?= path.resolve "/etc/yum.repos.d", path.basename config.source if config.source?
      config.target = path.resolve '/etc/yum.repos.d', config.target
      config.clean = path.resolve path.dirname(config.target), config.clean if config.clean
      remote_files = []
      repoids = []
      # Delete
      if config.clean
        log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        {files} = await @fs.glob config.clean
        remote_files = for file in files
          continue if file is config.target
          file
      await @fs.remove remote_files
      # Use download unless we are over ssh, in such case,
      # the source default to target host unless local is provided
      isFile = config.source and url.parse(config.source).protocol is null
      if config.source? and (not isFile or ssh? and config.local?)
        await @file.download
          cache: false
          gid: config.gid
          headers: config.headers
          location: config.location
          md5: config.md5
          mode: config.mode
          proxy: config.proxy
          source: config.source
          target: config.target
          uid: config.uid
      else if config.source?
        await @fs.copy
          gid: config.gid
          mode: config.mode
          source: config.source
          target: config.target
          uid: config.uid
      else if config.content?
        await @file.types.yum_repo
          content: config.content
          gid: config.gid
          mode: config.mode
          target: config.target
          uid: config.uid
      # Parse the definition file
      keys = []
      log "Read GPG keys from #{config.target}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
      {data} = await @fs.base.readFile
        target: config.target
        encoding: 'utf8'
      data  = utils.ini.parse_multi_brackets data
      keys = for name, section of data
        repoids.push name
        continue unless section.gpgcheck is '1'
        throw Error 'Missing gpgkey' unless config.gpg_key or section.gpgkey?
        continue unless /^http(s)??:\/\//.test section.gpgkey
        section.gpgkey
      keys.push config.gpg_key if config.gpg_key
      # Download GPG Keys
      if config.verify
        for key in keys
          log "Downloading GPG keys from #{key}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          {$status} = await @file.download
            source: key
            target: "#{config.gpg_dir}/#{path.basename key}"
          {$status} = await @execute
            $if: $status
            command: "rpm --import #{config.gpg_dir}/#{path.basename key}"
      # Clean Metadata
      {$status} = await @execute
        $if: path.relative('/etc/yum.repos.d', config.target) isnt '..' and $status
        # wdavidw: 180114, was "yum clean metadata"
        # explanation is provided in case of revert.
        # expire-cache is much faster, it forces yum to go redownload the small
        # repo files only, then if there's newer repo data, it will downloaded it.
        command: 'yum clean expire-cache; yum repolist -y'
      if config.update and $status
        await @execute
          command: """
          yum update -y --disablerepo=* --enablerepo='#{repoids.join(',')}'
          yum repolist
          """
          trap: true

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '@nikitajs/file/lib/utils'
    url = require 'url'
