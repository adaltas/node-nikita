
# `nikita.ssh.root`

Prepare the system to receive password-less root login with SSL/TLS keys.

Prior executing this handler, a user with appropriate sudo permissions must be 
created. The script will use those credentials
to loggin and will try to become root with the "sudo" command. Use the "command" 
property if you must use a different command (such as "sudo su -").

Additionnally, it disables SELINUX which require a restart. The restart is 
handled by Masson and the installation procedure will continue as soon as an 
SSH connection is again available.

## Example

```js
const {$status} = await nikita.ssh.root({
  "username": "vagrant",
  "private_key_path": "/home/monsieur/.vagrant.d/insecure_private_key"
  "public_key_path": "~/.ssh/id_rsa.pub"
})
console.info(`Public key was updoaded for root user: ${$status}`)
```
