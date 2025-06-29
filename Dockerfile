FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    vim \
    git \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    cmake \
    python3-dev \
    libeigen3-dev \
    libboost-all-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libusb-1.0-0  \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH /opt/miniconda3/bin:$PATH
# SHELL ["/bin/bash", "-c"]

# Create conda environment
RUN conda create -n mast3r-slam python=3.11 -y && \
    conda init bash && \
    echo "conda activate mast3r-slam" >> ~/.bashrc

# Set environment variables for the conda environment
ENV CONDA_DEFAULT_ENV mast3r-slam
ENV CONDA_PREFIX /opt/miniconda3/envs/mast3r-slam
ENV PATH=/opt/miniconda3/envs/mast3r-slam/bin:$PATH

# Install PyTorch with CUDA 12.4 support
RUN conda install pytorch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 pytorch-cuda=12.4 -c pytorch -c nvidia


# Clone MASt3R-SLAM repository
WORKDIR /workspace/MASt3R-SLAM
COPY . /workspace/MASt3R-SLAM/
RUN git submodule update --init --recursive


# Install dependencies step by step for better error handling
RUN conda run -n mast3r-slam pip install -e thirdparty/mast3r

RUN conda run -n mast3r-slam pip install -e thirdparty/in3d
# RUN pip install --no-build-isolation -e .
    
RUN conda run -n mast3r-slam pip install torchcodec==0.1

WORKDIR /
CMD ["/bin/bash"]

