import fs from "node:fs/promises";
const dirname = new URL(".", import.meta.url).pathname;

const exists = async function (path) {
  try {
    await fs.access(path, fs.constants.F_OK);
    return true;
  } catch {
    return false;
  }
};

// Write default configuration
if (
  !process.env["NIKITA_TEST_MODULE"] &&
  !(await exists(`${dirname}/../test.js`)) &&
  !(await exists(`${dirname}/../test.json`))
) {
  const config = await fs.readFile(`${dirname}/../test.sample.js`);
  await fs.writeFile(`${dirname}/../test.js`, config);
}

// Read configuration
const config = await import(process.env["NIKITA_TEST_MODULE"] || "../test.js");

// Export configuration
export default config.default;
