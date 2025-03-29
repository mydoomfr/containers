ARG VERSION
FROM freshrss/freshrss:${VERSION:-1}-alpine

ARG TARGETARCH
ARG VENDOR

ENV PHP_POST_MAX_SIZE=32M
ENV PHP_MAX_FILESIZE=32M
ENV LISTEN=8080

RUN apk update && \
	apk upgrade --no-cache

COPY ./entrypoint.sh /entrypoint.sh

RUN mkdir -p /run/apache2 && \
	chown -R nobody:nogroup /var/www/FreshRSS /run/apache2 && \
	rm /var/www/FreshRSS/cli/access-permissions.sh && \
	rm /etc/crontab.freshrss.default && \
	sed -i -E "s#^\\#Listen 80#Listen \${LISTEN}#" /etc/apache2/httpd.conf && \
	find /etc/php*/ -type f -name php.ini -exec sed -i -E \
		-e "\\#^;?post_max_size#s#^.*#post_max_size = \${PHP_POST_MAX_SIZE}#" \
		-e "\\#^;?upload_max_filesize#s#^.*#upload_max_filesize = \${PHP_MAX_FILESIZE}#" {} \;

USER nobody:nogroup

ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd", "-D", "FOREGROUND"]

EXPOSE 8080