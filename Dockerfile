
FROM postgres:latest

LABEL org.opencontainers.image.title="PostgreSQL"
LABEL org.opencontainers.image.source="https://github.com/sonr-io/postgres"
LABEL org.opencontainers.image.description="A custom PostgreSQL image with additional extensions for development purposes."

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    postgresql-server-dev-all \
    libcurl4-openssl-dev \
    libsodium-dev \
    ca-certificates \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Clone and build pg_net
RUN git clone https://github.com/supabase/pg_net.git \
    && cd pg_net \
    && make \
    && make install \
    && cd .. && rm -rf pg_net

# Clone and build pg_cron
RUN git clone https://github.com/citusdata/pg_cron.git \
    && cd pg_cron \
    && make \
    && make install \
    && cd .. && rm -rf pg_cron

# Clone and build pgsodium
RUN git clone https://github.com/michelp/pgsodium.git \
    && cd pgsodium \
    && make \
    && make install \
    && cd .. && rm -rf pgsodium

# Clone and build the http extension
RUN git clone https://github.com/pramsey/pgsql-http.git \
    && cd pgsql-http \
    && make \
    && make install \
    && cd .. && rm -rf pgsql-http

# Copy configuration files to both locations to ensure they're available
COPY config/generate_pgsodium_key.sh /etc/postgresql/generate_pgsodium_key.sh
COPY config/postgresql.conf /etc/postgresql/postgresql.conf
COPY config/pg_hba.conf /etc/postgresql/pg_hba.conf

# Also copy to docker-entrypoint-initdb.d for the setup script
COPY config/postgresql.conf /docker-entrypoint-initdb.d/postgresql.conf
COPY config/pg_hba.conf /docker-entrypoint-initdb.d/pg_hba.conf
COPY config/setup-postgres.sh /docker-entrypoint-initdb.d/setup-postgres.sh

# Ensure scripts are executable
RUN chmod +x /etc/postgresql/generate_pgsodium_key.sh \
    && chmod +x /docker-entrypoint-initdb.d/setup-postgres.sh

# Clean up
RUN apt-get purge -y --auto-remove build-essential git postgresql-server-dev-all

# Set default command with custom config
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

