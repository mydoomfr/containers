#!/bin/sh
# This file is based on the upstream FreshRSS project (https://github.com/FreshRSS/FreshRSS)
# Licensed under the AGPL-3.0 License.
# Modifications have been made to adapt it for specific use cases.
#
# Upstream Author: FreshRSS contributors (https://github.com/FreshRSS/FreshRSS)
# Modifications Author: Benjamin Pinchon (mydoomfr)
#
# This file is distributed under the AGPL-3.0 License.

FRESHRSS_DATA_PATH="${DATA_PATH:-/var/www/FreshRSS/data}"

umask 0002

check_writable_dir() {
	path="$1"
	name="$2"

	if ! mkdir -p "$path"; then
		echo "❌ FreshRSS $name directory '$path' cannot be created."
		exit 13
	fi

	if [ ! -w "$path" ]; then
		echo "❌ FreshRSS $name directory '$path' is not writable."
		exit 13
	fi

	if ! touch "$path/index.html"; then
		echo "❌ FreshRSS $name directory '$path' cannot be written to."
		exit 13
	fi
}

check_writable_dir "$FRESHRSS_DATA_PATH" 'data'
check_writable_dir "$FRESHRSS_DATA_PATH/cache" 'data cache'
check_writable_dir "$FRESHRSS_DATA_PATH/users" 'data users'
check_writable_dir "$FRESHRSS_DATA_PATH/users/_" 'data users'
check_writable_dir "$FRESHRSS_DATA_PATH/favicons" 'data favicons'
check_writable_dir "$FRESHRSS_DATA_PATH/tokens" 'data tokens'
check_writable_dir './extensions' 'extensions'

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
