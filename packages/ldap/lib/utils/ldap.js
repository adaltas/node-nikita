import utils from "@nikitajs/core/utils"

export default {
  acl: {
    /*
    ## Parse ACLs

    Parse one or multiple "olcAccess" entries.

    Example:

    ```
    ldap.acl
    .parse [ '{0}to attrs=userPassword,userPKCS12 by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read by self write by anonymous auth by * none' ]
    .should.eql [
      index: 0
      to: 'attrs=userPassword,userPKCS12'
      by: [ 'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
        'dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read'
        'self write'
        'anonymous auth'
        '* none'
      ]
    ]
    ```
    */
    parse: function(olcAccesses) {
      const isArray = Array.isArray(olcAccesses);
      if (!isArray) {
        olcAccesses = [olcAccesses];
      }
      olcAccesses = olcAccesses.map( olcAccess => {
        const match = /^\{(\d+)\}to\s+(.*?)(\s*by\s+|$)(.*)$/.exec(olcAccess)
        if (!match) throw Error('Invalid olcAccess entry');
        return {
          index: parseInt(match[1], 10),
          to: match[2],
          by: match[4].split(/\s+by\s+/),
        }
      });
      if (isArray) {
        return olcAccesses;
      } else {
        return olcAccesses[0];
      }
    },
    /*
    # Stringify ACLs

    Stringify one or multiple "olcAccess" entries.
    */
    stringify: function(olcAccesses) {
      const isArray = Array.isArray(olcAccesses);
      if (!isArray) {
        olcAccesses = [olcAccesses];
      }
      for (const i in olcAccesses) {
        const olcAccess = olcAccesses[i];
        let value = `{${olcAccess.index}}to ${olcAccess.to}`;
        for (const bie of olcAccess.by) {
          value += ` by ${bie}`;
        }
        olcAccesses[i] = value;
      }
      if (isArray) {
        return olcAccesses;
      } else {
        return olcAccesses[0];
      }
    }
  },
  config_connection(config){
    return utils.object.filter(config, [], ['binddn', 'mesh', 'passwd', 'uri'])
  },
  index: {
    /*
    ## Parse Index

    Parse one or multiple "olcDbIndex" entries.
    */
    parse: function(indexes) {
      const isArray = Array.isArray(indexes);
      if (!isArray) {
        indexes = [indexes];
      }
      indexes.forEach(function(index, i) {
        if (i === 0) {
          indexes = {};
        }
        const [k, v] = index.split(' ');
        indexes[k] = v;
      });
      if (isArray) {
        return indexes;
      } else {
        return indexes[0];
      }
    },
    /*
    ## Stringify Index

    Stringify one or multiple "olcDbIndex" entries.
    */
    stringify: function(indexes) {
      const isArray = Array.isArray(indexes);
      if (!isArray) {
        indexes = [indexes];
      }
      indexes = indexes.map((v, k) => `${k} ${v}`)
      if (isArray) {
        return indexes;
      } else {
        return indexes[0];
      }
    }
  }
};
