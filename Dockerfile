FROM amazonlinux:2
MAINTAINER "Oscar Nevarez" <fu.wire@gmail.com>

# |--------------------------------------------------------------------------
# | Default PHP extensions to be enabled
# | By default, enable all the extensions that are enabled on a base Ubuntu install
# |--------------------------------------------------------------------------
ARG PHP_EXTENSIONS="cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip"
ENV PHP_VERSION=7.4
ARG GROUP_ID=1001
ARG USER_ID=1001

RUN yum update -y \
    && yum install -y yum-utils shadow-utils amazon-linux-extras \
    && amazon-linux-extras enable php${PHP_VERSION} \
    && yum install -y which git jq zip unzip tar wget  \
    && yum install -y yum install php php-common php-pear \
    && yum install -y php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} \
    && mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

RUN useradd -u $USER_ID docker
RUN groupmod -g $GROUP_ID docker

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli-exe-linux-x86_64.zip" \
    && yum update -y \
    && yum install -y unzip \
    && unzip -qq awscli-exe-linux-x86_64.zip \
    && ./aws/install --bin-dir /usr/local/bin

RUN mkdir -p /usr/app \
    && chown -R docker:$GROUP_ID /usr/app

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod -R ugo+rx /usr/local/bin/docker-entrypoint.sh

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"  && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

USER docker

RUN composer global require laravel/installer \
    && chmod ugo+rx ~/.config/composer/vendor/bin/laravel

ENV PATH "~/.config/composer/vendor/bin:~/.composer/vendor/bin:/usr/local/bin:$PATH"

WORKDIR /usr/app

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
