#!/usr/bin/env bash
set -e

if [ ! -d opencv-python ]; then
    git clone https://github.com/opencv/opencv-python.git -b 64 --depth 1 --single-branch
    (cd opencv-python && git submodule update --init --depth 1)
fi

cp $(pwd)/auditwheel-min.py $(pwd)/opencv-python/
cp $(pwd)/verify-libs.py $(pwd)/opencv-python/
docker build -t opencv-python-package .
docker run --rm -v $(pwd)/opencv-python:/input -v $(pwd):/output opencv-python-package
