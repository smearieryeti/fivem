ARG FIVEM_NUM=2108
ARG FIVEM_VER=2108-d1f635d9936340f8b2376d56b1a260764d4da692

FROM smearieryeti/alpine:3.10 as builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output

RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/yeti-server \
 && wget -O- https://github.com/citizenfx/cfx-server-data/.tar.gz \
        | tar xz --strip-components=1 -C opt/yeti-server-data \
    \
 && apk -p $PWD add tini

ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint

RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM


LABEL maintainer="SmearierYeti <fivem@huntpunch.com>" \
      org.label-schema.vendor="Smearieryeti     " \
      org.label-schema.name="Yeti FiveM" \
      org.label-schema.url="https://fivem.net" \
      org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers." \
      org.label-schema.version=${FIVEM_NUM} \
      com.huntpunch.version.fivem=${FIVEM_VER} \
  

COPY --from=builder /output/ /

WORKDIR /config
EXPOSE 30120

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
