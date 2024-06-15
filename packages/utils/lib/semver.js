import semver from "semver";

const sanitize = function (versions, fill = "x") {
  const is_array = Array.isArray(versions);
  if (!is_array) {
    versions = [versions];
  }
  for (let i = 0; i < versions.length; i++) {
    let version = versions[i];
    version = version.split(".");
    version = version.slice(0, 3);
    while (version.length < 3) {
      version.push(fill);
    }
    version = version.map((v) => {
      if (!isNaN(parseInt(v, 10))) {
        // Ubuntu style, remove trailing '0'
        return `${parseInt(v, 10)}`;
      }
      if (/\d+-\d+/.test(v)) {
        // Arch style, strip /-\d$/
        v = v.split("-")[0];
      }
      return v;
    });
    versions[i] = version.join(".");
  }
  if (is_array) {
    return versions;
  } else {
    return versions[0];
  }
};

export { sanitize };

export default {
  sanitize: sanitize,
  satisfies: semver.satisfies,
};
