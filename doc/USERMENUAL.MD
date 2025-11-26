## 사용법

### 도커 컨테이너 시작
1. 빌드 및 실행
- docker-compose up -d --build (구버전)
- sudo docker compose up -d --build (신버전)
2. 실행
- docker-compose up -d
2. 중지
- docker-compose down
3. 완전 삭제
- docker-compose down -v
4. 로그 조회
- docker-compose logs -f

5. 참고 (구버전은 docker-compose, 신버전은 docker compose 이렇게 동작시켜야 함)
- docker-compose --version
    - docker-compose version 1.25.0, build unknown
- docker compose version
    - Docker Compose version v2.35.1
- 신버전 사용 시 해당 코드 docker compose에서 제거
    - version: '3.8'

### Provider 탑재
1. keycloak-provider-test git 저장소에서 jar 제작 후, providers 폴더에 업로드하면 컨테이너 빌드 때 알아서 올라감

### DB 접속 확인
1. psql 접속 
- docker exec -it keycloak-postgres psql -U keycloak -d keycloak (기본 5432 포트인 경우)
- docker exec -it keycloak-postgres psql -U keycloak -d keycloak -p 8888 (DB 컨테이너가 8888 포트라면)

