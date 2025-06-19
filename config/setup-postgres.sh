#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
until pg_isready; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

# Copy configuration files to the correct location
echo "Copying PostgreSQL configuration files..."
cp /docker-entrypoint-initdb.d/postgresql.conf "$PGDATA/postgresql.conf"
cp /docker-entrypoint-initdb.d/pg_hba.conf "$PGDATA/pg_hba.conf"

# Set permissions
chmod 600 "$PGDATA/postgresql.conf" "$PGDATA/pg_hba.conf"

# Reload configuration
echo "Reloading PostgreSQL configuration..."
pg_ctl -D "$PGDATA" reload || true

# Create extensions
echo "Creating PostgreSQL extensions..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS pg_net;
  CREATE EXTENSION IF NOT EXISTS pg_cron;
  CREATE EXTENSION IF NOT EXISTS pgsodium;
EOSQL

echo "PostgreSQL extensions have been created."
