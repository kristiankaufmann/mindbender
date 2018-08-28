#!/bin/bash
set -e

BUCKET=$1
S3PATH=$2

mkdir -p /mnt/mindbender-tasks/
AWSACCESSKEYID=$AWS_ACCESS_KEY_ID AWSSECRETACCESSKEY=$AWS_SECRET_ACCESS_KEY s3fs ${BUCKET}:${S3PATH} /mnt/mindbender-tasks/ -o use_cache=/tmp/s3fs_cache -o use_sse=1 
cd /mnt/mindbender-tasks/
NODE_PATH=/usr/local/n/versions/node/6.11.0/lib/node_modules/ MINDBENDER_HOME=/opt/mindbender/\@prefix\@/ PATH=/opt/mindbender/gui/backend/:/opt/mindbender/shell/:$PATH /opt/mindbender/gui/backend/mindbender-tagger $(ls -t **/mindtagger.conf)

