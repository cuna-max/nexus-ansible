# Nexus Ansible 프로젝트

이 프로젝트는 Ansible을 사용하여 Nexus 마이닝 노드들을 자동으로 배포하고 관리하는 도구입니다.

## 🚀 주요 기능

- **자동 배포**: Nexus 마이닝 노드를 원격 서버에 자동으로 설치 및 설정
- **일괄 관리**: 여러 서버를 동시에 관리할 수 있는 중앙화된 관리 시스템
- **간편한 명령어**: Makefile을 통한 직관적인 명령어 제공
- **실시간 모니터링**: 노드 상태 실시간 확인 및 모니터링
- **안전한 설정**: 환경 변수를 통한 민감한 정보 보호

## 📋 요구사항

### 시스템 요구사항

- **Ansible**: 2.9 이상
- **Python**: 3.6 이상
- **대상 서버**: Ubuntu/Debian 기반 Linux

### 네트워크 요구사항

- Ansible 컨트롤 노드에서 대상 서버로의 SSH 접근 가능
- 인터넷 연결 (GitHub에서 스크립트 다운로드)

## 🛠️ 설치 및 설정

### 1. Ansible 설치

#### macOS

```bash
brew install ansible
```

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y ansible
```

#### Python (pip)

```bash
pip install ansible
```

### 2. 프로젝트 설정

#### 초기 설정

```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd nexus-ansible

# 2. 설정 파일 생성
cp group_vars/miners.yml.example group_vars/miners.yml
cp inventory.ini.example inventory.ini
```

#### 서버 접속 정보 설정

**group_vars/miners.yml** 파일을 편집하여 서버 접속 정보를 설정합니다:

```yaml
# 서버 접속 정보 설정
ansible_user: root
ansible_ssh_pass: <password> # 실제 서버 비밀번호 입력
ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
```

#### 서버 목록 설정

**inventory.ini** 파일을 편집하여 관리할 서버들을 추가합니다:

```ini
[miners]
# 형식: 서버명 ansible_host=IP주소 node_id=노드ID threads=채굴스레드수
server1 ansible_host=192.168.1.100 node_id=7006171 threads=1
server2 ansible_host=192.168.1.101 node_id=7096264 threads=1
```

**설정 변수 설명:**

- `node_id`: Nexus 마이닝 노드 ID
- `threads`: 각 노드에서 사용할 CPU 스레드 수

## 🔧 사용법

### Makefile 명령어 (권장)

```bash
# 도움말 보기
make help

# 서버 연결 상태 확인
make ping

# Nexus 배포 (병렬 처리 최적화)
make deploy

# Nexus 노드 상태 확인
make status

# Nexus 노드 재시작 (기존 설정으로)
make restart

# 실시간 노드 모니터링
make monitor

# 시스템 상태 체크
make check

# 정리 작업
make cleanup

# 고급 배포 옵션
make deploy-fast   # 고속 배포 (20개 병렬 처리)
make deploy-batch  # 배치 배포 (5개씩 그룹 처리)

# 특정 서버에만 실행 (예: make ping-single SERVER=server1)
make ping-single SERVER=server1
make deploy-single SERVER=server1
make status-single SERVER=server1
make restart-single SERVER=server1
```

### 직접 Ansible 명령어 사용

```bash
# 모든 서버에 배포
ansible-playbook -i inventory.ini playbooks/nexus.yml

# 특정 서버에만 배포
ansible-playbook -i inventory.ini playbooks/nexus.yml --limit server1

# 서버 연결 테스트
ansible miners -i inventory.ini -m ping

