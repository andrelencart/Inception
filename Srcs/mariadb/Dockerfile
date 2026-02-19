FROM debian::bullseye

RUN apt-get update && apt-get install -y \
	mariadb-server \
	mariadb-client \
	rm -rf /var/lib/apt/lists/*

# COPY - <source-on-host> <destination-in-container>
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy initialization script
COPY tools/init.sh /usr/local/bin/

# ADD = COPY but can Auto-extract tar files and Download from URLs

# WORDIR - Changes the current directory / run from this directory / Creates the directory if it doesn't exist
WORKDIR /var/www/html

# EXPOSE - Exposes the port where the data packages will be received
EXPOSE 3306

# ENTRYPOINT - Defines the main command that runs when the container starts
ENTRYPOINT ["/usr/local/bin/init.sh"]