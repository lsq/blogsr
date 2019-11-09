#!/usr/bin/env bash

eval $(sed -n '/theme/s/ //gp' config.toml)
echo $theme
which hugo && /usr/bin/hugo -t $theme  --baseUrl="https://github.com/lsq/lsq.github.io"

