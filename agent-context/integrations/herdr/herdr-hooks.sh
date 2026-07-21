# pyobox Herdr integration settings
# Mirrors ~/.claude/hooks/herdr-agent-state.sh pattern

# Herdr session hook — reports agent state to Herdr daemon
# Installed by pyobox; managed by pyobox; reinstalling overwrites this file.
# Add custom hooks beside this file instead of editing it.

herdr_report_session() {
  local action="${1:-session}"
  local pane_id="${HERDR_PANE_ID:-}"
  local socket_path="${HERDR_SOCKET_PATH:-}"

  [ "${HERDR_ENV:-}" = "1" ] || return 0
  [ -n "$pane_id" ] || return 0
  [ -n "$socket_path" ] || return 0
  command -v python3 >/dev/null 2>&1 || return 0

  python3 -c "
import json, os, socket, time, random
pane_id = os.environ.get('HERDR_PANE_ID', '')
socket_path = os.environ.get('HERDR_SOCKET_PATH', '')
if not pane_id or not socket_path:
    raise SystemExit(0)
request = {
    'id': f'pyobox:{int(time.time()*1000)}:{random.randrange(1000000):06d}',
    'method': 'pane.report_agent_session',
    'params': {
        'pane_id': pane_id,
        'source': 'pyobox',
        'agent': 'pyobox',
        'seq': time.time_ns(),
        'agent_session_id': os.environ.get('PYOBOX_SESSION', str(time.time())),
    }
}
try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(0.5)
    s.connect(socket_path)
    s.sendall((json.dumps(request) + '\n').encode())
    s.close()
except Exception:
    pass
" 2>/dev/null || true
}
