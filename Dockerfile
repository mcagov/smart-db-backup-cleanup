FROM 009543623063.dkr.ecr.eu-west-2.amazonaws.com/amazonlinux:2023

LABEL maintainer="info@catapult.cx"
LABEL org.label-schema.description="DB Backup Cleanup"

ADD backup-cleanup.sh /
RUN chmod +x /backup-cleanup.sh && \
    curl -fsSL -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/*

CMD "/backup-cleanup.sh"