# 서버 상태 확인
ansible miners -i inventory.ini -m shell -a "bash /root/nexus_multi.sh status"
```

## 📁 프로젝트 구조

```
nexus-ansible/
├── group_vars/
│   ├── miners.yml.example    # 서버 접속 정보 예시
│   └── miners.yml           # 실제 서버 접속 정보 (Git에서 제외)
├── inventory.ini.example     # 서버 목록 예시
├── inventory.ini            # 실제 서버 목록 (Git에서 제외)
├── playbooks/               # Ansible 플레이북 모음
│   ├── nexus.yml            # 메인 배포 플레이북
│   └── restart.yml          # 재시작 플레이북
├── Makefile                 # 편의 명령어 모음
├── roles/
│   └── nexus/              # Nexus 설치 역할
│       ├── tasks/
│       │   └── main.yml    # 설치 작업 정의
│       └── files/
│           ├── nexus_multi.sh # Nexus 다중 노드 설치 스크립트
│           └── nexus_s3.sh    # Nexus S3 설치 스크립트 (백업용)
├── .gitignore              # Git 제외 파일 목록
└── README.md
```

## 🔒 보안 주의사항

⚠️ **중요**: 다음 파일들은 민감한 정보를 포함하므로 절대 Git에 커밋하지 마세요:

- `group_vars/miners.yml` - 서버 접속 비밀번호
- `inventory.ini` - 서버 IP 주소 및 노드 ID

이 파일들은 `.gitignore`에 포함되어 있어 실수로 커밋되는 것을 방지합니다.

## 📝 설정 예시

### 단일 서버 설정

```ini
[miners]
my-server ansible_host=203.0.113.10 node_id=1234567 threads=1
```

### 다중 서버 설정

```ini
[miners]
server1 ansible_host=203.0.113.10 node_id=1234567 threads=1
server2 ansible_host=203.0.113.11 node_id=1234568 threads=2
server3 ansible_host=203.0.113.12 node_id=1234569 threads=4
```

## ⚡ 성능 최적화

### 병렬 처리 설정

이 프로젝트는 대규모 서버 배포를 위해 다음과 같은 성능 최적화가 적용되어 있습니다:

#### 기본 최적화

- **병렬 처리**: 기본 10개 서버 동시 처리
- **SSH 최적화**: ControlMaster와 pipelining 활성화
- **타임아웃 최적화**: 불필요한 대기 시간 단축
- **Fact 캐싱**: 시스템 정보 캐싱으로 속도 향상

#### 배포 옵션별 성능

```bash
# 기본 배포 (10개 병렬)
make deploy

# 고속 배포 (20개 병렬) - 대규모 서버용
make deploy-fast

# 배치 배포 (5개씩 그룹) - 안정성 중시
make deploy-batch
```

#### 성능 비교

- **기존 방식**: 서버 1개씩 순차 처리
- **최적화 후**: 서버 10-20개 동시 처리
- **예상 속도 향상**: 5-10배 빠른 배포

### 시스템 요구사항

고성능 배포를 위한 권장 사항:

- **Ansible 컨트롤 노드**: 최소 4GB RAM, 4코어 CPU
- **네트워크**: 안정적인 인터넷 연결
- **대상 서버**: SSH 연결 지연 시간 < 100ms

## 🔧 작업 흐름

### 1. 배포 과정

1. **의존성 설치**: `screen` 패키지 설치
2. **스크립트 복사**: `nexus_multi.sh`를 대상 서버에 복사
3. **자동 설정**: 환경 변수를 통한 자동 설정
   - `AUTO_MODE=1`: 자동 모드 활성화
   - `NODE_COUNT=1`: 노드 개수 설정
   - `THREADS_PER_NODE`: 스레드 수 설정
   - `NODE_ID`: 노드 ID 설정
4. **스크립트 실행**: Nexus 마이닝 노드 설치 및 시작

### 2. 모니터링 및 관리

- **상태 확인**: `make status`로 모든 노드 상태 확인
- **실시간 모니터링**: `make monitor`로 실시간 상태 모니터링
- **재시작**: `make restart`로 노드 재시작
- **시스템 체크**: `make check`로 CPU, 메모리, 디스크 사용률 확인

## 📞 지원

문제가 발생하거나 추가 기능이 필요한 경우 이슈를 등록해 주세요.
