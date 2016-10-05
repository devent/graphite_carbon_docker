#!/bin/bash
set -eo pipefail

# If command starts with an option, prepend supervisord.
if [ "${1:0:1}" = '-' ]; then
    set -- supervisord "$@"
fi

# Update permissions.
chown -R www-data /opt/graphite/storage

# Run command.
exec "$@"
