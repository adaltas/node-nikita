export default async function({config}) {
  await this.call('@nikitajs/incus-runner/start', config);
  await this.call('@nikitajs/incus-runner/test', config);
  await this.call('@nikitajs/incus-runner/stop', config);
};
