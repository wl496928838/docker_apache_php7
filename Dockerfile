FROM php:7.3-apache
RUN apt-get update \
    && apt-get -y install vim
	
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

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y \
    cron \
    icu-devtools \
    libfreetype6-dev libicu-dev libjpeg62-turbo-dev libpng-dev libsasl2-dev libssl-dev libwebp-dev libxpm-dev libzip-dev \
    nodejs \
    unzip \
    zlib1g-dev
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && yes '' | pecl install redis \
	 && pecl install pcnti \
    && docker-php-ext-configure gd --with-freetype-dir --with-gd --with-jpeg-dir --with-png-dir --with-webp-dir --with-xpm-dir --with-zlib-dir \
    && docker-php-ext-install gd intl pdo_mysql zip \
    && docker-php-ext-enable opcache redis

RUN  pecl install mongodb \
    && echo "extension=mongodb.so" > $PHP_INI_DIR/conf.d/mongodb.ini

RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
