import nikita from "@nikitajs/core";
//import "@nikitajs/k8s/cluster";
import "@nikitajs/k8s/cluster/init";

const cluster = await nikita.k8s.cluster.init();
console.info(cluster);