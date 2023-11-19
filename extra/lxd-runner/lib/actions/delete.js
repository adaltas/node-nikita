export default async function({config}) {
  await this.lxc.delete({
    $header: 'Container delete',
    container: `${config.container}`,
    force: config.force
  });
};
