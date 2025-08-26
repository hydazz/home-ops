#!/bin/bash
set -euo pipefail

# WordPress Bootstrap Script

WP_ROOT="/var/www/html"
WP_SOURCE="/usr/src/wordpress"

echo "Starting WordPress bootstrap..."

rsync -rlL --no-perms --no-owner --no-group --no-times "${WP_SOURCE}/" "${WP_ROOT}/"
echo "WordPress files copied successfully."

# some cool stuff with wp-cli could be done here

echo "WordPress bootstrap completed."
