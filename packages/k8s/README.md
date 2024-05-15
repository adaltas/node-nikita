
# Nikita "java" package

The "java" package provides Nikita actions to work with Java keystores and truststores.

## Usage

```js
import "@nikitajs/java/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.java.keystore.add({
  keystore: "~/path/to/keystore",
  storepass: "changeit",
  // Certificate authority
  caname: "my_caname",
  cacert: "~/path/to/certificates/cacert.pem",
  // Certificate and key
  cert: "~/path/to/certificates/node_1_cert.pem",
  name: "my_name",
  key: "~/path/to/certificates/node_1_key.pem",
  keypass: "secret",
});
console.info("Keystore was modified:", $status);
```
