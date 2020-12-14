
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.copy', ->
  
  describe 'options parent', ->
    
    they 'create parent directory', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'hello'
        @fs.copy
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/a_dir/a_file"
        @fs.assert
          target: "#{tmpdir}/a_dir/a_file"
          content: 'hello'
  
    they 'throw error if false', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'hello'
        @fs.copy
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/a_dir/a_new_file"
          parent: false
        # Error is thrown by fs.base.copy, no need to check on the message here
        .should.be.rejectedWith
          code: 'NIKITA_FS_COPY_TARGET_ENOENT'
        
    they 'pass mode attribute', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'hello'
        @fs.copy
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/a_dir/a_new_file"
          parent: mode: 0o0700
          mode: 0o0604
        @fs.assert
          target: "#{tmpdir}/a_dir"
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_dir/a_new_file"
          mode: 0o0604

  describe 'file', ->

    they 'with a filename inside a existing directory', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'hello'
        @fs.copy
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/a_target"
        .should.be.finally.containEql
          status: true
        @fs.assert
          target: "#{tmpdir}/a_target"
          md5: '5d41402abc4b2a76b9719d911017c592'
        @fs.copy
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/a_target"
        .should.be.finally.containEql
          status: false
  
    they 'into a directory', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'hello'
        @fs.mkdir
          target: "#{tmpdir}/existing_dir"
        @fs.copy # Copy non existing file
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/existing_dir"
        .should.be.finally.containEql
          status: true
        @fs.assert
          target: "#{tmpdir}/existing_dir/a_file"
  
    they 'over an existing file', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/source_file", content: 'hello'
        @fs.base.writeFile "#{tmpdir}/target_file", content: 'to overwrite'
        @fs.copy
          source: "#{tmpdir}/source_file"
          target: "#{tmpdir}/target_file"
        .should.be.finally.containEql
          status: true
        @fs.assert
          target: "#{tmpdir}/target_file"
          md5: '5d41402abc4b2a76b9719d911017c592'
        @fs.copy
          source: "#{tmpdir}/source_file"
          target: "#{tmpdir}/target_file"
        .should.be.finally.containEql
          status: false
  
    they 'change permissions', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/source_file"
          content: 'hello you'
          mode: 0o0644
        @fs.base.writeFile
          target: "#{tmpdir}/target_file"
          content: 'Hello you'
          mode: 0o0644
        @fs.copy
          target: "#{tmpdir}/target_file"
          source: "#{tmpdir}/source_file"
          mode: 0o0750
        .should.be.finally.containEql
          status: true
        @fs.assert
          target: "#{tmpdir}/target_file"
          mode: 0o0750
        @fs.copy
          target: "#{tmpdir}/target_file"
          source: "#{tmpdir}/source_file"
          mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/target_file"
          mode: 0o0755
  
    they 'handle hidden files', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/.a_empty_file"
          content: 'hello'
        @fs.copy
          target: "#{tmpdir}/.a_copy"
          source: "#{tmpdir}/.a_empty_file"
        @fs.assert
          target: "#{tmpdir}/.a_copy"
          content: 'hello'
  
    they 'set permissions', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/a_source_file"
          content: ''
          mode: 0o0606
        @fs.copy
          target: "#{tmpdir}/a_target_file"
          source: "#{tmpdir}/a_source_file"
          mode: 0o0644
        @fs.assert
          target: "#{tmpdir}/a_target_file"
          mode: 0o0644
  
    they 'preserve permissions', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/a_source_file"
          content: ''
          mode: 0o0640
        @fs.copy
          source: "#{tmpdir}/a_source_file"
          target: "#{tmpdir}/a_target_file"
          preserve: true
        @fs.assert
          target: "#{tmpdir}/a_target_file"
          mode: 0o0640
  
  describe 'link', ->
  
    they 'file into file', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/org_file"
          content: 'hello'
        @fs.base.symlink
          source: "#{tmpdir}/org_file"
          target: "#{tmpdir}/ln_file"
        @fs.copy
          source: "#{tmpdir}/ln_file"
          target: "#{tmpdir}/dst_file"
        @fs.assert
          target: "#{tmpdir}/dst_file"
          content: 'hello'
  
    they 'file parent dir', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.mkdir "#{tmpdir}/source"
        @fs.base.writeFile
          content: 'hello'
          target: "#{tmpdir}/source/org_file"
        @fs.base.symlink
          source: "#{tmpdir}/source/org_file"
          target: "#{tmpdir}/source/ln_file"
        @fs.copy
          source: "#{tmpdir}/source/ln_file"
          target: "#{tmpdir}"
        @fs.assert
          target: "#{tmpdir}/ln_file"
          content: 'hello'
  
  describe 'directory', ->
  
    they 'should copy without slash at the end', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir "#{tmpdir}/source/a_dir"
        @fs.base.writeFile "#{tmpdir}/source/a_dir/a_file", content: ''
        @fs.base.writeFile "#{tmpdir}/source/a_file", content: ''
        # if the target doesn't exists, then copy as target
        @fs.copy
          source: "#{tmpdir}/source"
          target: "#{tmpdir}/target_1"
        .should.be.finally.containEql
          status: true
        @fs.assert "#{tmpdir}/target_1/a_dir/a_file"
        @fs.assert "#{tmpdir}/target_1/a_file"
        # if the target exists, then copy the folder inside target
        @fs.mkdir
          target: "#{tmpdir}/target_2"
        @fs.copy
          source: "#{tmpdir}/source"
          target: "#{tmpdir}/target_2"
        .should.be.finally.containEql
          status: true
        @fs.assert "#{tmpdir}/target_2/source/a_dir/a_file"
        @fs.assert "#{tmpdir}/target_2/source/a_file"
  
    they 'should copy the files when dir end with slash', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir "#{tmpdir}/source/a_dir"
        @fs.base.writeFile "#{tmpdir}/source/a_dir/a_file", content: ''
        @fs.base.writeFile "#{tmpdir}/source/a_file", content: ''
        # if the target doesn't exists, then copy as target
        @fs.copy
          source: "#{tmpdir}/source/"
          target: "#{tmpdir}/target_1"
        .should.be.finally.containEql
          status: true
        @fs.assert "#{tmpdir}/target_1/a_dir/a_file"
        @fs.assert "#{tmpdir}/target_1/a_file"
        # if the target exists, then copy the files inside target
        @fs.mkdir
          target: "#{tmpdir}/target_2"
        @fs.copy
          source: "#{tmpdir}/source/"
          target: "#{tmpdir}/target_2"
        .should.be.finally.containEql
          status: true
        @fs.assert "#{tmpdir}/target_2/a_dir/a_file"
        @fs.assert "#{tmpdir}/target_2/a_file"
  
    they 'should copy hidden files', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir
          target: "#{tmpdir}/a_dir"
        @fs.base.writeFile
          target: "#{tmpdir}/a_dir/a_file"
          content: ''
        @fs.base.writeFile
          target: "#{tmpdir}/a_dir/.a_hidden_file"
          content: ''
        @fs.copy
          source: "#{tmpdir}/a_dir"
          target: "#{tmpdir}/a_copy"
        {files} = await @fs.glob "#{tmpdir}/a_copy/**", dot: true
        files.sort().should.eql [
          "#{tmpdir}/a_copy"
          "#{tmpdir}/a_copy/.a_hidden_file"
          "#{tmpdir}/a_copy/a_file"
        ]
  
    they 'set permissions', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir
          target: "#{tmpdir}/a_source"
        @fs.base.writeFile
          target: "#{tmpdir}/a_source/a_file"
          content: ''
          mode: 0o0606
        @fs.mkdir
          target: "#{tmpdir}/a_source/a_dir"
          content: ''
          mode: 0o0777
        @fs.base.writeFile
          target: "#{tmpdir}/a_source/a_dir/a_file"
          content: ''
          mode: 0o0644
        @fs.copy
          target: "#{tmpdir}/a_target"
          source: "#{tmpdir}/a_source"
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_target/a_file"
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_target/a_dir"
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_target/a_dir/a_file"
          mode: 0o0700
  
    they 'preserve permissions', ({ssh}) ->
      nikita
        ssh: ssh
        metadata:
          tmpdir: true
          dirty: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir
          target: "#{tmpdir}/a_source"
        @fs.base.writeFile
          target: "#{tmpdir}/a_source/a_file"
          content: ''
          mode: 0o0611
        @fs.mkdir
          target: "#{tmpdir}/a_source/a_dir"
          mode: 0o0700
        @fs.base.writeFile
          target: "#{tmpdir}/a_source/a_dir/a_file"
          content: ''
          mode: 0o0655
        @fs.copy
          source: "#{tmpdir}/a_source"
          target: "#{tmpdir}/a_target"
          preserve: true
        @fs.assert
          target: "#{tmpdir}/a_target/a_file"
          mode: 0o0611
        @fs.assert
          target: "#{tmpdir}/a_target/a_dir"
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_target/a_dir/a_file"
          mode: 0o0655
  
    they.skip 'should copy with globing and hidden files', ({ssh}) ->
      # Todo: not yet implemented
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        # if the target doesn't exists, then copy as target
        @fs.copy
          source: "#{__dirname}/../*"
          target: "#{tmpdir}"
        , (err, {status}) ->
          status.should.be.true() unless err
        @fs.glob "#{tmpdir}/**", dot: true, (err, {files}) ->
            callback err
