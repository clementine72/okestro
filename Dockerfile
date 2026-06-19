# 1단계: 빌드 스테이지 (의존성 패키지 설치)
FROM python:3.11-slim AS builder

WORKDIR /app

# 필수 빌드 도구 설치 (C 확장 모듈 등이 필요한 패키지 대비)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 가상환경 생성 및 패키지 설치
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
# --no-cache-dir로 캐시를 남기지 않아 용량 최적화
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# 2단계: 런타임 스테이지 (실제 실행용 경량 이미지)
FROM python:3.11-slim AS runner

WORKDIR /app

# 빌드 스테이지에서 설치된 패키지만 복사 (용량 최소화)
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 애플리케이션 소스 코드 복사
COPY . .

# 보안을 위해 root가 아닌 일반 사용자(appuser)로 실행
RUN useradd -u 8888 appuser && chown -R appuser:appuser /app
USER appuser

# AI 에이전트 실행 포트 설정 (예: FastAPI, Streamlit 등)
EXPOSE 8000

# AI 에이전트 실행 명령어 (FastAPI 예시)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]