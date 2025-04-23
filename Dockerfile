FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app/
COPY ./ ./

# Install apt-getable dependencies
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        gcc \
        git \
        python3-dev \
        python3-pip \
        python3-pyproj \
        python3-scipy \
        python3-yaml \
        curl \
        ffmpeg \
        libsm6 \
        libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install pytorch
RUN pip3 install torch==1.13.1 torchvision==0.14.1 --extra-index-url https://download.pytorch.org/whl/cu113

# Install detectron2 (sub-model for dinov)
RUN pip install git+https://github.com/MaureenZOU/detectron2-xyz.git

# Install COCO panoptic API
RUN pip install git+https://github.com/cocodataset/panopticapi.git

# Install required python libraries
RUN pip3 install --upgrade pip
RUN pip install mmcv==2.2.0 -f https://download.openmmlab.com/mmcv/dist/cu117/torch1.13/index.html
RUN pip3 install -r requirements.txt 

# Replace builtin metadata for coco by our custom one so training on a datset with the same structure as coco panoptic works (modifies one of the libraries)
RUN cp -f /app/modified_builtin_meta.py /usr/local/lib/python3.8/dist-packages/detectron2/data/datasets/builtin_meta.py