FROM phusion/baseimage:0.10.0
MAINTAINER kkaufmann@prognos.ai

# Specify a mounted volume for joblib to use as temp space
# If you don't do this it will quickly fill disk
# https://www.kaggle.com/general/22023
RUN mkdir $HOME/joblib
VOLUME ["$HOME/joblib"]

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install curl bzip2 s3fs -yqq --no-install-recommends \
        build-essential \
        pkg-config \
        fuse \
        mime-support \
        default-jdk \
        libcurl4-gnutls-dev \
        libfuse-dev \
        libssl-dev \
        libgl1-mesa-glx \
        libxml2-dev \
        git \
        automake \
        nodejs \
        npm \
        python-pip \
        rsync \
        unzip \ 
        && \
    npm cache clean -f && \
    npm install -g n && \
    npm install --global coffeescript yarn && \
    n 6.11.0 \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh > /tmp/Miniconda3-latest-Linux-x86_64.sh \
    && chmod 744 /tmp/Miniconda3-latest-Linux-x86_64.sh \
    && /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /usr/local/miniconda3

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse && \
    cd /tmp/s3fs-fuse && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    rm -rf /tmp/s3*

ENV PATH=/usr/local/miniconda3/bin/:${PATH}
RUN conda config --add channels conda-forge && \
    conda install --quiet --yes \
        boto3 \
        boto \
        s3fs \
        pyhocon
    
RUN mkdir -p /opt/mindbender
COPY ./ /opt/mindbender
RUN chmod +x /opt/mindbender/entrypoint
#RUN rm /opt/mindbender/.depends/.all/bin/bash
RUN npm install -g phantomjs
RUN cd /opt/mindbender/ && USER=prognos NODE_PATH=/usr/local/n/versions/node/6.11.0/lib/node_modules/ make
ENTRYPOINT ["/opt/mindbender/entrypoint"]
