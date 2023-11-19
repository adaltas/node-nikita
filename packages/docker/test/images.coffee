
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.images', ->
  return unless test.tags.docker

  they 'all images', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.build
        image: 'nikita/images_all'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo hello']"
      {images, count} = await @docker.images()
      images.filter( ({Repository}) -> Repository is 'nikita/images_all').should.match [
        Containers: 'N/A',
        CreatedAt: /\d{4}-\d{2}-\d{2} [\d]{2}:[\d]{2}:[\d]{2} \+0000 UTC/
        CreatedSince: /\w*/,
        Digest: '<none>',
        ID: /\w{12}/,
        Repository: 'nikita/images_all',
        SharedSize: 'N/A',
        Size: /[\d\.]+MB/,
        Tag: 'latest',
        UniqueSize: 'N/A',
        VirtualSize: /[\d\.]+MB/
      ]
      count.should.be.a.Number()
      await @docker.rmi 'nikita/images_all'

  they 'filter dangling `true`', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.build
        image: 'nikita/images_dangling_true'
        tag: 'latest'
        content: "FROM alpine\nLABEL nikita=dangling_true\nCMD ['echo 1']"
      await @docker.build
        image: 'nikita/images_dangling_true'
        tag: 'latest'
        content: "FROM alpine\nLABEL nikita=dangling_true\nCMD ['echo 2']"
      {images, count} = await @docker.images
        filters:
          label: 'nikita=dangling_true'
          dangling: true
      images.should.match [
        Repository: '<none>',
        Tag: '<none>',
      ]
      await @docker.rmi 'nikita/images_dangling_true'

  they 'filter dangling `false`', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.build
        image: 'nikita/images_dangling_false'
        tag: 'latest'
        content: "FROM alpine\nLABEL nikita=dangling_false\nCMD ['echo 1']"
      await @docker.build
        image: 'nikita/images_dangling_false'
        tag: 'latest'
        content: "FROM alpine\nLABEL nikita=dangling_false\nCMD ['echo 2']"
      {images, count} = await @docker.images
        filters:
          label: 'nikita=dangling_false'
          dangling: false
      images.should.match [
        Repository: 'nikita/images_dangling_false',
        Tag: 'latest',
      ]
      await @docker.rmi 'nikita/images_dangling_false'
