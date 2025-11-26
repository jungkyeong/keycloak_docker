## Docker compose yml
1. config 설정
- Dockerfile보다 docker-compose.yml 옵션 적용 값이 우선됨
- docker compose 에 있는 값이 오버라이드 되며 만약 없어도 Dockerfile에 있는 값들이 기본 값으로써 동작됨
- 빌드 스테이지마다 그래도 선언은 한 번씩 되야됨