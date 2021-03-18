#!/bin/bash
# info: pull backups from clevercloud cellar, push them to aws s3
echo "start backup script"
mkdir -p $SYNC_DIR

# setup aws cli to pull backup from ms3e cellar datastore
echo "configure aws cli to pull backups from clevercloud cellar"
/usr/local/bin/aws configure set aws_access_key_id $CELLAR_ADDON_KEY_ID --profile=clevercloud-cellar
/usr/local/bin/aws configure set aws_secret_access_key $CELLAR_ADDON_KEY_SECRET --profile=clevercloud-cellar
echo "pull backups from clevercloud cellar"
/usr/local/bin/aws s3 sync $CELLAR_ADDON_BUCKET $SYNC_DIR --profile=clevercloud-cellar --endpoint-url https://cellar-c2.services.clever-cloud.com

# setup aws cli to push backups to s3
echo "configure aws cli to push backups to s3"
/usr/local/bin/aws configure set aws_access_key_id $AWS_S3_ACCESS_KEY_ID --profile=aws-s3
/usr/local/bin/aws configure set aws_secret_access_key $AWS_S3_SECRET_ACCESS_KEY --profile=aws-s3
echo "push backups to s3"
/usr/local/bin/aws s3 sync $SYNC_DIR $AWS_S3_BUCKET --profile=aws-s3


echo "done"
