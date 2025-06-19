#!/bin/bash
# Script to generate a random key for pgsodium in development environments
# Returns a consistent key for development purposes

# Generate a 32-byte random key and output it in hex format
openssl rand -hex 32
