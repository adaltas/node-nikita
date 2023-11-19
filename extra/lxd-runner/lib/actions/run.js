export default async function({config}) {
  await this.call('@nikitajs/lxd-runner/start', config);
  await this.call('@nikitajs/lxd-runner/test', config);
  await this.call('@nikitajs/lxd-runner/stop', config);
};
