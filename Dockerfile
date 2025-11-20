FROM debian:12-slim AS base-image

# -------- Base runtime --------
FROM base-image AS base-runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 python3-pip git curl unzip wget \
      dnsutils nmap iputils-ping \
      libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev \
      libnss3 libxss1 libasound2-dev libxtst6 xauth xvfb \
      ca-certificates fonts-liberation lsb-release xdg-utils \
      nano time openssh-server \
    && pip3 install --no-cache-dir --break-system-packages \
       arjun dirsearch git-dumper sqlmap awscli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# -------- Rustscan build stage --------
FROM base-image AS rustscan-builder
ENV CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup \
    PATH=$PATH:/usr/local/cargo/bin
RUN apt-get update && apt-get install -y --no-install-recommends curl build-essential ca-certificates \
    && curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal \
    && cargo install rustscan \
    && strip /usr/local/cargo/bin/rustscan \
    && rm -rf $CARGO_HOME/registry $CARGO_HOME/git $RUSTUP_HOME /var/lib/apt/lists/*

# -------- Chromium stage --------
FROM base-image AS chromium-builder
WORKDIR /opt/chromium
RUN apt-get update && apt-get install -y --no-install-recommends git curl unzip ca-certificates \
    && git clone --depth=1 https://github.com/scheib/chromium-latest-linux . \
    && ./update.sh \
    && cp $(find /opt/chromium -type f -name chrome | head -n1) /usr/local/bin/chromium
# binary path: /opt/chromium/chromium-latest-linux/latest/chrome-linux

# -------- Tools stage --------
FROM base-image AS tools
ARG AQUATONE_VERSION=1.7.0
ARG METABIGOR_VERSION=2.0.0
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip ca-certificates \
    && wget https://github.com/michenriksen/aquatone/releases/download/v${AQUATONE_VERSION}/aquatone_linux_amd64_${AQUATONE_VERSION}.zip \
    && unzip aquatone_linux_amd64_${AQUATONE_VERSION}.zip -d /usr/local/bin \
    && rm -rf *.zip \
    && wget https://github.com/j3ssie/metabigor/releases/download/v${METABIGOR_VERSION}/metabigor_v${METABIGOR_VERSION}_linux_amd64.tar.gz \
    && tar -xvf metabigor_v${METABIGOR_VERSION}_linux_amd64.tar.gz -C /usr/local/bin \
    && rm -rf metabigor* \
    && rm -rf /var/lib/apt/lists/*

# -------- Go project builder --------
FROM golang:1.25 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpcap-dev make \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Makefile ./
RUN make install

# -------- Final image --------
FROM base-runtime AS final
COPY --from=rustscan-builder /usr/local/cargo/bin/rustscan /usr/local/bin/rustscan
COPY --from=chromium-builder /usr/local/bin/chromium /usr/local/bin/chromium
COPY --from=tools /usr/local/bin/aquatone /usr/local/bin/aquatone
COPY --from=tools /usr/local/bin/metabigor /usr/local/bin/metabigor
COPY --from=builder /go/bin /usr/local/bin

# SSH setup
RUN mkdir -p /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo "root:recon" | chpasswd \
    && rm -rf /tmp/* /var/tmp/* /root/.cache

CMD ["/usr/sbin/sshd", "-D"]
