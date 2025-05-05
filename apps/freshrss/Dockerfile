# This file is based on the upstream FreshRSS project (https://github.com/FreshRSS/FreshRSS)
# Licensed under the AGPL-3.0 License.
# Modifications have been made to adapt it for specific use cases.
#
# Upstream Author: FreshRSS contributors (https://github.com/FreshRSS/FreshRSS)
# Modifications Author: Benjamin Pinchon (mydoomfr)
#
# This file is distributed under the AGPL-3.0 License.

ARG VERSION
FROM freshrss/freshrss:${VERSION:-1}-alpine

ARG TARGETARCH
ARG VENDOR

ENV PHP_POST_MAX_SIZE=32M \
    PHP_MAX_FILESIZE=32M \
    LISTEN=8080 \
    TZ=UTC

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

COPY ./entrypoint.sh /entrypoint.sh

RUN apk update && \
    apk upgrade --no-cache && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache apache-mod-auth-openidc && \
    mkdir -p /run/apache2 && \
    chown -R nobody:nogroup /var/www/FreshRSS /run/apache2 && \
    rm -f /var/www/FreshRSS/cli/access-permissions.sh /etc/crontab.freshrss.default && \
    sed -i -E "s#^\\#Listen 80#Listen \${LISTEN}#" /etc/apache2/httpd.conf && \
    find /etc/php*/ -type f -name php.ini -exec sed -i -E \
    -e "\\#^;?post_max_size#s#^.*#post_max_size = \${PHP_POST_MAX_SIZE}#" \
    -e "\\#^;?upload_max_filesize#s#^.*#upload_max_filesize = \${PHP_MAX_FILESIZE}#" {} \; && \
    rm -f /etc/apache2/conf.d/mod-auth-openidc.conf && \
    cat <<EOF > /etc/apache2/conf.d/01-mod-auth-openidc.conf
<IfDefine OIDC_ENABLED>
LoadModule auth_openidc_module /usr/lib/apache2/mod_auth_openidc.so
</IfDefine>
EOF

USER nobody:nogroup

ENTRYPOINT ["/entrypoint.sh"]

CMD exec httpd -D FOREGROUND $([ -n "$OIDC_ENABLED" ] && [ "$OIDC_ENABLED" -ne 0 ] && echo '-D OIDC_ENABLED')

EXPOSE 8080