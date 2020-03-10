FROM ubuntu:19.10

##########################
### Preparation
##########################

RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y apt-utils

###########################
### NVIDIA
###########################

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

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
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411"

ENV NCCL_VERSION 2.4.8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-libraries-$CUDA_PKG_VERSION \
    cuda-nvtx-$CUDA_PKG_VERSION \
    libcublas10=10.2.1.243-1 \
    libnccl2=$NCCL_VERSION-1+cuda$CUDA_PART_VERSION && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*

ENV CUDNN_VERSION 7.6.5.32

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda$CUDA_PART_VERSION \
    && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

#########################
### Install Pip
#########################

RUN apt-get update && apt-get install -y python3-pip

RUN pip3 install --upgrade pip

##########################
### Install PyTorch
#########################

ARG PYTHON_VERSION=3.7

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    ca-certificates \
    libjpeg-dev \
    libpng-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include ninja cython typing && \
    /opt/conda/bin/conda install -y -c pytorch magma-cuda101 && \
    /opt/conda/bin/conda clean -ya

ENV PATH /opt/conda/bin:$PATH

WORKDIR /opt/pytorch

COPY . .

RUN git submodule update --init --recursive

RUN TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
    pip install -v .

RUN git clone https://github.com/pytorch/vision.git && cd vision && pip install -v .

WORKDIR /workspace

RUN chmod -R a+w .

##########################
### Some useful packages
##########################

RUN apt-get update && apt-get install -y \
    gcc-multilib \
    tmux \
    wget \
    gdb \
    qemu \
    qemu-system

###########################
### Python libraries
##########################

RUN pip3 install \
    pandas \
    tqdm \
    scikit-learn \
    scikit-image \
    tensorflow-gpu \
    nltk \
    jupyter \
    matplotlib \
    Pillow \
    librosa
