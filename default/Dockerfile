FROM ubuntu:20.10
ARG DEBIAN_FRONTEND=noninteractive

##########################
### Preparation
##########################

RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y apt-utils

###########################
### NVIDIA
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/ubuntu18.04/10.1/base/Dockerfile
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/ubuntu18.04/10.1/runtime/Dockerfile
### From https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/ubuntu18.04/10.1/runtime/cudnn7/Dockerfile
###########################

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV CUDA_VERSION 10.1.243
ENV CUDA_PART_VERSION 10.1
ENV CUDA_DASH_VERSION 10-1
ENV CUDA_PKG_VERSION $CUDA_DASH_VERSION=$CUDA_VERSION-1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-cudart-$CUDA_PKG_VERSION \
    cuda-compat-$CUDA_DASH_VERSION && \
    ln -s cuda-$CUDA_PART_VERSION /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411 brand=tesla,driver>=418,driver<419"

ENV NCCL_VERSION 2.4.8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-libraries-$CUDA_PKG_VERSION \
    cuda-nvtx-$CUDA_PKG_VERSION \
    libcublas10=10.2.1.243-1 \
    libnccl2=$NCCL_VERSION-1+cuda$CUDA_PART_VERSION && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-nvml-dev-$CUDA_PKG_VERSION \
    cuda-command-line-tools-$CUDA_PKG_VERSION \
    cuda-libraries-dev-$CUDA_PKG_VERSION \
    cuda-minimal-build-$CUDA_PKG_VERSION \
    libnccl-dev=$NCCL_VERSION-1+cuda10.1 \
    libcublas-dev=10.2.1.243-1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

ENV CUDNN_VERSION 7.6.5.32

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda$CUDA_PART_VERSION \
    libcudnn7-dev=$CUDNN_VERSION-1+cuda10.1 \
    && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

##########################
### Install PyTorch
#########################

ARG PYTHON_VERSION=3.8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++-8 \
    build-essential \
    cmake \
    git \
    curl \
    ca-certificates \
    libjpeg-dev \
    libpng-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -y python=$PYTHON_VERSION cmake numpy=1.18 pyyaml scipy ipython mkl mkl-include ninja cython typing setuptools cffi && \
    /opt/conda/bin/conda install -y -c pytorch magma-cuda101 && \
    /opt/conda/bin/conda clean -ya

ENV PATH /opt/conda/bin:$PATH
ENV CMAKE_PREFIX_PATH ${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

RUN git clone https://github.com/pytorch/pytorch.git && \
    cd pytorch && \
    git checkout tags/v1.6.0 && \
    git submodule sync && \
    git submodule update --init --recursive && \
    USE_CUDA=1 \
    USE_CUDNN=1 \
    USE_MKLDNN=1 \
    CUDA_HOME="/usr/local/cuda" \
    CUDA_TOOLKIT_ROOT_DIR="/usr/local/cuda" \
    TORCH_CUDA_ARCH_LIST="3.5;3.7;5.0+PTX;6.0;6.1;7.0;7.5" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CUDA_INCLUDE_DIRS="usr/include/cuda" \
    CUDA_CUDART_LIBRARY="/usr/local/cuda/lib64/libcudart.so" \
    CUDA_NVCC_EXECUTABLE="/usr/local/cuda/bin/nvcc" \
    CC="/usr/bin/gcc-8" \
    CXX="/usr/bin/g++-8" \
    python setup.py install && \
    cd .. && \
    rm -rf pytorch

RUN git clone https://github.com/pytorch/vision.git && \
    cd vision && \
    git checkout tags/v0.7.0 && \
    CC="/usr/bin/gcc-8" \
    CXX="/usr/bin/g++-8" \
    python setup.py install && \
    cd .. && \
    rm -rf vision

##########################
### Some useful packages
##########################

RUN apt-get update && apt-get install -y \
    gcc-multilib \
    tmux \
    wget \
    gdb \
    qemu \
    qemu-system \
    time \
    zip \
    unzip

#########################
### Install Pip
#########################

RUN conda install -y pip

###########################
### Python libraries
##########################

RUN pip install \
    pandas \
    tqdm \
    scikit-learn \
    scikit-image \
    tensorflow-gpu \
    nltk \
    jupyter \
    matplotlib \
    Pillow \
    librosa \
    click \
    pycocotools

RUN pip install subword-nmt
