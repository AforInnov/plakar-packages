#!/bin/sh
# Snapshot /staging into an encrypted plakar store once at start, then every day at BACKUP_TIME
# UTC. BACKUP_PREPARE is the app-specific shell command that fills /staging.
set -eu

: "${BACKUP_TIME:=01:30}" "${PLAKAR_KEEP:=90d}" "${CRONITOR_API_KEY:=}" "${CRONITOR_MONITOR:=}"

# A restarted container keeps its store list, so the entry is replaced.
plakar store rm backups > /dev/null 2>&1 || true
plakar store add backups "$STORE" \
  access_key="$BACKUP_S3_ACCESS_KEY" secret_access_key="$BACKUP_S3_SECRET_KEY"
plakar at @backups ls > /dev/null 2>&1 || plakar at @backups create

beat() {
  [ -n "$CRONITOR_API_KEY" ] && [ -n "$CRONITOR_MONITOR" ] || return 0
  curl -fsS -m 10 -o /dev/null -G --data-urlencode "state=$1" \
    "https://cronitor.link/p/$CRONITOR_API_KEY/$CRONITOR_MONITOR" || true
}

backup() {
  rm -rf /staging
  mkdir /staging
  sh -c "$BACKUP_PREPARE"
  plakar at @backups backup /staging
  plakar at @backups rm -before "$PLAKAR_KEEP" -apply
}

# set -e is off inside an if condition, so the subshell status is read after it runs.
run() {
  beat run
  set +e
  (set -e; backup)
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then beat complete; else beat fail; fi
}

run
while :; do
  now=$(date -u +%s)
  next=$(date -u -d "$(date -u +%Y-%m-%d) $BACKUP_TIME" +%s)
  if [ "$next" -le "$now" ]; then next=$((next + 86400)); fi
  sleep $((next - now))
  run
done
