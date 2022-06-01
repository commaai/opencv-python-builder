#!/usr/bin/env bash
set -e

if [ ! -d opencv-python ]; then
    # TODO: Clone at -b 65 once the next release is pushed, current release causes skbuild issues
    git clone https://github.com/opencv/opencv-python.git --depth 1 --single-branch
    (cd opencv-python && git submodule update --init --depth 1)
fi

docker build -t opencv-python-package .
docker run --rm -v $(pwd)/opencv-python:/input -v $(pwd):/output opencv-python-package
