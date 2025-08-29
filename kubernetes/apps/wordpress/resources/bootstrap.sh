#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
WP_ROOT="${WP_ROOT:-/var/www/html}"
WP_SOURCE="${WP_SOURCE:-/usr/src/wordpress}"

DRAGONFLY_HOST="${DRAGONFLY_HOST:-dragonfly.databases.svc.cluster.local}"
DRAGONFLY_PORT="${DRAGONFLY_PORT:-6379}"

WP_PARALLEL="${WP_PARALLEL:-8}"
WP_ARGS=(--path="$WP_ROOT" --quiet)

throttle() { while [ "$(jobs -pr | wc -l)" -ge "$WP_PARALLEL" ]; do sleep 0.1; done; } # wp cli uses a bit of ram...
set_w3() { wp w3tc option set "$1" "$2" "${WP_ARGS[@]}" &>/dev/null || true; }

sep() {
    printf '=%.0s' {1..50}
    echo
}

echo "🚀 WordPress Init"
echo "   Root: ${WP_ROOT}"
echo "   Source: ${WP_SOURCE}"
echo "   Redis: ${DRAGONFLY_HOST}:${DRAGONFLY_PORT}"
sep

# --- Sync core ---
echo "📁 Syncing WordPress core..."
rsync --recursive --no-perms --no-owner --no-group --no-times "${WP_SOURCE}/" "${WP_ROOT}/" </dev/null ||
    {
        echo "❌ ERROR: rsync failed"
        exit 1
    }
echo "✅ Core sync complete"
sep

# --- Temporarily create wp-config.php for WP-CLI ---
echo "⚙️  Creating temporary wp-config.php..."
cp -f "${WP_ROOT}/wp-config-docker.php" "${WP_ROOT}/wp-config.php"
sep

# --- Install (only if needed) ---
if ! wp core is-installed "${WP_ARGS[@]}"; then
    echo "🔧 Installing WordPress..."
    echo "   URL: ${WORDPRESS_URL:-<unset>}"
    echo "   Admin: ${WORDPRESS_ADMIN_USER:-<unset>}"

    : "${WORDPRESS_URL:?set WORDPRESS_URL}"
    : "${WORDPRESS_TITLE:?set WORDPRESS_TITLE}"
    : "${WORDPRESS_ADMIN_USER:?set WORDPRESS_ADMIN_USER}"
    : "${WORDPRESS_ADMIN_PASSWORD:?set WORDPRESS_ADMIN_PASSWORD}"
    : "${WORDPRESS_ADMIN_EMAIL:?set WORDPRESS_ADMIN_EMAIL}"

    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        "${WP_ARGS[@]}" </dev/null ||
        {
            echo "❌ ERROR: wp core install failed"
            exit 1
        }

    echo "✅ WordPress installation complete"
    sep
else
    echo "✅ WordPress already installed"
    sep
fi

# --- Apply WP_* env options ---
echo "⚙️  Applying WordPress options..."
count=0
while IFS='=' read -r -d '' kv; do
    key="${kv%%=*}"
    val="${kv#*=}"
    [[ $key == WP_* ]] || continue
    opt="$(tr '[:upper:]' '[:lower:]' <<<"${key#WP_}")"
    wp option update "$opt" "$val" "${WP_ARGS[@]}" &>/dev/null || true
    ((count++))
done < <(env -0)
echo "✅ Applied $count WordPress options"
sep

# --- Ensure W3TC present/active ---
echo "🔌 Setting up W3 Total Cache..."
wp plugin install w3-total-cache --force "${WP_ARGS[@]}" &>/dev/null || true
wp plugin activate w3-total-cache "${WP_ARGS[@]}" &>/dev/null || true
echo "✅ W3TC ready"
sep

# --- Configure W3TC ---
echo "⚡ Configuring W3TC (${DRAGONFLY_HOST}:${DRAGONFLY_PORT})..."

components=(pgcache dbcache objectcache minify)
for c in "${components[@]}"; do
    throttle
    set_w3 "${c}.enabled" true &
    throttle
    set_w3 "${c}.engine" redis &
    throttle
    set_w3 "${c}.redis.servers" "${DRAGONFLY_HOST}:${DRAGONFLY_PORT}" &
    throttle
    set_w3 "${c}.redis.dbid" 2 &
    throttle
    set_w3 "${c}.redis.password" "" &
    throttle
    set_w3 "${c}.memcached.servers" "" &
    throttle
    set_w3 "${c}.memcached.username" "" &
    throttle
    set_w3 "${c}.memcached.password" "" &
done

# page cache specifics
throttle
set_w3 pgcache.lifetime 86400 &
throttle
set_w3 pgcache.prime.enabled true &
throttle
set_w3 pgcache.prime.interval 86400 &
throttle
set_w3 pgcache.prime.limit 30 &

# extras
throttle
set_w3 lazyload.enabled true &

wait || true
echo "✅ W3TC configuration complete"
sep

echo "🎉 WordPress initialisation complete!"
sep

# --- Clean up temporary wp-config.php ---
echo "🧹 Cleaning up..."
rm -f "${WP_ROOT}/wp-config.php"
