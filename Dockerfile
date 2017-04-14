FROM sgtsquiggs/alpine:3.4

MAINTAINER sgtsquiggs

ENV LANG=C.UTF-8

RUN \
# install packages
    apk add --no-cache \
        --virtual=build-dependencies \
        curl &&\

# install glibc
    latest_tag=$(curl -sX GET "https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]') &&\
    base_url=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$latest_tag &&\
    curl -o /etc/apk/keys/sgerrand.rsa.pub \
        -L https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub &&\
    curl -o /tmp/glibc.apk \
        -L $base_url/glibc-$latest_tag.apk &&\
    curl -o /tmp/glibc-bin.apk \
        -L $base_url/glibc-bin-$latest_tag.apk &&\
    curl -o /tmp/glibc-i18n.apk \
        -L $base_url/glibc-i18n-$latest_tag.apk &&\
    apk add --no-cache \
        /tmp/glibc.apk \
        /tmp/glibc-bin.apk \
        /tmp/glibc-i18n.apk &&\
    /usr/glibc-compat/bin/localedef \
        --force \
        --inputfile POSIX \
        --charmap UTF-8 C.UTF-8 || true &&\
    echo "export LANG=C.UTF-8" \
        > /etc/profile.d/locale.sh &&\

# clean up
    apk del glibc-i18n &&\
    apk del build-dependencies &&\
    rm -rf \
        /tmp/* \
        /etc/apk/keys/sgerrand.rsa.pub
