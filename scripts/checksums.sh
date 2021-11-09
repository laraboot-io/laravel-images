#!/bin/bash
shopt -s globstar
md5sum **/*.tar.gz > checksums.md5