FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'Acquire::Languages { "none"; };' > /etc/apt/apt.conf.d/99no-translations && \
    apt-get update && \
    apt-get install -y curl unzip git neovim ca-certificates iproute2 libglib2.0-0 iputils-ping && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb [trusted=yes] https://ng-client.cryptopro.ru/repository/debian/amd64/ ./" > /etc/apt/sources.list.d/cryptopro.list && \
    apt-get update && \
    apt-get install -y cprongate-console cprongate-tun && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN echo "downloading CSP..." && \
    curl -k -L -o csp.tgz 'https://cloud.dit.mos.ru/s/DT6yq8LfE4InCqA/download?path=%2F&files=linux-amd64_deb.tgz' && \
    mkdir -p csp && \
    tar -xzf csp.tgz -C csp && \
    cd csp/linux-amd64_deb && \
    ./install.sh kc1 && \
    dpkg -i cprocsp-compat-debian*.deb || true && \
    cd /tmp && \
    rm -rf csp csp.tgz

RUN echo "installing Root Cert..." && \
    curl -A 'Mozilla/5.0' -L -k -o guts.zip https://roskazna.gov.ru/upload/iblock/903/Kornevoy_sertifikat_GUTS_2022.zip && \
    unzip -o guts.zip && \
    /opt/cprocsp/bin/amd64/certmgr -inst -cert -file Kornevoy-sertifikat-GUTS-2022.CER -store mRoot && \
    rm guts.zip *.CER

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
