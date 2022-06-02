FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1
ENV MAKEFLAGS "-j$(nproc)"

RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    clang \
    cmake \
    curl \
    git \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libeigen3-dev \
    libffi-dev \
    liblzma-dev \
    libbz2-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libswscale-dev \
    python-openssl \
    tk-dev \
    xz-utils \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Create batman user
RUN useradd -ms /bin/bash batman
USER batman
ENV HOME /home/batman
WORKDIR $HOME

# Install python
ENV PATH="${HOME}/.pyenv/bin:${HOME}/.pyenv/shims:${PATH}"
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    CONFIGURE_OPTS="--enable-shared" pyenv install 3.8.10 && \
    pyenv global 3.8.10 && \
    pyenv rehash

# Note: We can upgrade to the latest version of scikit-build after the next opencv-python release
RUN pip install --upgrade pip setuptools numpy scikit-build==0.13.1

VOLUME [ "/input", "/output" ]
WORKDIR /input

ENV CMAKE_ARGS="-DWITH_CUDA=ON -DCUDA_ARCH_BIN=6.1,7.5,8.6 -DWITH_OPENCL=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DOPENCV_DNN_OPENCL=OFF -DOPENCV_EXTRA_MODULES_PATH=/input/opencv_contrib/modules"

CMD python setup.py bdist_wheel && \
    cp dist/*.whl /output/
