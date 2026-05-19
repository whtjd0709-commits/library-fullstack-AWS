# Book Management

Spring Boot REST API와 Next.js 프론트엔드로 만든 도서 관리 애플리케이션입니다.

## 배포 트랙

- 선택 트랙: C. AWS Amplify + Elastic Beanstalk
- Frontend: AWS Amplify
- Backend: AWS Elastic Beanstalk, Java 21
- Database: Amazon RDS MySQL 8.0, Private Subnet

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| Backend | Java 21, Spring Boot 3.4.5, Spring Web, Spring Data JPA |
| Database | Local H2, Production MySQL 8.0 on RDS |
| Frontend | Next.js 16, React 19, TypeScript |
| Build | Gradle Wrapper, npm |
| Health Check | Spring Boot Actuator |

## 로컬 실행

### Backend

```bash
cd book-management-api
gradlew.bat bootRun
```

- API: http://localhost:8080
- Health: http://localhost:8080/actuator/health
- H2 Console: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:mem:bookdb`
- Username: `sa`
- Password: empty

### Frontend

```bash
cd book-management-front
npm install
npm run dev
```

- UI: http://localhost:3000

프론트에서 사용할 API 주소를 바꾸려면 `book-management-front/.env.local`에 설정합니다.

```env
NEXT_PUBLIC_API_URL=http://localhost:8080
```

## 운영 환경변수

Elastic Beanstalk 환경변수:

```env
SPRING_PROFILES_ACTIVE=prod
DB_HOST=your-rds-endpoint.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_NAME=bookdb
DB_USER=admin
DB_PASS=your-password
CORS_ORIGINS=https://your-amplify-domain.amplifyapp.com
```

Amplify 환경변수:

```env
NEXT_PUBLIC_API_URL=http://your-eb-env.ap-northeast-2.elasticbeanstalk.com
```

## AWS 배포 메모

1. VPC에 Public Subnet 2개, Private Subnet 2개를 구성합니다.
2. RDS MySQL은 Private Subnet에 배치하고 Public Access를 비활성화합니다.
3. RDS 보안그룹은 Elastic Beanstalk EC2 보안그룹에서 오는 3306 포트만 허용합니다.
4. Elastic Beanstalk는 Java 21 플랫폼으로 생성하고 Health check path를 `/actuator/health`로 설정합니다.
5. Amplify는 GitHub 저장소를 연결하고 `amplify.yml` 기준으로 `book-management-front`를 빌드합니다.
6. Amplify 배포 후 생성된 HTTPS URL을 `CORS_ORIGINS`에 반영합니다.

## API

기본 URL:

```text
http://localhost:8080
```

주요 엔드포인트:

| Method | Path | 설명 |
| --- | --- | --- |
| GET | `/api/books` | 도서 목록 조회 |
| GET | `/api/books/{id}` | 도서 상세 조회 |
| GET | `/api/books/search?title=keyword` | 제목 검색 |
| POST | `/api/books` | 도서 등록 |
| PUT | `/api/books/{id}` | 도서 수정 |
| DELETE | `/api/books/{id}` | 도서 삭제 |
| GET | `/actuator/health` | 서버 및 DB 상태 확인 |

## 배포 관련 파일

- `amplify.yml`: Amplify 프론트엔드 빌드 설정
- `buildspec.yml`: 백엔드 JAR 빌드 및 EB 산출물 생성
- `Procfile`: Elastic Beanstalk Java 애플리케이션 실행 명령
- `book-management-api/src/main/resources/schema.sql`: DB 테이블 생성
- `book-management-api/src/main/resources/data.sql`: 초기 도서 데이터 3건
