# Nexus Ansible 프로젝트

이 프로젝트는 Ansible을 사용하여 Nexus 마이닝 노드들을 자동으로 배포하고 관리하는 도구입니다.

## 🚀 주요 기능

- **자동 배포**: Nexus 마이닝 노드를 원격 서버에 자동으로 설치 및 설정
- **일괄 관리**: 여러 서버를 동시에 관리할 수 있는 중앙화된 관리 시스템
- **간편한 명령어**: Makefile을 통한 직관적인 명령어 제공
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
ansible_user: root
ansible_ssh_pass: "{{ lookup('env', 'ANSIBLE_SSH_PASS') }}"
ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
```

#### 서버 목록 설정

**inventory.ini** 파일을 편집하여 관리할 서버들을 추가합니다:

```ini
[miners]
# 형식: 서버명 ansible_host=IP주소 node_id=노드ID
contabo1 ansible_host=192.168.1.100 node_id=7006171
contabo2 ansible_host=192.168.1.101 node_id=7096264
```

## 🔧 사용법

### Makefile 명령어 (권장)

```bash
# 도움말 보기
make help

# 서버 연결 상태 확인
make ping

# Nexus 배포
make deploy

# 특정 서버에만 배포
make deploy-single SERVER=contabo1

# 서버 상태 확인
make status

# Nexus 로그 확인
make logs

# Nexus 재시작
make restart

# 시스템 상태 체크
make check

# 정리 작업
make cleanup
```

### 직접 Ansible 명령어 사용

```bash
# 모든 서버에 배포
ansible-playbook -i inventory.ini nexus.yml

# 특정 서버에만 배포
ansible-playbook -i inventory.ini nexus.yml --limit contabo1

# 서버 연결 테스트
ansible miners -i inventory.ini -m ping
```

## 📁 프로젝트 구조

```
nexus-ansible/
├── group_vars/
│   ├── miners.yml.example    # 서버 접속 정보 예시
│   └── miners.yml           # 실제 서버 접속 정보 (Git에서 제외)
├── inventory.ini.example     # 서버 목록 예시
├── inventory.ini            # 실제 서버 목록 (Git에서 제외)
├── nexus.yml                # 메인 플레이북
├── Makefile                 # 편의 명령어 모음
├── roles/
│   └── nexus/              # Nexus 설치 역할
│       ├── tasks/
│       │   └── main.yml    # 설치 작업 정의
│       └── files/
│           └── nexus_s3.sh # Nexus 설치 스크립트 (백업용)
├── .gitignore              # Git 제외 파일 목록
└── README.md
```

## 🔒 보안 주의사항

⚠️ **중요**: 다음 파일들은 민감한 정보를 포함하므로 절대 Git에 커밋하지 마세요:

- `group_vars/miners.yml` - 서버 접속 비밀번호
- `inventory.ini` - 서버 IP 주소 및 노드 ID
- `.env` - 환경 변수 (비밀번호 등)

이 파일들은 `.gitignore`에 포함되어 있어 실수로 커밋되는 것을 방지합니다.

## 📝 설정 예시

### 단일 서버 설정

```ini
[miners]
my-server ansible_host=203.0.113.10 node_id=1234567
```

### 다중 서버 설정

```ini
[miners]
server1 ansible_host=203.0.113.10 node_id=1234567
server2 ansible_host=203.0.113.11 node_id=1234568
server3 ansible_host=203.0.113.12 node_id=1234569
```
