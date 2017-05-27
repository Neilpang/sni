FROM ubuntu:16.04
RUN apt-get update && apt-get upgrade -y  && apt-get install -y \
  libev4 \
  libudns0 \
  && apt-get -y autoremove && apt-get clean all && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV sni_ver=0.5.0
ADD sniproxy_${sni_ver}_amd64.deb /sniproxy_${sni_ver}_amd64.deb
ADD entry.sh /entry.sh

RUN chmod +x /entry.sh && dpkg -i /sniproxy_${sni_ver}_amd64.deb && mkdir -p /sniproxy/

VOLUME /sniproxy/

ENTRYPOINT /entry.sh

RUN for cmd in addhttp addssl add; do echo '#!'"/usr/bin/env sh\n/entry.sh $cmd \"\$@\"" >/bin/$cmd && chmod +x /bin/$cmd;done;


