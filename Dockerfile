FROM php:7-apache

# 设置个时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置工作目录
WORKDIR /var/www/html

#把本地代码copy进去
#COPY ./app /var/www/html/

# 不给权限创建不了文件
#RUN chmod -R 777 /var/www/html/*

#配置站点配置文件
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

#配置apache2 支持伪静态
COPY apache2.conf /etc/apache2/apache2.conf
RUN cp /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# 开放端口
EXPOSE 80

# zip
RUN apt-get update && apt-get -yqq install zip

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        imagemagick \
        openssh-client \
        sudo \
        git \
        libmemcached-dev \
        libssl-dev \
        libpng12-dev \
        libjpeg-dev \
        re2c \
        libfreetype6-dev \
        libmcrypt-dev \
        libxml2-dev && \
    rm -r /var/lib/apt/lists/*


RUN cd /tmp/ && \
    git clone https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached && \
    cd /usr/src/php/ext/memcached && \
    git checkout php7 && \
    pecl install mongodb \
    && echo "extension=mongodb.so" > $PHP_INI_DIR/conf.d/mongodb.ini

RUN docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-freetype-dir && \
	docker-php-ext-install gd && \
	docker-php-ext-install mcrypt && \
	docker-php-ext-install mbstring && \
	docker-php-ext-install bcmath && \
	docker-php-ext-install opcache && \
	docker-php-ext-install memcached && \
	docker-php-ext-install pdo pdo_mysql && \
	docker-php-ext-install mysqli && \
        a2ensite 000-default.conf && \
	a2enmod rewrite

RUN apt-get clean
