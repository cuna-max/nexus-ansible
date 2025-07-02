# Nexus Ansible Makefile
# 사용법: make <target>

# 기본 설정
INVENTORY = inventory.ini
GROUP = miners
NEXUS_SCRIPT = /root/nexus_multi.sh
ERROR_MSG = Nexus script not found
PLAYBOOKS_DIR = playbooks/

# 기본 타겟
.PHONY: help
help:
	@echo "사용 가능한 명령어:"
	@echo "  make ping          - 서버 연결 상태 확인"
	@echo "  make deploy        - Nexus 새로 배포 (병렬 처리 최적화)"
	@echo "  make status        - Nexus 노드 상태 확인"
	@echo "  make restart       - Nexus 노드 재시작 (기존 설정으로)"
	@echo "  make restart-playbook - Nexus 노드 재시작 (Ansible 플레이북 사용)"
	@echo "  make monitor       - 실시간 노드 모니터링"
	@echo "  make update        - Nexus 업데이트"
	@echo "  make check         - 시스템 상태 체크"
	@echo "  make cleanup       - 정리 작업"
	@echo "  make deploy-fast   - 고속 배포 (20개 병렬)"
	@echo "  make deploy-batch  - 배치 배포 (5개씩 그룹)"
	@echo ""
	@echo "특정 서버 명령어 (SERVER=서버명 지정 필요):"
	@echo "  make ping-single    - 특정 서버 연결 확인"
	@echo "  make deploy-single  - 특정 서버에 새로 배포 (병렬 처리 최적화)"
	@echo "  make status-single  - 특정 서버 노드 상태 확인"
	@echo "  make restart-single - 특정 서버 노드 재시작"
	@echo "  make restart-single-playbook - 특정 서버 노드 재시작 (Ansible 플레이북 사용)"

# 서버 연결 상태 확인
.PHONY: ping
ping:
	@echo "🔍 서버 연결 상태를 확인합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m ping

# Nexus 배포
.PHONY: deploy
deploy:
	@echo "🚀 Nexus를 배포합니다..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)nexus.yml --forks 10 --timeout 300

# Nexus 노드 상태 확인
.PHONY: status
status:
	@echo "📊 Nexus 노드 상태를 확인합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "if [ -f ~/.nexus/nexus.pid ]; then PID=\$(cat ~/.nexus/nexus.pid); if ps -p \$PID > /dev/null; then echo \"Nexus CLI is running with PID: \$PID\"; tail -n 5 ~/.nexus/nexus.log; else echo \"Nexus CLI process not found\"; fi; elif systemctl is-active --quiet nexus-mining; then echo \"Nexus CLI is running as systemd service\"; systemctl status nexus-mining --no-pager -l; else echo \"Nexus CLI status unknown\"; fi"

# 실시간 노드 모니터링
.PHONY: monitor
monitor:
	@echo "📈 실시간 Nexus 노드 모니터링을 시작합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "if systemctl is-active --quiet nexus-mining; then journalctl -u nexus-mining -f; elif screen -list | grep -q nexus-cli; then screen -r nexus-cli; else echo 'Nexus CLI가 실행 중이지 않습니다.'; fi"

# 시스템 상태 체크
.PHONY: check
check:
	@echo "🔍 시스템 상태를 체크합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "echo '=== CPU 사용률 ===' && top -bn1 | grep 'Cpu(s)' && echo '=== 메모리 사용률 ===' && free -h && echo '=== 디스크 사용률 ===' && df -h"

# 정리 작업
.PHONY: cleanup
cleanup:
	@echo "🧹 정리 작업을 수행합니다..."
	ansible $(GROUP) -i $(INVENTORY) -m shell -a "apt autoremove -y && apt autoclean && killall screen && pkill -f "ssh.*@""

# 특정 서버에만 실행 (예: make ping-single SERVER=contabo1)
.PHONY: ping-single
ping-single:
	@echo "🔍 $(SERVER) 서버 연결 상태를 확인합니다..."
	ansible $(SERVER) -i $(INVENTORY) -m ping

# 특정 서버에만 배포
.PHONY: deploy-single
deploy-single:
	@echo "🚀 $(SERVER) 서버에 Nexus를 배포합니다..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)nexus.yml --limit $(SERVER) --forks 10 --timeout 300

# 특정 서버의 Nexus 노드 상태 확인
.PHONY: status-single
status-single:
	@echo "📊 $(SERVER) 서버의 Nexus 노드 상태를 확인합니다..."
	ansible $(SERVER) -i $(INVENTORY) -m shell -a "if [ -f ~/.nexus/nexus.pid ]; then PID=\$(cat ~/.nexus/nexus.pid); if ps -p \$PID > /dev/null; then echo \"Nexus CLI is running with PID: \$PID\"; tail -n 5 ~/.nexus/nexus.log; else echo \"Nexus CLI process not found\"; fi; elif systemctl is-active --quiet nexus-mining; then echo \"Nexus CLI is running as systemd service\"; systemctl status nexus-mining --no-pager -l; else echo \"Nexus CLI status unknown\"; fi"

# 특정 서버의 Nexus 노드 재시작 (Ansible 플레이북 사용)
.PHONY: restart-single-playbook
restart-single-playbook:
	@echo "🔄 Ansible 플레이북으로 $(SERVER) 서버의 Nexus 노드를 재시작합니다..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)restart.yml --limit $(SERVER) --forks 10 --timeout 300

# 고급 배포 옵션 (더 빠른 배포)
.PHONY: deploy-fast
deploy-fast:
	@echo "⚡ 고속 Nexus 배포를 시작합니다 (20개 병렬 처리)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)nexus.yml --forks 20 --timeout 180

# 배치 배포 (서버 그룹별로 배포)
.PHONY: deploy-batch
deploy-batch:
	@echo "📦 배치 배포를 시작합니다 (5개씩 그룹 처리)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)nexus.yml --forks 5 --timeout 300
