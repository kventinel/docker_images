FROM ubuntu:19.10

##########################
### Preparation
##########################

RUN apt-get update && \
    apt-get full-upgrade && \
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

ENV CUDA_VERSION 10.0.130

ENV CUDA_PART_VERSION 10.0

ENV CUDA_DASH_VERSION 10-0

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
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"

ENV NCCL_VERSION 2.4.8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-libraries-$CUDA_PKG_VERSION \
    cuda-nvtx-$CUDA_PKG_VERSION \
    libnccl2=$NCCL_VERSION-1+cuda$CUDA_PART_VERSION && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*

ENV CUDNN_VERSION 7.6.4.38

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda$CUDA_PART_VERSION \
    && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

##########################
### Some useful packages
##########################

RUN apt-get update && apt-get install -y \
    gcc-multilib \
    tmux \
    wget \
    git

###########################
### Python libraries
##########################

RUN apt-get update && apt-get install -y python3-pip

RUN pip3 install --upgrade pip

RUN pip3 install \
    numpy \
    pandas \
    tqdm \
    scipy \
    scikit-learn \
    tensorflow-gpu

RUN pip3 install --no-cache-dir \
    torch \
    torchvision

RUN pip3 install \
    nltk \
    ipython \
    jupyter \
    matplotlib

############################
### OS course
############################

RUN apt-get update && apt-get install -y \
    gdb \
    qemu \
    qemu-system
