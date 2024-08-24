# Image to clean up old db backups

Keep backup for 31 days.
Then keep backup from 1st of month for 1 year.

To build locally

    docker build .

To run

    docker run -t -i --rm --env-file .env 009543623063.dkr.ecr.eu-west-2.amazonaws.com/smart-db-backup-cleanup:latest
