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

# 安装基本拓展
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd


# 安装php扩展 pdo 必备
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install mongo

# 装好vim好调试
RUN apt-get -yqq install vim

RUN apt-get clean