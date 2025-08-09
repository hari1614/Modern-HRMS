#!/bin/bash

set -e

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd /home/frappe/frappe-bench
    bench start
else
    echo "Creating new bench..."

    cd /home/frappe
    bench init --skip-redis-config-generation frappe-bench
    cd frappe-bench

    bench set-mariadb-host mariadb
    bench set-redis-cache-host redis://redis:6379
    bench set-redis-queue-host redis://redis:6379
    bench set-redis-socketio-host redis://redis:6379

    sed -i '/redis/d' ./Procfile
    sed -i '/watch/d' ./Procfile

    bench get-app erpnext --branch version-15
    bench get-app hrms ../hrms
    bench get-app roster ../roster

    bench new-site hrms.localhost \
        --force \
        --mariadb-root-password 123 \
        --admin-password admin \
        --no-mariadb-socket

    bench --site hrms.localhost install-app erpnext
    bench --site hrms.localhost install-app hrms
    bench --site hrms.localhost install-app roster

    bench --site hrms.localhost set-config developer_mode 1
    bench --site hrms.localhost enable-scheduler
    bench --site hrms.localhost clear-cache
    bench use hrms.localhost

    bench start
fi
