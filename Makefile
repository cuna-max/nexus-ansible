# Nexus Ansible Makefile
# 사용법: make <target>

# 기본 설정
INVENTORY = inventory.ini
GROUP = miners

# 기본 타겟
.PHONY: help
help:
	@echo "사용 가능한 명령어:"
	@echo "  make ping          - 서버 연결 상태 확인"
	@echo "  make deploy        - Nexus 배포 실행"
	@echo "  make status        - 서버 상태 확인"
	@echo "  make logs          - Nexus 로그 확인"
	@echo "  make restart       - Nexus 재시작"
	@echo "  make update        - Nexus 업데이트"
	@echo "  make check         - 시스템 상태 체크"
	@echo "  make cleanup       - 정리 작업"

# 서버 연결 상태 확인
.PHONY: ping
ping:
	@echo "🔍 서버 연결 상태를 확인합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m ping

# Nexus 배포
.PHONY: deploy
deploy:
	@echo "🚀 Nexus를 배포합니다..."
	ansible-playbook -i $(INVENTORY) nexus.yml

# 서버 상태 확인
.PHONY: status
status:
	@echo "📊 서버 상태를 확인합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "systemctl status nexus || echo 'Nexus 서비스가 없습니다'"

# Nexus 로그 확인
.PHONY: logs
logs:
	@echo "📋 Nexus 로그를 확인합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "journalctl -u nexus -n 50 --no-pager || echo 'Nexus 로그가 없습니다'"

# Nexus 재시작
.PHONY: restart
restart:
	@echo "🔄 Nexus를 재시작합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "systemctl restart nexus || echo 'Nexus 서비스를 찾을 수 없습니다'"

# Nexus 업데이트
.PHONY: update
update:
	@echo "⬆️  Nexus를 업데이트합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "cd /root && wget -O nexus_s3.sh https://raw.githubusercontent.com/kooroot/Node_Executor-Nexus/refs/heads/main/nexus_s3.sh && chmod +x nexus_s3.sh"

# 시스템 상태 체크
.PHONY: check
check:
	@echo "🔍 시스템 상태를 체크합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "echo '=== CPU 사용률 ===' && top -bn1 | grep 'Cpu(s)' && echo '=== 메모리 사용률 ===' && free -h && echo '=== 디스크 사용률 ===' && df -h"

# 정리 작업
.PHONY: cleanup
cleanup:
	@echo "🧹 정리 작업을 수행합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "apt autoremove -y && apt autoclean"

# 특정 서버에만 실행 (예: make ping-single SERVER=contabo1)
.PHONY: ping-single
ping-single:
	@echo "🔍 $(SERVER) 서버 연결 상태를 확인합니다..."
	ansible $(SERVER) -i $(INVENTORY) -m ping

# 특정 서버에만 배포
.PHONY: deploy-single
deploy-single:
	@echo "🚀 $(SERVER) 서버에 Nexus를 배포합니다..."
	ansible-playbook -i $(INVENTORY) nexus.yml --limit $(SERVER) 