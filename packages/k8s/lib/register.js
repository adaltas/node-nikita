
// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  k8s: {
    "": {
      handler: function () {},
    },
    helm: {
      '': '@nikitajs/k8s/helm',
      env: '@nikitajs/k8s/helm/env',
      get: '@nikitajs/k8s/helm/get',
      history: '@nikitajs/k8s/helm/history',
      install: '@nikitajs/k8s/helm/install',
      list: '@nikitajs/k8s/helm/list',
      plugin: '@nikitajs/k8s/helm/plugin',
      repo: '@nikitajs/k8s/helm/repo',
      rollback: '@nikitajs/k8s/helm/rollback',
      search: '@nikitajs/k8s/helm/search',
      status: '@nikitajs/k8s/helm/status',
      uninstall: '@nikitajs/k8s/helm/uninstall',
      upgrade: '@nikitajs/k8s/helm/upgrade'
    },
    kubectl: {
      '': '@nikitajs/k8s/kubectl',
      annotate: '@nikitajs/k8s/kubectl/annotate',
      apiRessources: '@nikitajs/k8s/kubectl/api-ressources',
      apiVersions: '@nikitajs/k8s/kubectl/api-versions',
      apply: '@nikitajs/k8s/kubectl/apply',
      attach: '@nikitajs/k8s/kubectl/attach',
      auth: '@nikitajs/k8s/kubectl/auth',
      autoscale: '@nikitajs/k8s/kubectl/autoscale',
      certificate: '@nikitajs/k8s/kubectl/certificate',
      clusterInfo: '@nikitajs/k8s/kubectl/cluster-info',
      config: '@nikitajs/k8s/kubectl/config',
      cordon: '@nikitajs/k8s/kubectl/cordon',
      cp: '@nikitajs/k8s/kubectl/cp',
      create: '@nikitajs/k8s/kubectl/create',
      debug: '@nikitajs/k8s/kubectl/debug',
      delete: '@nikitajs/k8s/kubectl/delete',
      diff: '@nikitajs/k8s/kubectl/diff',
      drain: '@nikitajs/k8s/kubectl/drain',
      edit: '@nikitajs/k8s/kubectl/edit',
      events: '@nikitajs/k8s/kubectl/events',
      exec: '@nikitajs/k8s/kubectl/exec',
      explain: '@nikitajs/k8s/kubectl/explain',
      expose: '@nikitajs/k8s/kubectl/expose',
      get: '@nikitajs/k8s/kubectl/get',
      kustomize: '@nikitajs/k8s/kubectl/kustomize',
      label: '@nikitajs/k8s/kubectl/label',
      logs: '@nikitajs/k8s/kubectl/logs',
      options: '@nikitajs/k8s/kubectl/options',
      patch: '@nikitajs/k8s/kubectl/patch',
      plugin: '@nikitajs/k8s/kubectl/plugin',
      portForward: '@nikitajs/k8s/kubectl/port-forward',
      proxy: '@nikitajs/k8s/kubectl/proxy',
      replace: '@nikitajs/k8s/kubectl/replace',
      rollout: '@nikitajs/k8s/kubectl/rollout',
      run: '@nikitajs/k8s/kubectl/run',
      scale: '@nikitajs/k8s/kubectl/scale',
      set: '@nikitajs/k8s/kubectl/set',
      taint: '@nikitajs/k8s/kubectl/taint',
      top: '@nikitajs/k8s/kubectl/top',
      uncordon: '@nikitajs/k8s/kubectl/uncordon',
      version: '@nikitajs/k8s/kubectl/version'
    },
    kubeadm: {
      '': '@nikitajs/k8s/kubeadm',
      alpha: '@nikitajs/k8s/kubeadm/alpha',
      certs: '@nikitajs/k8s/kubeadm/certs',
      config: '@nikitajs/k8s/kubeadm/config',
      init: '@nikitajs/k8s/kubeadm/init',
      join: '@nikitajs/k8s/kubeadm/join',
      kubeconfig: '@nikitajs/k8s/kubeadm/kubeconfig',
      reset: '@nikitajs/k8s/kubeadm/reset',
      token: '@nikitajs/k8s/kubeadm/token',
      upgrade: '@nikitajs/k8s/kubeadm/upgrade',
      version: '@nikitajs/k8s/kubeadm/version'
    },
    cluster: {
      '': '@nikitajs/k8s/cluster',
      init: '@nikitajs/k8s/cluster/init',
      node: '@nikitajs/k8s/cluster/node',
      startService: '@nikitajs/k8s/cluster/start-service',
      stopService: '@nikitajs/k8s/cluster/stop-service',
      reset: '@nikitajs/k8s/cluster/reset',
      logs: '@nikitajs/k8s/cluster/logs',
      status: '@nikitajs/k8s/cluster/status'
    }
  }
};

await registry.register(actions)
