export default async function({config}) {
  await this.incus.delete({
    $header: 'Container delete',
    container: `${config.container}`,
    force: config.force
  });
};
