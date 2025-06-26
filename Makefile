# Nexus Ansible Makefile
# 사용법: make <target>

# 기본 설정
INVENTORY = inventory.ini
GROUP = miners
NEXUS_SCRIPT = /root/nexus_multi.sh
ERROR_MSG = Nexus script not found

# 기본 타겟
.PHONY: help
help:
	@echo "사용 가능한 명령어:"
	@echo "  make ping          - 서버 연결 상태 확인"
	@echo "  make deploy        - Nexus 새로 배포 (스크립트 복사 + 실행)"
	@echo "  make status        - Nexus 노드 상태 확인"
	@echo "  make restart       - Nexus 노드 재시작 (기존 설정으로)"
	@echo "  make monitor       - 실시간 노드 모니터링"
	@echo "  make update        - Nexus 업데이트"
	@echo "  make check         - 시스템 상태 체크"
	@echo "  make cleanup       - 정리 작업"
	@echo ""
	@echo "특정 서버 명령어 (SERVER=서버명 지정 필요):"
	@echo "  make ping-single    - 특정 서버 연결 확인"
	@echo "  make deploy-single  - 특정 서버에 새로 배포"
	@echo "  make status-single  - 특정 서버 노드 상태 확인"
	@echo "  make restart-single - 특정 서버 노드 재시작"

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

# Nexus 노드 상태 확인
.PHONY: status
status:
	@echo "📊 Nexus 노드 상태를 확인합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "bash $(NEXUS_SCRIPT) status || echo '$(ERROR_MSG)'"

# Nexus 노드 재시작
.PHONY: restart
restart:
	@echo "🔄 Nexus 노드를 재시작합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "bash $(NEXUS_SCRIPT) restart || echo '$(ERROR_MSG)'"

# 실시간 노드 모니터링
.PHONY: monitor
monitor:
	@echo "📈 실시간 Nexus 노드 모니터링을 시작합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "bash $(NEXUS_SCRIPT) monitor || echo '$(ERROR_MSG)'"

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

# 특정 서버의 Nexus 노드 상태 확인
.PHONY: status-single
status-single:
	@echo "📊 $(SERVER) 서버의 Nexus 노드 상태를 확인합니다..."
	ansible $(SERVER) -i $(INVENTORY) -m shell -a "bash $(NEXUS_SCRIPT) status || echo '$(ERROR_MSG)'"

# 특정 서버의 Nexus 노드 재시작
.PHONY: restart-single
restart-single:
	@echo "🔄 $(SERVER) 서버의 Nexus 노드를 재시작합니다..."
	ansible $(SERVER) -i $(INVENTORY) -m shell -a "bash $(NEXUS_SCRIPT) restart || echo '$(ERROR_MSG)'"
