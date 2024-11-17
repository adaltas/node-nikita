import nikita from '@nikitajs/core';
import test from '../test.js';
import mochaThey from 'mocha-they';

const they = mochaThey(test.config);

describe('incus.file.read', function() {
  if (!test.tags.incus) return;

  they('file with content', function({ssh}) {
    return nikita({
      $ssh: ssh
    }, async function({registry}) {
      registry.register('clean', function() {
        return this.incus.delete('nikita-file-read-1', {force: true});
      });
      await this.clean();
      await this.incus.init({
        image: `images:${test.images.alpine}`,
        container: 'nikita-file-read-1',
        start: true
      });
      await this.incus.exec({
        command: "echo 'ok' > /root/a_file",
        container: 'nikita-file-read-1'
      });
      const {data} = await this.incus.file.read({
        container: 'nikita-file-read-1',
        target: '/root/a_file'
      });
      data.should.eql('ok\n');
      await this.clean();
    });
  });

  they.skip('empty file', function({ssh}) {
    // See https://github.com/incus/incus/issues/11388
    return nikita({
      $ssh: ssh
    }, async function({registry}) {
      registry.register('clean', function() {
        return this.incus.delete('nikita-file-read-2', {force: true});
      });
      await this.clean();
      await this.incus.init({
        image: `images:${test.images.alpine}`,
        container: 'nikita-file-read-2',
        start: true
      });
      await this.incus.exec({
        command: "touch /root/a_file",
        container: 'nikita-file-read-2'
      });
      const {data} = await this.incus.file.read({
        container: 'nikita-file-read-2',
        target: '/root/a_file'
      });
      data.should.eql('');
      await this.clean();
    });
  });

  they('option `trim`', function({ssh}) {
    return nikita({
      $ssh: ssh
    }, async function({registry}) {
      registry.register('clean', function() {
        return this.incus.delete('nikita-file-read-3', {force: true});
      });
      await this.clean();
      await this.incus.init({
        image: `images:${test.images.alpine}`,
        container: 'nikita-file-read-3',
        start: true
      });
      await this.incus.exec({
        command: "echo 'ok' > /root/a_file",
        container: 'nikita-file-read-3'
      });
      const {data} = await this.incus.file.read({
        container: 'nikita-file-read-3',
        target: '/root/a_file',
        trim: true
      });
      data.should.eql('ok');
      await this.clean();
    });
  });
});
