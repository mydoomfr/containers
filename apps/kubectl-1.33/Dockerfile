FROM debian:bookworm-20250929-slim

ARG TARGETARCH
ARG KUBECTL_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gettext \
        jq \
        procps \
        bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=${TARGETARCH:-amd64} && \
    if [ "$ARCH" = "amd64" ]; then ARCH="amd64"; fi && \
    if [ "$ARCH" = "arm64" ]; then ARCH="arm64"; fi && \
    curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 && \
    echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c - && \
    chmod 0555 /usr/local/bin/kubectl && \
    rm /tmp/kubectl.sha256

RUN ARCH=${TARGETARCH:-amd64} && \
    curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" -o /usr/local/bin/yq && \
    curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/checksums" -o /tmp/yq.checksums && \
    grep "^yq_linux_${ARCH} " /tmp/yq.checksums | awk '{print $19 "  /usr/local/bin/yq"}' | sha256sum -c - && \
    chmod 0555 /usr/local/bin/yq && \
    rm /tmp/yq.checksums

RUN apt-get remove -y curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/log/* /tmp/* /var/tmp/*

RUN find / -xdev -perm /6000 -type f -exec chmod a-s {} \; 2>/dev/null || true

RUN useradd -r -u 1001 -g root kubectl && \
    mkdir -p /.kube /tmp && \
    chmod 1777 /tmp && \
    chmod g+rwX /.kube && \
    touch /.kube/.placeholder && \
    rm -f /home/kubectl/.bash_history /root/.bash_history 2>/dev/null || true

ENV HISTFILE=/dev/null

USER 1001

WORKDIR /tmp

ENTRYPOINT [ "kubectl" ]
CMD [ "--help" ]
