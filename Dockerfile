FROM ubuntu:12.04

MAINTAINER Joe Shaw <joe@joeshaw.org>

RUN apt-get update \
        && apt-get install -y python-pip python-virtualenv python-dev python-software-properties supervisor \
        && add-apt-repository ppa:nginx/stable \
        && apt-get update \
        && apt-get install -y nginx \
        && rm -rf /var/lib/apt/lists/*

# Install uWSGI
RUN pip install uwsgi

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80 443

# Make NGINX run on the foreground
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# Copy the modified Nginx conf
COPY nginx.conf /etc/nginx/conf.d/

# Custom Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./app /app
WORKDIR /app

CMD ["/usr/bin/supervisord"]
