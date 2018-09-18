# cleanup () { rm -rf /tmp/nikita/java_keystore_1537191205935; }
cleanup () { echo 'clean'; }
# Check password
if [ -f /tmp/nikita-test/keystore ] && ! keytool -list -keystore /tmp/nikita-test/keystore -storepass changeit >/dev/null; then
  # Keystore password is invalid, change it manually with:
  # keytool -storepasswd -keystore /tmp/nikita-test/keystore -storepass ${old_pasword} -new changeit
  cleanup; exit 2
fi
[ -f /Users/wdavidw/projects/github/nikita/test/java/keystore/certs1/cacert.pem ] || (echo 'CA file doesnt not exists: /Users/wdavidw/projects/github/nikita/test/java/keystore/certs1/cacert.pem 1>&2'; cleanup; exit 3)
# Import CACert
PEM_FILE=/Users/wdavidw/projects/github/nikita/test/java/keystore/certs1/cacert.pem
CERTS=$(grep 'END CERTIFICATE' $PEM_FILE| wc -l)
code=5
for N in $(seq 0 $(($CERTS - 1))); do
  if [ $CERTS -eq '1' ]; then
    ALIAS="my_alias"
  else
    ALIAS="my_alias-$N"
  fi
  # Isolate cert into a file
  CACERT_FILE=/tmp/nikita/java_keystore_1537191205935/$ALIAS
  cat $PEM_FILE | awk "n==$N { print }; /END CERTIFICATE/ { n++ }" > $CACERT_FILE
  # Read user CACert signature
  user=`openssl x509  -noout -in "$CACERT_FILE" -sha1 -fingerprint | sed 's/\(.*\)=\(.*\)/\2/'`
  # Read registered CACert signature
  keystore=`keytool -list -v -keystore /tmp/nikita-test/keystore -storepass changeit -alias $ALIAS | grep SHA1: | sed -E 's/.+SHA1: +(.*)/\1/'`
  echo "User CA Cert: $user"
  echo "Keystore CA Cert: $keystore"
  if [ "$user" = "$keystore" ]; then echo 'Identical Signature'; code=5; continue; fi
  # Remove CACert if signature doesnt match
  if [ "$keystore" != "" ]; then
    keytool -delete -keystore /tmp/nikita-test/keystore -storepass changeit -alias $ALIAS
  fi
  keytool -noprompt -import -trustcacerts -keystore /tmp/nikita-test/keystore -storepass changeit -alias $ALIAS -file /tmp/nikita/java_keystore_1537191205935/$ALIAS
  code=0
done
cleanup
exit $code