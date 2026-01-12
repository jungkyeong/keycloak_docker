# KeyCloak HTTPS 서버 Dockerfile

# Default Value (docker compose에 설정 값 없을 경우 해당 값으로 적용됨)
# ARG HOSTNAME=192.168.0.16
# ARG HTTPS_PORT=8443
# ARG KEYSTORE_PASSWORD=password

# Stage 1: 인증서 생성 (Alpine Linux의 패키지 매니저 사용)
FROM alpine:latest AS cert-generator
ARG HOSTNAME
ARG KEYSTORE_PASSWORD

# openssl 빌드용 설치
RUN apk add --no-cache openssl && mkdir -p /certs

# 자체 서명 인증서 생성
RUN openssl req -x509 -newkey rsa:2048 \
    -keyout /certs/server.key \
    -out /certs/server.pem \
    -days 3650 -nodes \
    -subj "/CN=${HOSTNAME}"

# PKCS12 키스토어 생성
RUN openssl pkcs12 -export \
    -in /certs/server.pem \
    -inkey /certs/server.key \
    -out /certs/server.p12 \
    -name keycloak \
    -passout pass:${KEYSTORE_PASSWORD}

# Stage 2: Keycloak 이미지
FROM quay.io/keycloak/keycloak:26.3.1
ARG HOSTNAME
ARG HTTPS_PORT
ARG KEYSTORE_PASSWORD

USER root

# 인증서 복사 및 권한 설정
COPY --from=cert-generator /certs /opt/keycloak/cert
RUN chown -R keycloak:keycloak /opt/keycloak/cert && \
    chmod 644 /opt/keycloak/cert/*

# providers JAR 복사
RUN mkdir -p /opt/keycloak/providers
COPY ./providers/*.jar /opt/keycloak/providers/
RUN chown -R keycloak:keycloak /opt/keycloak/providers && \
    chmod 644 /opt/keycloak/providers/*

# 커스텀 테마 복사
COPY ./themes /opt/keycloak/themes
RUN chown -R keycloak:keycloak /opt/keycloak/themes

# PKCS12 → Java KeyStore 변환
RUN keytool -importkeystore \
    -srckeystore /opt/keycloak/cert/server.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass ${KEYSTORE_PASSWORD} \
    -destkeystore /opt/keycloak/conf/server.keystore \
    -deststorepass ${KEYSTORE_PASSWORD} \
    -noprompt

# Keycloak 설정
USER keycloak
ENV KC_HOSTNAME=${HOSTNAME}
ENV KC_HTTPS_PORT=${HTTPS_PORT}
ENV KC_HTTPS_KEY_STORE_FILE=/opt/keycloak/conf/server.keystore
ENV KC_HTTPS_KEY_STORE_PASSWORD=${KEYSTORE_PASSWORD}

EXPOSE ${HTTPS_PORT}

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev"]
