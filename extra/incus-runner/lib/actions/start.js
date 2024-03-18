export default async function({config}) {
  await this.incus.cluster({
    $header: 'Container start'
  }, config.cluster);
};
