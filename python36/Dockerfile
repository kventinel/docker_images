FROM ubuntu:20.10
ARG DEBIAN_FRONTEND=noninteractive

##########################
### Install apt packages
##########################

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
        gnupg2 \
        curl \
        ca-certificates \
        tmux \
        wget \
        zip \
        unzip \
        llvm-10 \
        llvm-10-dev \
        make \
        g++ \
        zlib1g-dev \
        libssl-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    /bin/bash -c 'for filename in /usr/bin/llvm-*; do update-alternatives --install ${filename:: -3} ${filename:9: -3} ${filename} 10; done'

RUN mkdir python36 && \
    cd python36 && \
    curl https://www.python.org/ftp/python/3.6.13/Python-3.6.13.tgz --output python36.tar.gz && \
    tar -xvf python36.tar.gz && \
    cd Python-3.6.13 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd ../../ && \
    rm -r python36 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 36 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 36 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3.6 36 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.6 36

###########################
### NVIDIA
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0.3/ubuntu18.04-x86_64/base/Dockerfile
###########################

RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION 11.0.3

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-cudart-11-0=11.0.221-1 \
    cuda-compat-11-0 && \
    ln -s cuda-11.0 /usr/local/cuda && \
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
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.0 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

###########################
### Python libraries
##########################

RUN pip install --upgrade pip && \
    pip install numpy && \
    pip install \
        scipy \
        pandas \
        tqdm \
        scikit-learn \
        jupyter \
        matplotlib \
        librosa \
        tensorboard && \
    pip install -f https://download.pytorch.org/whl/torch_stable.html \
        torch==1.7.1+cu110 \
        torchvision==0.8.2+cu110 \
        torchaudio===0.7.2 && \
    pip cache purge