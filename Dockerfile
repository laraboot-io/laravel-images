FROM amazonlinux:2
ARG INSTALL_RECOMMENDED=1
MAINTAINER "Oscar Nevarez" <fu.wire@gmail.com>

# |--------------------------------------------------------------------------
# | NodeJs Details
# |--------------------------------------------------------------------------
ARG NODE_VERSION=12.14.1
ENV NVM_DIR /usr/local/nvm
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

WORKDIR /usr/app

RUN mkdir -p /usr/app/dist \
    && chown -R docker:$GROUP_ID /usr/app

ADD scripts scripts
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod -R ugo+rx scripts
RUN chmod -R ugo+rx /usr/local/bin/docker-entrypoint.sh

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && node -v \
    npm -v

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

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

RUN if [[ -z "$INSTALL_RECOMMENDED" ]] ; then echo "INSTALL_RECOMMENDED not provided" ; else scripts/require.sh ; fi

RUN scripts/default-setup.sh
RUN scripts/breeze-setup.sh
RUN scripts/inertia-setup.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
