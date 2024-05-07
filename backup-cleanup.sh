#!/bin/bash

# Keep backup for 31 days
# Then keep backup from 1st of month for 1 year

if [[ -z "$S3BACKUPBUCKET" ]] ; then
    echo "ERROR: S3BACKUPBUCKET not set"
    exit 1
fi

# check aws access
aws s3api head-bucket --bucket ${S3BACKUPBUCKET} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error connecting to AWS - ensure the container has correct IAM role"
    exit 1
fi

function deleteObject {
  key="$1"
  echo "deleting ${S3BACKUPBUCKET}/${key}"
  aws s3api delete-object --bucket "${S3BACKUPBUCKET}" --key "${key}"
  if [ $? -ne 0 ]; then
      echo "ERROR while deleting file ${S3BACKUPBUCKET}/${key}"
      exit 1
  fi
}

function deleteOlderThanOneYear {
  PGDATABASE="$1"
  CUTOFF="$(date --date "-1 year -1 day" +%F)"
  echo "Deleting backups created before ${CUTOFF}"
  for key in $(aws s3api list-objects-v2 --bucket ${S3BACKUPBUCKET} --prefix "dbbackups/${PGDATABASE}" --query 'Contents[?LastModified < `"'${CUTOFF}'"`].Key' --output text | grep -v "^None"); do
    deleteObject ${key}
  done
}

function deleteExceptFirstOfMonth {
  PGDATABASE="$1"
  CUTOFF="$(date --date "-31 day" +%F)"
  echo "Deleting backups older that 31 days and not on first of month"
  for key in $(aws s3api list-objects-v2 --bucket ${S3BACKUPBUCKET} --prefix "dbbackups/${PGDATABASE}" --query 'Contents[?LastModified < `"'${CUTOFF}'"`].[Key]' --output text | grep -v "^None" | egrep -v "dbbackups/${PGDATABASE}/[0-9]{4}-[0-9]{2}-01"); do
    deleteObject ${key}
  done
}

# first delete anything older than 1 year
deleteOlderThanOneYear "smart_api"
deleteOlderThanOneYear "smart_attachments"
deleteOlderThanOneYear "smart_comments"
deleteExceptFirstOfMonth "smart_api"
deleteExceptFirstOfMonth "smart_attachments"
deleteExceptFirstOfMonth "smart_comments"
echo "Finished clean up of backups"
