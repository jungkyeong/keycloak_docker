## 사용법

### 도커 컨테이너 시작
1. 빌드 및 실행
- docker-compose up -d --build
2. 실행
- docker-compose up -d
2. 중지
- docker-compose down
3. 완전 삭제
- docker-compose down -v
4. 로그 조회
- docker-compose logs -f

### Provider 탑재
1. keycloak-provider-test git 저장소에서 jar 제작 후, providers 폴더에 업로드하면 컨테이너 빌드 때 알아서 올라감

