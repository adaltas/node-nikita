// Miscellaneous kerberos functions

const kinit = function (config) {
  let command = "kinit";
  if (config.keytab === true) {
    (" -k");
  } else if (config.keytab && typeof config.keytab === "string") {
    command += ` -kt ${config.keytab}`;
  } else if (config.password) {
    command = `echo ${config.password} | ${command}`;
  } else {
    throw Error("Incoherent config: expects one of keytab or password");
  }
  command += ` ${config.principal}`;
  return (command = su(config, command));
};

const su = function (config, command) {
  if (config.uid) {
    command = `su - ${config.uid} -c '${command}'`;
  }
  return command;
};

export { kinit, su };

export default {
  kinit: kinit,
  su: su,
};
