import prerequirements from "./requirements.js"
import definitions from "./schema.json" assert { type: "json" };
// Action
export default {
    handler: async function() {
        console.log("je suis dans k8s function")
        const checkPreRequirements = await prerequirements.handler({
            //vm: config.vms,
            tools: "K8S_UTILS"
        });
        if (checkPreRequirements){
            console.log("ready to install k8s");
            cluster.init();  
        }
        // kubeadm init --control-plane-endpoint="$MASTER_PUBLIC_IP" --apiserver-cert-extra-sans="$MASTER_PUBLIC_IP" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap
        //const configValue = Object.entries(config.config).map(([key, value]) => `--config ${key}=${value}`).join(` `)
        console.log("configValue")
    },
    hooks: {
        on_action: {
          before: ['@nikitajs/core/src/plugins/metadata/schema'],
          handler: function({config}) {
            //todo
          }
        }
    },
    metadata: {
        definitions: definitions
    }
};