FROM nvidia/cuda:12.6.1-devel-ubuntu24.04

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
    tk-dev \
    xz-utils \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Patched version of patchelf for auditwheel
RUN git clone https://github.com/NixOS/patchelf -b 0.18.0 --depth 1
WORKDIR $HOME/patchelf
RUN ./bootstrap.sh
RUN ./configure
RUN make
RUN make install

USER ubuntu
ENV HOME /home/ubuntu
WORKDIR $HOME

# Install python
ENV PATH="${HOME}/.pyenv/bin:${HOME}/.pyenv/shims:${PATH}"
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    CONFIGURE_OPTS="--enable-shared" pyenv install 3.11.4 && \
    pyenv global 3.11.4 && \
    pyenv rehash

RUN pip install --upgrade pip auditwheel==6.1.0 setuptools numpy scikit-build

VOLUME [ "/input", "/output" ]
WORKDIR /input

ENV ENABLE_HEADLESS=1
ENV CMAKE_ARGS="-DWITH_CUDA=ON -DCUDA_ARCH_BIN=6.1,7.5,8.6,8.9 -DWITH_OPENCL=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DOPENCV_DNN_OPENCL=OFF -DOPENCV_EXTRA_MODULES_PATH=/input/opencv_contrib/modules -DBUILD_SHARED_LIBS=ON -DBUILD_opencv_world=OFF"

CMD python setup.py bdist_wheel && \
    python auditwheel-min.py repair dist/*.whl --plat manylinux_2_39_x86_64 && \
    cp wheelhouse/*.whl /output/ && \
    python verify-libs.py wheelhouse/*.whl && \
    cp wheelhouse/*.whl /output/
