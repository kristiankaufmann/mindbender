FROM ubuntu:18.04
MAINTAINER kkaufmann@prognos.ai

# Specify a mounted volume for joblib to use as temp space
# If you don't do this it will quickly fill disk
# https://www.kaggle.com/general/22023
RUN mkdir $HOME/joblib
VOLUME ["$HOME/joblib"]

RUN apt-get update -y 
RUN apt-get upgrade -y 
RUN apt-get install -y \
        curl 
RUN apt-get install -y \
        bzip2 
RUN apt-get install -y \
        s3fs 
RUN apt-get install -y \
        build-essential 
RUN apt-get install -y \
        pkg-config 
RUN apt-get install -y \
        fuse 
RUN apt-get install -y \
        mime-support 
RUN apt-get install -y \
        default-jdk 
RUN apt-get install -y \
        libcurl4-gnutls-dev 
RUN apt-get install -y \
        libfuse-dev 
RUN apt-get install -y \
        libssl-dev 
RUN apt-get install -y \
        libgl1-mesa-glx
RUN apt-get install -y \
        libxml2-dev 
RUN apt-get install -y \
        git 
RUN apt-get install -y \
        automake 
RUN apt-get install -y \
        nodejs 
RUN apt-get install -y \
        npm 
RUN apt-get install -y \
        python-pip 
RUN apt-get install -y \
        rsync 
RUN apt-get install -y \
        unzip  
RUN apt-get install -y \
        node-less
RUN apt-get install -y \
        bats
RUN npm cache clean -f && \
    npm install -g n && \
    npm install --global coffeescript yarn && \
    n 12.16.1 \
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
#RUN npm install -g phantomjs
RUN cd /opt/mindbender/ && USER=prognos make
ENTRYPOINT ["/opt/mindbender/entrypoint"]
