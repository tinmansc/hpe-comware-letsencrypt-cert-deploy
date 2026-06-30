ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
    python3 \
    py3-yaml \
    py3-pexpect \
    openssl \
    openssh-client \
    sshpass \
    curl

COPY run.sh /run.sh
RUN chmod 755 /run.sh

CMD [ "/run.sh" ]
