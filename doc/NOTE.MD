## 메모 정리

### keycloak 설정
1. config 설정
- Dockerfile보다 docker-compose.yml 옵션 적용 값이 우선됨
- docker compose 에 있는 값이 오버라이드 되며 만약 없어도 Dockerfile에 있는 값들이 기본 값으로써 동작됨
- 빌드 스테이지마다 그래도 선언은 한 번씩 되야됨

### DB 연결
1. keycloak jdbc 연결 
- jdbc:postgresql://postgres:5432/keycloak
    - jdbc: Java Database Connectivity (Java DB 연결 표준)
    - postgres: 호스트명 (docker-compose 서비스명)
    - 5432: 포트 (컨테이너 내부용) 
        - 만약 DB 포트를 바꾸고 싶다 하면 compose 파일 내 postgres 서비스 내에 command: -p 8888 추가 및 jdbc url 포트 변경
    - keycloak: 데이터베이스 이름 (POSTGRES_DB)

2. 해당 Dockerfile 위치로부터 data/postgres 폴더에 생성됨

3. health test
- test: ["CMD", "pg_isready", "-U", "keycloak", "-d", "keycloak", "-p", "8888"]
- healthy, 아니면 unhealthy인지 확인 cmd (DB가 연결될 준비가 되었는지 확인)

### TEST
1. Docker Desktop 및 Linux 서버 환경에서 확인