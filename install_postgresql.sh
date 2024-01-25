#!/bin/bash

# Update package list
sudo apt update

# Install PostgreSQL 14 and its dependencies
sudo apt install -y postgresql-14 postgresql-client-14

# Start and enable PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Optional: Adjust PostgreSQL authentication method to allow password-based authentication
# Open the configuration file in a text editor
sudo nano /etc/postgresql/14/main/pg_hba.conf

# Find the lines starting with "local" and "host" and change "peer" to "md5" for password authentication

# After making changes, save and exit the editor

# Reload PostgreSQL to apply the changes
sudo systemctl reload postgresql

# Optional: Set a password for the default PostgreSQL user (postgres)
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'posgres';"

echo "PostgreSQL 14 installation completed."
