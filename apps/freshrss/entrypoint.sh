#!/bin/sh
# This file is based on the upstream FreshRSS project (https://github.com/FreshRSS/FreshRSS)
# Licensed under the AGPL-3.0 License.
# Modifications have been made to adapt it for specific use cases.
#
# Upstream Author: FreshRSS contributors (https://github.com/FreshRSS/FreshRSS)
# Modifications Author: Benjamin Pinchon (mydoomfr)
#
# This file is distributed under the AGPL-3.0 License.

php -f ./cli/prepare.php >/dev/null

if [ -n "$FRESHRSS_INSTALL" ]; then
	# shellcheck disable=SC2046
	php -f ./cli/do-install.php -- \
		$(echo "$FRESHRSS_INSTALL" | sed -r 's/[\r\n]+/\n/g' | paste -s -)
	EXITCODE=$?

	if [ $EXITCODE -eq 3 ]; then
		echo 'ℹ️ FreshRSS already installed; no change performed.'
	elif [ $EXITCODE -eq 0 ]; then
		echo '✅ FreshRSS successfully installed.'
	else
		echo '❌ FreshRSS error during installation!'
		exit $EXITCODE
	fi
fi

if [ -n "$FRESHRSS_USER" ]; then
	# shellcheck disable=SC2046
	php -f ./cli/create-user.php -- \
		$(echo "$FRESHRSS_USER" | sed -r 's/[\r\n]+/\n/g' | paste -s -)
	EXITCODE=$?

	if [ $EXITCODE -eq 3 ]; then
		echo 'ℹ️ FreshRSS user already exists; no change performed.'
	elif [ $EXITCODE -eq 0 ]; then
		echo '✅ FreshRSS user successfully created.'
		./cli/list-users.php | xargs -n1 ./cli/actualize-user.php --user
	else
		echo '❌ FreshRSS error during the creation of a user!'
		exit $EXITCODE
	fi
fi

exec "$@"
