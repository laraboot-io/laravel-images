# Laravel images

This project bootstrap _Laravel_ projects with its variants inside a convenient _Docker_ image.

## Build
docker build . --file Dockerfile -t script-builder

## Usage

### Grab distro from image

#### Default setup

docker cp script-builder:/usr/app/dist/default.zip .

#### Breeze setup
docker cp script-builder:/usr/app/dist/breeze.zip .


