#
# TinyMediaManager Dockerfile
#
FROM jlesage/baseimage-gui:alpine-3.17-v4

# Define software versions.
ARG TMM_VERSION=4.3.13

# Define software download URLs.
ARG TMM_URL=https://release.tinymediamanager.org/v4/dist/tmm_${TMM_VERSION}_linux-arm.tar.gz
ARG JAVAJRE_URL=https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jre17.0.5-linux_musl_aarch64.tar.gz
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/config/jre/bin:/opt/base/bin/

# Define working directory.
WORKDIR /tmp

# Download TinyMediaManager&&JRE
RUN \
    mkdir -p /defaults && \
    wget ${TMM_URL} -O /defaults/tmm.tar.gz && \
    wget ${JAVAJRE_URL} -O /defaults/jre.tar.gz

ADD launcher-extra.yml /defaults/

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# Install dependencies.
RUN \
    apk add --update \
        libmediainfo \
        ttf-dejavu \
        bash \
	    zenity \
        tar \
      	zstd \
        ffmpeg

# Install Chinese Fonts https://github.com/dzhuang/tinymediamanager-docker
#RUN wget https://mirrors.aliyun.com/alpine/edge/testing/x86_64/font-wqy-zenhei-0.9.45-r2.apk -O wqy.apk \
#    && apk add --allow-untrusted wqy.apk \
#    && rm -rf /tmp/wqy.apk
    
# Fix Java Segmentation Fault
# RUN wget "https://www.archlinux.org/packages/core/x86_64/zlib/download" -O /tmp/libz.tar.xz \
#     && mkdir -p /tmp/libz \
#     && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
#     && cp /tmp/libz/usr/lib/libz.so.1.2.12 /usr/glibc-compat/lib \
#     && /usr/glibc-compat/sbin/ldconfig \
#     && rm -rf /tmp/libz /tmp/libz.tar.xz

# Maximize only the main/initial window.
# It seems this is not needed for TMM 3.X version.
#RUN \
#    sed-patch 's/<application type="normal">/<application type="normal" title="tinyMediaManager \/ 3.0.2">/' \
#        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://gitlab.com/tinyMediaManager/tinyMediaManager/raw/45f9c702615a55725a508523b0524166b188ff75/AppBundler/tmm.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY VERSION /

# Set environment variables.
ENV APP_NAME="TinyMediaManager" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

# Metadata.
LABEL \
      org.label-schema.name="tinymediamanager-arm" \
      org.label-schema.description="arm64 version of the TinyMediaManager container" \
      org.label-schema.version=${TMM_VERSION} \
      org.label-schema.vcs-url="https://github.com/coolyzp/tinymediamanager-arm" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -d \
--restart=unless-stopped \
--name=tinymediamanager-arm \
-v /mnt/sdb2/tinymediamanager/config:/config \
-v /mnt:/mnt:rslave \
-e GROUP_ID=1000 -e USER_ID=1000 -e TZ=Europe/Kiev \
-p 5801:5800 \
-p 5901:5900 \
coolyzp/tinymediamanager-arm"
