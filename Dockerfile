FROM docker:20.10.12-dind-alpine3.15

RUN mkdir /setup

RUN apk add --no-cache iptables bash make curl nano openssl git jq

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.3/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# install kind
RUN curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# install helm
RUN curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# install velero
RUN curl -L -o /tmp/velero.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v1.7.1/velero-v1.7.1-linux-amd64.tar.gz && \
    tar -C /tmp -xvf /tmp/velero.tar.gz && \
    mv /tmp/velero-v1.7.1-linux-amd64/velero /usr/local/bin/velero && \
    chmod +x /usr/local/bin/velero

# install terraform
RUN curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/1.1.5/terraform_1.1.5_linux_amd64.zip && \
    unzip /tmp/terraform.zip && \
    chmod +x terraform && mv terraform /usr/local/bin/

COPY . /setup



# RUN echo $'kind: Cluster\napiVersion: kind.x-k8s.io/v1alpha4\ncontainerdConfigPatches:\n  - |-\n\
#     [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]\n\
#     endpoint = ["http://kind-registry:5000"]'\
#     >> /setup/kindConfig.yaml

# RUN echo $'apiVersion: v1\nkind: ConfigMap\nmetadata:\n\
#     name: local-registry-hosting\n\
#     namespace: kube-public\ndata:\n\
#     localRegistryHosting.v1: |\n\
#     host: "localhost:5000"\n\
#     help: "https://kind.sigs.k8s.io/docs/user/local-registry/"' \
#     >> /setup/registryConfigMap.yaml

# RUN echo $'#!/bin/bash \n\
#     set -o errexit \n\
#     # create registry container unless it already exists \n\
#     reg_name="kind-registry" \n\
#     reg_port="5000" \n\
#     running="$(docker inspect -f "{{.State.Running}}" "${reg_name}" 2>/dev/null || true)" \n\
#     if [ "${running}" != "true" ]; then \n\
#     docker run -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" registry:2 \n\
#     fi \n\
#     \n\
#     # create a cluster with the local registry enabled in containerd \n\
#     kind create cluster --config=/setup/kindConfig.yaml \n\
#     \n\
#     # connect the registry to the cluster network \n\
#     # (the network may already be connected) \n\
#     docker network connect "kind" "${reg_name}" || true \n\
#     # Document the local registry \n\
#     # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry \n\
#     kubectl apply -f /setup/registryConfigMap.yaml --validate=false\
#     ' >> /setup/registry.sh

RUN echo $'#!/bin/bash \n\
    dockerd & \n\
    sleep 2 \n\
    echo " " \n\
    kind create cluster --config=/setup/config.yml \n\
    exec bash \
    ' >> /usr/local/bin/start.sh

RUN ["chmod", "+x", "/usr/local/bin/start.sh"]

ENTRYPOINT [ "/usr/local/bin/start.sh" ]
