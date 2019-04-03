#!/bin/bash

# timestamp to keep track of files.
date_stamp=$(date +%Y_%m_%d_%H%M)

# path of where to save backups locally. Make sure this directory exists.
path=/usr/local/working/backups/

# path of the upload_to_s3.sh script
aws_upload_script=/usr/local/working/upload_to_s3.sh

# the output filename of the databasse backup.
filename=ghost_prod_db_$date_stamp.sql.gz

# the output filename of the compressed ghost content folder.
content_filename=ghost_blog_content_$date_stamp.tar.gz

# ghost details to access ghosts mysql database.
ghost_mysql_usr=ghost
ghost_mysql_pwd=ghost-db-password-here
ghost_mysql_db_name=ghost_production

# aws credentials
aws_secret=aws-secret-here
aws_key=aws-key-here
aws_bucket_name=aws-bucket-name
aws_region=eu-west-1

##############################################################################

echo "backing ghost db. Filename: $path$filename"

mysqldump --user=$ghost_mysql_usr --password=$ghost_mysql_pwd --databases $ghost_mysql_db_name --single-transaction | gzip > $path$filename

echo "ghost db backed up complete."

##############################################################################

echo "compressing ghost blog content."

tar -czf $path$content_filename /var/www/ghost/content

echo "compression complete."

##############################################################################

echo "uploading db to s3."

$aws_upload_script $aws_key $aws_secret $aws_bucket_name@$aws_region $path$filename dbs/$filename private

echo "upload db to s3 complete."

##############################################################################
echo "uploading content to s3."

$aws_upload_script $aws_key $aws_secret $aws_bucket_name@$aws_region $path$content_filename dbs/$content_filename private

echo "upload content to s3 complete."
