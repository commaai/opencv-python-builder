FROM nvidia/cuda:11.8.0-devel-ubuntu20.04

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

# Patched version of patchelf for auditwheel
RUN git clone https://github.com/nvictus/patchelf.git --depth 1
WORKDIR $HOME/patchelf
RUN ./bootstrap.sh
RUN ./configure
RUN make
RUN make install

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
RUN pip install --upgrade pip auditwheel setuptools numpy scikit-build==0.13.1

VOLUME [ "/input", "/output" ]
WORKDIR /input

ENV ENABLE_HEADLESS=1
ENV CMAKE_ARGS="-DWITH_CUDA=ON -DCUDA_ARCH_BIN=6.1,7.5,8.6 -DWITH_OPENCL=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DOPENCV_DNN_OPENCL=OFF -DOPENCV_EXTRA_MODULES_PATH=/input/opencv_contrib/modules -DBUILD_SHARED_LIBS=ON -DBUILD_opencv_world=OFF"

CMD python setup.py bdist_wheel && \
    python auditwheel-min.py repair dist/*.whl --plat manylinux_2_31_x86_64 && \
    python verify-libs.py wheelhouse/*.whl && \
    cp wheelhouse/*.whl /output/
