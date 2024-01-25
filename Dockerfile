FROM ubuntu:latest

# Install dependencies
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt install -y php8.2\
    php8.2-cli\
    php8.2-common\
    php8.2-fpm\
    php8.2-mysql\
    php8.2-zip\
    php8.2-gd\
    php8.2-mbstring\
    php8.2-curl\
    php8.2-xml\
    php8.2-bcmath\
    php8.2-pdo

# Install php-fpm
RUN apt install -y php8.2-fpm php8.2-cli

# Install composer
RUN apt install -y curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nodejs
RUN apt install -y ca-certificates gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ENV NODE_MAJOR 20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt update
#RUN apt install -y nodejs

# Install nginx
RUN apt install -y nginx
#RUN echo "\
#    server {\n\
#        listen 80;\n\
#       listen [::]:80;\n\
#        root /var/www/html/public;\n\
#        add_header X-Frame-Options \"SAMEORIGIN\";\n\
#        add_header X-Content-Type-Options \"nosniff\";\n\
#        index index.php;\n\
#        charset utf-8;\n\
#        location / {\n\
#            try_files \$uri \$uri/ /index.php?\$query_string;\n\
#        }\n\
#        location = /favicon.ico { access_log off; log_not_found off; }\n\
#        location = /robots.txt  { access_log off; log_not_found off; }\n\
#        error_page 404 /index.php;\n\
#        location ~ \.php$ {\n\
#            fastcgi_pass unix:/run/php/php8.2-fpm.sock;\n\
#            fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;\n\
#            include fastcgi_params;\n\
#        }\n\
#        location ~ /\.(?!well-known).* {\n\
#            deny all;\n\
#        }\n\
#    }\n" > /etc/nginx/sites-available/default
	
#COPY ./app/conf/nginx/sites-available/default /etc/nginx/sites-available/default
COPY ./app/conf/nginx/conf.d/vhosts.conf /etc/nginx/conf.d/vhosts.conf

# PostgreSQL
COPY install_postgresql.sh /install_postgresql.sh
RUN chmod +x /install_postgresql.sh
RUN /install_postgresql.sh

# Setting for api
COPY ./health-app-frontend /var/www/html
WORKDIR /var/www/html
#RUN php artisan key:generate
RUN chown -R www-data:www-data /var/www/html

# Setting for frontend
COPY ./health-web /var/www/html/health-web
#WORKDIR /var/www/html/health-web
#RUN npm install
#RUN npm run build
	
# Run web server
RUN echo "\
    #!/bin/sh\n\
    echo \"Starting services...\"\n\
    service php8.2-fpm start\n\
    nginx -g \"daemon off;\" &\n\
    echo \"Ready.\"\n\
    tail -s 1 /var/log/nginx/*.log -f\n\
    " > /start.sh
	
EXPOSE 80 3000 5432

CMD ["sh", "/start.sh"]