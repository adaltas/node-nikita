import nikita from "@nikitajs/core";
import cluster from "@nikitajs/k8s/cluster/init"
import * as fs from 'fs';
import {execSync} from "child_process";

const initCluster = await cluster;
console.log(initCluster.remote.tls);



function runCommand(command) {
    try {
        const output = execSync(command, { stdio: 'inherit' });
        console.log(output.toString());
    } catch (error) {
        console.error(`Error executing command: ${command}`);
        console.error(error.toString());
        process.exit(1);  // Exit on error
    }
}

function installKubernetesMaster() {
    console.log("Updating package information...");
    runCommand('sudo apt-get update');

    // console.log("Installing dependencies...");
    // runCommand('sudo apt-get install -y apt-transport-https ca-certificates curl');

    // console.log("Adding Docker’s official GPG key...");
    // runCommand('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -');

    // console.log("Adding Docker APT repository...");
    // runCommand('sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"');

    // console.log("Installing Docker...");
    // runCommand('sudo apt-get update');
    // runCommand('sudo apt-get install -y docker-ce docker-ce-cli containerd.io');

    // console.log("Adding Kubernetes GPG key...");
    // runCommand('curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -');

    // console.log("Adding Kubernetes APT repository...");
    // runCommand('sudo bash -c "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list\ndeb http://apt.kubernetes.io/ kubernetes-xenial main\nEOF"');

    // console.log("Installing kubeadm, kubelet, and kubectl...");
    // runCommand('sudo apt-get update');
    // runCommand('sudo apt-get install -y kubelet kubeadm kubectl');
    // runCommand('sudo apt-mark hold kubelet kubeadm kubectl');

    // console.log("Disabling swap...");
    // runCommand('sudo swapoff -a');
    // runCommand('sudo sed -i /\\swap/d /etc/fstab');

    // console.log("Initializing Kubernetes cluster...");
    // runCommand('sudo kubeadm init --pod-network-cidr=10.244.0.0/16');

    // console.log("Setting up kubeconfig for the current user...");
    // runCommand('mkdir -p $HOME/.kube');
    // runCommand('sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config');
    // runCommand('sudo chown $(id -u):$(id -g) $HOME/.kube/config');

    // console.log("Applying Flannel CNI...");
    // runCommand('kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml');

    // console.log("Retrieving join command...");
    // const joinCommand = execSync('kubeadm token create --print-join-command').toString().trim();
    // console.log(`Join command: ${joinCommand}`);

    // fs.writeFileSync('/vagrant/kubeadm_join_command.sh', joinCommand);
    // console.log("Join command saved to /vagrant/kubeadm_join_command.sh");
}

function installKubernetesNode() {
    console.log("Updating package information...");
    runCommand('sudo apt-get update');

    console.log("Installing dependencies...");
    runCommand('sudo apt-get install -y apt-transport-https ca-certificates curl');

    console.log("Adding Docker’s official GPG key...");
    runCommand('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -');

    console.log("Adding Docker APT repository...");
    runCommand('sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"');

    console.log("Installing Docker...");
    runCommand('sudo apt-get update');
    runCommand('sudo apt-get install -y docker-ce docker-ce-cli containerd.io');

    console.log("Adding Kubernetes GPG key...");
    runCommand('curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -');

    console.log("Adding Kubernetes APT repository...");
    runCommand('sudo bash -c "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list\ndeb http://apt.kubernetes.io/ kubernetes-xenial main\nEOF"');

    console.log("Installing kubeadm, kubelet, and kubectl...");
    runCommand('sudo apt-get update');
    runCommand('sudo apt-get install -y kubelet kubeadm kubectl');
    runCommand('sudo apt-mark hold kubelet kubeadm kubectl');

    console.log("Disabling swap...");
    runCommand('sudo swapoff -a');
    runCommand('sudo sed -i /\\swap/d /etc/fstab');

    console.log("Fetching join command...");
    const joinCommand = fs.readFileSync('/vagrant/kubeadm_join_command.sh', 'utf8').trim();
    console.log(`Join command: ${joinCommand}`);

    console.log("Joining Kubernetes cluster...");
    runCommand(`sudo ${joinCommand}`);
}

installKubernetesMaster();
//installKubernetesNode();

