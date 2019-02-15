
Install

```
# Initialize the VM
cd assets && vagrant up && cd..
# Set up LXD client
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
# Initialize the container
npx coffee start.coffee
```

Update the VM

```
lxc remote remove nikita
lxc remote switch local
lxc remote remove nikita
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
```
