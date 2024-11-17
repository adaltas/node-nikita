export default {
  tags: {
    api: true,
    incus: true,
    incus_vm: process.platform === 'linux' && !process.env.CI,
    incus_prlimit: !process.env.CI
  },
  images: {
    alpine: 'alpine/3.17'
  },
  config: [
    {
      label: 'local'
    }
    // Commented out section:
    // {
    //   label: 'remote',
    //   ssh: {
    //     host: '127.0.0.1',
    //     username: process.env.USER,
    //     private_key_path: '~/.ssh/id_ed25519'
    //   }
    //   // Example with vagrant:
    //   // ssh: {
    //   //   host: '127.0.0.1',
    //   //   port: 2222,
    //   //   username: 'vagrant',
    //   //   private_key_path: `${os.homedir()}/.vagrant.d/insecure_private_key`
    //   // }
    // }
  ]
};
