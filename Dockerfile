FROM ubuntu:16.04 AS buildsni

RUN apt-get update \
  && apt-get install -qqy \
  git \
  build-essential \
  autotools-dev \
  cdbs \
  debhelper \
  dh-autoreconf \
  dpkg-dev \
  gettext \
  libev-dev \
  libpcre3-dev \
  libudns-dev \
  pkg-config \
  fakeroot \
  devscripts \
  && apt-get clean

ENV sni_ver=0.5.0

RUN mkdir -p /root && cd /root \
  && git clone https://github.com/Neilpang/sniproxy.git \
  && cd sniproxy \
  && ./autogen.sh && dpkg-buildpackage \
  && cd .. \
  && rm -rf sniproxy



FROM ubuntu:16.04
RUN apt-get update && apt-get install -y \
  libev4 \
  libudns0 \
  && apt-get -y autoremove && apt-get clean all && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV sni_ver=0.5.0

COPY --from=buildsni /root/sniproxy_${sni_ver}_amd64.deb /sniproxy_${sni_ver}_amd64.deb

ADD entry.sh /entry.sh

RUN chmod +x /entry.sh && dpkg -i /sniproxy_${sni_ver}_amd64.deb && mkdir -p /sniproxy/

VOLUME /sniproxy/

ENTRYPOINT ["/entry.sh"]

RUN for cmd in addhttp addssl add; do echo '#!'"/usr/bin/env sh\n/entry.sh $cmd \"\$@\"" >/bin/$cmd && chmod +x /bin/$cmd;done;


