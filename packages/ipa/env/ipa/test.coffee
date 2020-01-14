
module.exports =
  tags:
    ipa: true
  ipa:
    principal: 'admin'
    password: 'admin_pw'
    # referer: 'https://freeipa.nikita.local/ipa/xml'
    url: 'https://freeipa.nikita.local/ipa/session/json'
  ssh: [
    null
  ,
    sudo: true
    ssh: host: '127.0.0.1', username: 'nikita'
  ]
