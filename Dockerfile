# KeyCloak HTTP 서버 실행 cmd
# docker run -p 127.0.0.1:8080:8080 -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:26.3.1 start-dev

# ========== 사용법  ========== # 
## Powershell 해당 Dockerfile 위치에서
# # 이미지 빌드
# docker build -t keycloak-java .
# 
# # 실행
# docker run -d -p 8443:8443 --name keycloak-java keycloak-java
# 
# # ID 조회 후 중지
# docker ps 후 
# docker stop [CONTAINER ID]
# 
# # 컨테이터 삭제
# docker rm [CONTAINER ID]

# # Keycloak용 키 반출
# docker cp keycloak-java:/opt/keycloak/cert ./cert
# 명령어 수행 후 (server.keystore에 들어가서 반출하고자 하는 키 반출) 
# =========================== #

# 1. Ubuntu 22.04 베이스
FROM ubuntu:22.04

# 2. 필수 패키지 설치 (openjdk-21, openssl .. 후, APT 캐시 삭제)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    curl \
    unzip \
    openssl \
    vim \
#    sudo \
    && rm -rf /var/lib/apt/lists/*

# 3. Keycloak tar.gz 파일 복사 및 설치
COPY keycloak-26.3.4.tar.gz /opt/
RUN tar -xzf /opt/keycloak-26.3.4.tar.gz -C /opt && \
    mv /opt/keycloak-26.3.4 /opt/keycloak && \
    rm /opt/keycloak-26.3.4.tar.gz

# 4. OpenSSL 인증서 생성
RUN mkdir -p /opt/keycloak/cert && \
    openssl req -x509 -newkey rsa:2048 \
        -keyout /opt/keycloak/cert/server.key \
        -out /opt/keycloak/cert/server.pem \
        -days 365 -nodes \
        -subj "/CN=localhost" && \
    openssl pkcs12 -export \
        -in /opt/keycloak/cert/server.pem \
        -inkey /opt/keycloak/cert/server.key \
        -out /opt/keycloak/cert/server.p12 \
        -name keycloak \
        -passout pass:password && \
    keytool -importkeystore \
        -srckeystore /opt/keycloak/cert/server.p12 \
        -srcstoretype PKCS12 \
        -srcstorepass password \
        -destkeystore /opt/keycloak/conf/server.keystore \
        -deststorepass password \
        -noprompt

# 5. Keycloak 환경 변수 setting
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin123
ENV KC_HOSTNAME=192.168.0.16
ENV KC_HTTPS_KEY_STORE_FILE=/opt/keycloak/conf/server.keystore
ENV KC_HTTPS_KEY_STORE_PASSWORD=password

# 6. Provider file COPY
# COPY ./providers/*.jar /opt/keycloak/providers/

# 7. 비루트 사용자 생성 및 권한 설정

#RUN useradd -ms /bin/bash keycloak && \
#    chown -R keycloak:keycloak /opt/keycloak
#USER keycloak

# 포트 open
EXPOSE 8443

# 9. Keycloak 실행 명령어 등록
# 기본 실행 파일
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
# 개발 모드, HTTPS 8443 포트
CMD ["start-dev", "--https-port=8443"]

