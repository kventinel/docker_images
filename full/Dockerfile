FROM ubuntu:21.04
ARG DEBIAN_FRONTEND=noninteractive

###########################
### Install apt packages
### g++-9 need to build pytorch with cuda
### ninja-build, pkg-config need to build torchaudio
###########################

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
        gnupg2 \
        curl \
        ca-certificates \
        python3.9-dev \
        python3.9-distutils \
        tmux \
        wget \
        zip \
        unzip \
        llvm-12 \
        llvm-12-dev \
        make \
        g++-9 \
        g++-10 \
        git \
        vim \
        locales \
        cmake \
        htop \
        libsndfile1 \
        sox \
        libncurses5 \
        ninja-build \
        pkg-config && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.9 39 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 39 && \
    /bin/bash -c 'for filename in /usr/bin/llvm-*12; do update-alternatives --install ${filename:: -3} ${filename:9: -3} ${filename} 12; done' && \
    locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8

###########################
### NVIDIA
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1.1/ubuntu20.04-x86_64/base/Dockerfile
### From https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/11.1.1/ubuntu20.04-x86_64/runtime/Dockerfile
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1.1/ubuntu20.04-x86_64/devel/Dockerfile
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1.1/ubuntu20.04-x86_64/devel/cudnn8/Dockerfile
### Without cuda-command-line-tools and cuda-minimal-build
###########################

RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION 11.1.1
ENV CUDA_PKG_VERSION 11-1
ENV NCCL_VERSION 2.8.4
ENV CUDNN_VERSION 8.0.5.39

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-$CUDA_PKG_VERSION \
        cuda-libraries-$CUDA_PKG_VERSION \
        libnpp-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libcublas-$CUDA_PKG_VERSION \
        libcusparse-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda11.1 \
        libtinfo5 \
        libncursesw5 \
        cuda-cudart-dev-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION \
        cuda-libraries-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        libnpp-dev-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-1+cuda11.1 \
        libcublas-dev-$CUDA_PKG_VERSION \
        libcusparse-dev-$CUDA_PKG_VERSION \
        libcudnn8=$CUDNN_VERSION-1+cuda11.1 \
        libcudnn8-dev=$CUDNN_VERSION-1+cuda11.1 && \
    ln -s cuda-11.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.1 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

###########################
### Python libraries
###########################

RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py && \
    python get-pip.py && \
    rm get-pip.py && \
    pip install numpy && \
    pip install \
        scipy \
        pandas \
        tqdm \
        scikit-learn \
        jupyter \
        matplotlib \
        librosa \
        tensorboard \
        hydra_core \
        hydra_colorlog \
        pystoi \
        pesq \
        pylint \
        einops \
        mypy \
        cython && \
    pip cache purge

###########################
### Pytorch intallation for gpus:
### Geforce 1080 -- 6.1
### Geforce 2080 -- 7.5
### K40 -- 3.5
###########################

RUN git clone https://github.com/pytorch/pytorch.git && \
    cd pytorch && \
    git checkout tags/v1.8.1 && \
    git submodule sync && \
    git submodule update --init --recursive && \
    USE_CUDA=1 \
    USE_CUDNN=1 \
    TORCH_CUDA_ARCH_LIST="3.5;6.1;7.5" \
    CC="/usr/bin/gcc-9" \
    CXX="/usr/bin/g++-9" \
    python setup.py install && \
    cd .. && \
    rm -rf pytorch

RUN git clone https://github.com/pytorch/vision.git && \
    cd vision && \
    git checkout tags/v0.9.1 && \
    git submodule sync && \
    git submodule update --init --recursive && \
    CC="/usr/bin/gcc-9" \
    CXX="/usr/bin/g++-9" \
    python setup.py install && \
    cd .. && \
    rm -r vision

RUN git clone https://github.com/pytorch/audio.git && \
    cd audio && \
    git checkout tags/v0.8.1 && \
    git submodule sync && \
    git submodule update --init --recursive && \
    CC="/usr/bin/gcc-9" \
    CXX="/usr/bin/g++-9" \
    BUILD_SOX=1 \
    python setup.py install && \
    cd .. && \
    rm -r audio

###########################
### Make User
###########################

RUN useradd -ms /bin/bash lollypop
USER lollypop
WORKDIR /home/lollypop

###########################
### Set user profile
###########################

RUN git clone https://github.com/kventinel/configs.git && \
    cp configs/tmux.conf .tmux.conf && \
    cp configs/vimrc .vimrc && \
    cat configs/bashrc >> .bashrc && \
    rm -r configs && \
    mkdir -p .vim/pack/vendor/start && \
    git clone https://github.com/morhetz/gruvbox.git .vim/pack/vendor/start/gruvbox && \
    git clone https://github.com/ycm-core/YouCompleteMe.git .vim/pack/vendor/start/YouCompleteMe && \
    git clone https://github.com/itchyny/vim-cursorword.git .vim/pack/vendor/start/vim-cursorword && \
    git clone https://github.com/vim-syntastic/syntastic.git .vim/pack/vendor/start/syntastic && \
    git clone https://github.com/preservim/nerdcommenter.git .vim/pack/vendor/start/nerdcommenter && \
    cd .vim/pack/vendor/start/YouCompleteMe && \
    git submodule update --init --recursive && \
    ./install.py && \
    cd ~/
