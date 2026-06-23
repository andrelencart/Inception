FROM debian:oldstable

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx openssl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

ARG DOMAIN_NAME=andcarva.42.fr 
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=FR/ST=IDF/L=Paris/0=42/OU=Inception/CN=${DOMAIN_NAME}"

RUN rm -f /etc/nginx/sites-enabled/default
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]

