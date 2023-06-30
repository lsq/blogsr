#!/usr/bin/env bash

eval $(sed -n '/theme/s/ //gp' config.toml)
echo $theme
[ -d public ] && rm -rf public
which hugo && /usr/bin/hugo -t $theme  -b "https://lsq.github.io"

