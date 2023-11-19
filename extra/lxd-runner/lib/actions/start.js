export default async function({config}) {
  await this.lxc.cluster({
    $header: 'Container start'
  }, config.cluster);
};
