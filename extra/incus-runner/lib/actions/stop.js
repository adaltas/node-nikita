export default async function({config}) {
  await this.incus.stop({
    $header: 'Container stop',
    container: `${config.container}`
  });
};
