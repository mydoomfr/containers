FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG VERSION
ARG TARGETARCH
ARG VENDOR
ARG LISTEN=8080
ARG PHP_POST_MAX_SIZE=32M
ARG PHP_MAX_FILESIZE=32M
ARG TZ=UTC

ENV TZ=${TZ} \
    DATA_PATH='' \
    FRESHRSS_ENV=''

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

LABEL \
    org.opencontainers.image.authors="mydoomfr" \
    org.opencontainers.image.description="A self-hosted RSS feed aggregator" \
    org.opencontainers.image.documentation="https://freshrss.github.io/FreshRSS/" \
    org.opencontainers.image.licenses="AGPL-3.0" \
    org.opencontainers.image.source="https://github.com/FreshRSS/FreshRSS" \
    org.opencontainers.image.title="FreshRSS" \
    org.opencontainers.image.url="https://freshrss.org/" \
    org.opencontainers.image.vendor="FreshRSS" \
    org.opencontainers.image.version=${VERSION}

RUN PHP_APK_INDEX="$(apk search --no-cache php)" && \
    PHP_PACKAGE="$(printf '%s\n' "$PHP_APK_INDEX" | sed -n -E 's/^(php[0-9][0-9])-.*$/\1/p' | sort -V | tail -n1)" && \
    test -n "$PHP_PACKAGE" && \
    PHP_PACKAGES="$PHP_PACKAGE ${PHP_PACKAGE}-apache2" && \
    for extension in \
        curl \
        gmp \
        intl \
        mbstring \
        xml \
        zip \
        ctype \
        dom \
        fileinfo \
        iconv \
        json \
        opcache \
        openssl \
        phar \
        session \
        simplexml \
        xmlreader \
        xmlwriter \
        tokenizer \
        zlib \
        pdo_mysql \
        pdo_pgsql; \
    do \
        package="${PHP_PACKAGE}-${extension}"; \
        if printf '%s\n' "$PHP_APK_INDEX" | grep -q "^${package}-"; then \
            PHP_PACKAGES="$PHP_PACKAGES $package"; \
        fi; \
    done && \
    apk add --no-cache \
        tzdata \
        apache2 \
        $PHP_PACKAGES && \
    if [ ! -f /usr/bin/php ]; then ln -s "/usr/bin/${PHP_PACKAGE}" /usr/bin/php; fi

RUN mkdir -p /var/www/FreshRSS /run/apache2

WORKDIR /var/www/FreshRSS

ADD https://github.com/FreshRSS/FreshRSS/archive/refs/tags/${VERSION}.tar.gz /tmp/freshrss.tar.gz

RUN tar -xzf /tmp/freshrss.tar.gz --strip-components=1 -C /var/www/FreshRSS && \
    rm /tmp/freshrss.tar.gz && \
    cp ./Docker/*.Apache.conf /etc/apache2/conf.d/ && \
    rm -f /etc/apache2/conf.d/languages.conf /etc/apache2/conf.d/info.conf \
        /etc/apache2/conf.d/status.conf /etc/apache2/conf.d/userdir.conf && \
    sed -r -i "/^\s*LoadModule .*mod_(alias|autoindex|negotiation|status).so$/s/^/#/" \
        /etc/apache2/httpd.conf && \
    sed -r -i "/^\s*(CustomLog|ErrorLog|Listen) /s/^/#/" \
        /etc/apache2/httpd.conf && \
    sed -r -i "/^\s*#\s*LoadModule .*mod_(deflate|expires|filter|headers|mime|remoteip|setenvif).so$/s/^\s*#//" \
        /etc/apache2/httpd.conf && \
    sed -r -i "\\#disable_update#s#^.*#\t'disable_update' => true,#" ./config.default.php

COPY ./entrypoint.sh /entrypoint.sh

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && \
    echo "$TZ" >/etc/timezone && \
    chown -R nobody:nogroup /var/www/FreshRSS /run/apache2 && \
    rm -f /var/www/FreshRSS/cli/access-permissions.sh && \
    sed -i -E "s#^Listen 80#Listen ${LISTEN}#" /etc/apache2/conf.d/FreshRSS.Apache.conf && \
    find /etc/php*/ -type f -name php.ini -exec sed -i -E \
    -e "\\#^;?date.timezone#s#^.*#date.timezone = ${TZ}#" \
    -e "\\#^;?post_max_size#s#^.*#post_max_size = ${PHP_POST_MAX_SIZE}#" \
    -e "\\#^;?upload_max_filesize#s#^.*#upload_max_filesize = ${PHP_MAX_FILESIZE}#" {} \;

USER nobody:nogroup

ENTRYPOINT ["/entrypoint.sh"]

CMD exec httpd -D FOREGROUND

EXPOSE 8080
