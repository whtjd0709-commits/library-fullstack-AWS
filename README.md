# Book Management

Spring Boot REST API와 Next.js 프론트엔드로 만든 도서 관리 애플리케이션입니다.  
AWS Amplify, Elastic Beanstalk, RDS MySQL을 사용해 C 트랙 기준으로 배포했습니다.

## GitHub 저장소

- https://github.com/whtjd0709-commits/library-fullstack-AWS

## 배포 URL

- Frontend: https://main.d22l5u4g8e8eq5.amplifyapp.com
- Backend: http://book-management-api-env.eba-kfbhrgdg.ap-northeast-2.elasticbeanstalk.com
- Health Check: http://book-management-api-env.eba-kfbhrgdg.ap-northeast-2.elasticbeanstalk.com/actuator/health
- Books API: http://book-management-api-env.eba-kfbhrgdg.ap-northeast-2.elasticbeanstalk.com/api/books

## 선택 트랙

- 트랙: C. AWS Amplify + Elastic Beanstalk
- Frontend: AWS Amplify Hosting, Next.js SSR, WEB_COMPUTE
- Backend: AWS Elastic Beanstalk, Java 21
- Database: Amazon RDS MySQL 8.x, Private Subnet

## 주요 기능

- 도서 목록 조회
- 도서 제목 검색
- 도서 상세 조회
- 도서 등록
- 도서 수정
- 도서 삭제
- `/actuator/health` 기반 서버 및 DB 상태 확인

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| Backend | Java 21, Spring Boot 3.4.5, Spring Web, Spring Data JPA, Actuator |
| Database | Local H2, Production Amazon RDS MySQL |
| Frontend | Next.js 16, React 19, TypeScript |
| Build | Gradle Wrapper, npm |
| Deploy | AWS Amplify, AWS Elastic Beanstalk |

## AWS 서비스 목록

| 서비스 | 용도 |
| --- | --- |
| Amazon VPC | 퍼블릭·프라이빗 서브넷, IGW, NAT Gateway |
| Amazon RDS (MySQL 8.0) | 운영 DB (Private Subnet, 퍼블릭 액세스 비활성화) |
| AWS Amplify Hosting | Next.js 프론트엔드 빌드·배포 (WEB_COMPUTE, CI/CD) |
| AWS Elastic Beanstalk | Spring Boot 백엔드 (Java 21) |
| Amazon EC2 | EB 환경 인스턴스 |
| Elastic Load Balancing | EB 로드 밸런서 (환경 유형에 따라 포함) |
| AWS IAM | EB EC2 인스턴스 프로파일, Amplify 서비스 역할 |

## 아키텍처

```text
User
  |
  v
AWS Amplify Hosting
  |
  v
Elastic Beanstalk Web Server
  |
  v
Amazon RDS MySQL
```

프론트엔드 API 주소는 Amplify 콘솔 환경 변수 `NEXT_PUBLIC_API_URL`에 설정합니다.

## 운영 환경변수

### Elastic Beanstalk

```env
SPRING_PROFILES_ACTIVE=prod
DB_HOST=book-management-db.c5ygiuewy15t.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_NAME=bookdb
DB_USER=admin
DB_PASS=your-password
CORS_ORIGINS=https://main.d22l5u4g8e8eq5.amplifyapp.com
```

### Amplify

```env
AMPLIFY_MONOREPO_APP_ROOT=book-management-front
NEXT_PUBLIC_API_URL=http://book-management-api-env.eba-kfbhrgdg.ap-northeast-2.elasticbeanstalk.com
```

## AWS 배포 설정

1. VPC에 Public Subnet 2개, Private Subnet 2개를 구성했습니다.
2. RDS MySQL은 Private Subnet에 배치하고 Public Access를 비활성화했습니다.
3. RDS 보안그룹은 Elastic Beanstalk EC2 보안그룹에서 오는 MySQL 3306 포트만 허용했습니다.
4. Elastic Beanstalk는 Java 21 플랫폼으로 생성하고 `Procfile`로 Spring Boot JAR를 실행합니다.
5. Elastic Beanstalk health check path는 `/actuator/health`입니다.
6. Amplify는 GitHub 저장소를 연결하고 `book-management-front`를 monorepo app root로 설정했습니다.
7. Amplify 플랫폼은 Next.js SSR 지원을 위해 `WEB_COMPUTE`로 배포했습니다.

## API 엔드포인트

| Method | Path | 설명 |
| --- | --- | --- |
| GET | `/api/books` | 도서 목록 조회 |
| GET | `/api/books/{id}` | 도서 상세 조회 |
| GET | `/api/books/search?title=keyword` | 도서 제목 검색 |
| POST | `/api/books` | 도서 등록 |
| PUT | `/api/books/{id}` | 도서 수정 |
| DELETE | `/api/books/{id}` | 도서 삭제 |
| GET | `/actuator/health` | 서버 및 DB 상태 확인 |

## 배포 관련 파일

- `amplify.yml`: Amplify monorepo 및 Next.js 빌드 설정
- `Procfile`: Elastic Beanstalk Java 애플리케이션 실행 명령
- `.ebextensions/healthcheck.config`: Elastic Beanstalk health check path 설정
- `scripts/package-eb.ps1`: 수동 EB 업로드용 `backend-eb.zip` 생성 스크립트
- `book-management-api/src/main/resources/schema.sql`: DB 테이블 생성
- `book-management-api/src/main/resources/data.sql`: 초기 도서 데이터 3건
