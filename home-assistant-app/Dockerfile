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
COPY deploy_cert_hpe_comware.py /app/deploy_cert_hpe_comware.py

RUN chmod 755 /run.sh \
    && chmod 755 /app/deploy_cert_hpe_comware.py

CMD [ "/run.sh" ]
