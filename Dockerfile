# KeyCloak HTTP 서버 실행 cmd
# docker run -p 127.0.0.1:8080:8080 -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:26.3.1 start-dev

# ========== 사용법  ========== # 
## Powershell 해당 Dockerfile 위치에서
# # 이미지 빌드
# docker build -t keycloak-https .
# 
# # 실행
# docker run -d -p 8443:8443 --name keycloak-https keycloak-https
# 
# # ID 조회 후 중지
# docker ps 후 
# docker stop [CONTAINER ID]
# 
# # 컨테이터 삭제
# docker rm [CONTAINER ID]

# # Keycloak용 키 반출
# docker cp keycloak-https:/opt/keycloak/cert ./cert
# 명령어 수행 후 (server.keystore에 들어가서 반출하고자 하는 키 반출) 
# =========================== # 

# 1. Alpine 패키지 매니저를 통해 OpenSSL 인증서 생성
FROM alpine:latest as cert-generator
RUN apk add --no-cache openssl
RUN mkdir -p /certs
RUN openssl req -x509 -newkey rsa:2048 \
    -keyout /certs/server.key \
    -out /certs/server.pem \
    -days 365 -nodes \
    -subj "/CN=localhost"
RUN cp /certs/server.pem /certs/server.crt

# 2. Keycloak 이미지
FROM quay.io/keycloak/keycloak:26.3.1

# 3. ID, 비밀번호 세팅
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin123

# 4. 생성한 인증서를 root 권한으로 Keycloack 컨테이너에 복사
USER root
COPY --from=cert-generator /certs /opt/keycloak/cert

# 5. keycloak 사용자 파일 접근 권한 부여 (644: 읽기, 쓰기)
RUN chown -R keycloak:keycloak /opt/keycloak/cert
RUN chmod 644 /opt/keycloak/cert/*

# 6. Keycloak용 keystore 생성
RUN keytool -importkeystore \
    -srcstoretype PKCS12 \
    -srcstorepass password \
    -destkeystore /opt/keycloak/conf/server.keystore \
    -deststorepass password

# 7. Keycloak HTTPS 설정
USER keycloak
ENV KC_HOSTNAME=localhost
ENV KC_HTTPS_KEY_STORE_FILE=/opt/keycloak/conf/server.keystore
ENV KC_HTTPS_KEY_STORE_PASSWORD=password

# 포트 open
EXPOSE 8443

# 8. Keycloak 실행 명령어 등록
# 기본 실행 파일
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
# 개발 모드, HTTPS 8443 포트
CMD ["start-dev", "--https-port=8443"]