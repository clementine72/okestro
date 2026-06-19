pipeline {
    agent any

    environment {
        // GitHub 및 Harbor 설정 정보 변경 필요
        REGISTRY_URL   = 'harbor.yourdomain.com'             // 본인의 Harbor 도메인 주소
        PROJECT_NAME   = 'ai-agents'                         // Harbor 내의 프로젝트(레포지토리) 이름
        IMAGE_NAME     = 'python-llm-agent'                  // 생성할 이미지 이름
        HARBOR_CREDS   = 'harbor-credentials'                // Jenkins에 등록한 Harbor 자격증명 ID
        
        // 빌드 버전 태그 (Jenkins 빌드 번호 조합)
        IMAGE_TAG      = "v1.0.${BUILD_NUMBER}"
        FULL_IMAGE_URI = "${REGISTRY_URL}/${PROJECT_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                // GitHub 소스 코드 체크아웃 (Jenkins 웹 UI에서 Pipeline from SCM 설정 시 생략 가능)
                checkout scm
                echo "Code checked out successfully."
            }
        }

        stage('2. Security & Lint (선택)') {
            steps {
                echo 'Running Python Linting and Security Checks...'
                // 필요시 flake8 이나 black, safety 같은 도구 활용 가능
                // sh 'pip install flake8 && flake8 .'
            }
        }

        stage('3. Docker Build') {
            steps {
                echo "Building Docker Image: ${FULL_IMAGE_URI}"
                // 빌드 시점에 생성한 도커파일(Dockerfile)을 기준으로 빌드
                sh "docker build -t ${FULL_IMAGE_URI} ."
            }
        }

        stage('4. Harbor Registry Push') {
            steps {
                echo "Logging into Harbor and Pushing Image..."
                // Jenkins Credentials 기능으로 안전하게 Harbor 로그인 후 푸시 및 로그아웃
                withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDS}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                    sh "echo '${HARBOR_PASS}' | docker login ${REGISTRY_URL} -u '${HARBOR_USER}' --password-stdin"
                    sh "docker push ${FULL_IMAGE_URI}"
                    sh "docker logout ${REGISTRY_URL}"
                }
                echo "Image successfully pushed to Harbor!"
            }
        }

        stage('5. Deploy Agent') {
            steps {
                echo "Deploying the AI Agent to Target Server..."
                // 배포 환경(SSH, Kubernetes, Docker Compose 등)에 맞춰 작성합니다.
                // 아래는 원격 서버에 Docker로 간단히 띄우는 예시입니다.
                /*
                sshagent(['target-server-ssh-key']) {
                    sh "ssh user@target-ip 'docker pull ${FULL_IMAGE_URI} && docker run -d -p 8000:8000 ${FULL_IMAGE_URI}'"
                }
                */
            }
        }
    }

    post {
        always {
            echo "Cleaning up local workspace images..."
            // Jenkins 서버의 디스크 공간 확보를 위해 빌드된 로컬 이미지 삭제
            sh "docker rmi ${FULL_IMAGE_URI} || true"
        }
        success {
            echo "CI/CD Pipeline Completed Successfully!"
        }
        failure {
            echo "Pipeline Failed. Please check the logs."
        }
    }
}