#!/bin/bash
shopt -s globstar
find . -name *.tar.gz -type f -print0 | xargs -0 md5sum