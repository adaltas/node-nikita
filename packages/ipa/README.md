
# Nikita "ipa" package

The "ipa" package provides Nikita actions for various FreeIPA operations.

## Usage

```js
import "@nikitajs/ipa/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.ipa.user({
  uid: "my_username",
  attributes: {
    givenname: "My Firstname",
    sn: "My Lastname",
    mail: "my_username@nikita.js.org",
  },
  connection: {
    "principal": "admin",
    "password": "admin_pw",
    "url": "https://ipa.nikita.local/ipa/session/json",
  },
});
console.info("User was modified:", $status);
```

## Notes

### Permission denied on tmp

[FreeIPA install issue](https://bugzilla.redhat.com/show_bug.cgi?id=1678793)

```
[1/29]: configuring certificate server instance
[error] IOError: [Errno 13] Permission denied: "/tmp/tmp_Tm1l_"
```

Host must have `fs.protected_regular` set to `0`, eg `echo "0" > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a`. In our Physical -> VM -> LXD setup, the parameters shall be set in the VM, no restart is required to install the FreeIPA server, just uninstall it first with `ipa-server-install --uninstall` before re-executing the install command.
