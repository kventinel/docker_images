FROM ubuntu:21.04
ARG DEBIAN_FRONTEND=noninteractive

###########################
### Install apt packages
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
        g++ \
        git \
        vim \
        locales \
        cmake \
        htop \
        libsndfile1 \
        sox && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.9 39 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 39 && \
    /bin/bash -c 'for filename in /usr/bin/llvm-*; do update-alternatives --install ${filename:: -3} ${filename:9: -3} ${filename} 10; done' && \
    locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8

###########################
### NVIDIA
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1.1/ubuntu20.04-x86_64/base/Dockerfile
###########################

RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION 11.1.1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-cudart-11-1=11.1.74-1 \
    cuda-compat-11-1 && \
    ln -s cuda-11.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

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
        einops && \
    pip install -f https://download.pytorch.org/whl/torch_stable.html \
        torch==1.8.1+cu111 \
        torchvision==0.9.1+cu111 \
        torchaudio==0.8.1 && \
    pip cache purge

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
