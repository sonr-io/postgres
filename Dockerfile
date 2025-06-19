FROM postgres:latest

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    postgresql-server-dev-all \
    libcurl4-openssl-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build pg_net
RUN git clone https://github.com/supabase/pg_net.git \
    && cd pg_net \
    && make \
    && make install

# Clone and build pg_cron
RUN git clone https://github.com/citusdata/pg_cron.git \
    && cd pg_cron \
    && make \
    && make install

# Clone and build pg_sodium
RUN git clone https://github.com/michelp/pgsodium.git \
    && cd pgsodium \
    && make \
    && make install

# Copy configuration files
COPY config/generate_pgsodium_key.sh /etc/postgresql/generate_pgsodium_key.sh
COPY config/postgresql.conf /etc/postgresql/postgresql.conf
COPY config/pg_hba.conf /etc/postgresql/pg_hba.conf
COPY config/setup-postgres.sh /docker-entrypoint-initdb.d/

# Ensure script is executable
RUN chmod +x /docker-entrypoint-initdb.d/setup-postgres.sh

# Clean up
RUN apt-get purge -y --auto-remove build-essential git postgresql-server-dev-all

# Set default command with custom config
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
