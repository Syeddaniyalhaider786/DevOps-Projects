
#!/bin/bash

# === CONFIGURATION ===
SERVICES=(
  notification-broker-services
  receiving-services
  rest-handler-cas
  rest-handler-Host
  rest-handler-inquiry
  rest-handler-MX
  rest-handler-payment
  rest-handler-payment-async
)

LOG_BASE="/apps/logs"
SLEEP_INTERVAL=10  # seconds to wait before rechecking when file not found

# === FUNCTION TO MONITOR ONE SERVICE ===

# === CLEAN EXIT ON CTRL+C ===

trap 'echo "[INFO] Stopping monitoring..."; pkill -P $$; exit' SIGINT

monitor_service() {
  local service=$1
  local service_log_dir="$LOG_BASE/$service"
  local last_file=""
  local tail_pid=0

  while true; do
    current_file="$service_log_dir/application.$(date '+%Y-%m-%d_%H').log"

    if [[ "$current_file" != "$last_file" ]]; then
      if [[ -f "$current_file" ]]; then
        echo -e "\n[$(date)] [INFO] Now monitoring $service => $current_file"
        last_file="$current_file"

        # Kill previous tail process if still running
        if [[ $tail_pid -ne 0 ]]; then
          kill $tail_pid 2>/dev/null
        fi

        # Start tail with colored service name + timestamp
        # Start tail with colored service name + timestamp
(
  tail -n 0 -F "$current_file" | \
  grep --line-buffered 'Exception' | \
  grep --line-buffered -Ev 'com\.microsoft\.sqlserver\.jdbc\.SQLServerException: The connection is closed|at com\.microsoft\.sqlserver\.jdbc\.SQLServerException\.makeFromDriverError' | \
          grep --color=always --line-buffered 'Exception' | \
          awk -v s="$service" 'BEGIN {
              GREEN = "\033[0;32m"
              RESET = "\033[0m"
          }
          {
              cmd = "date +\"%Y-%m-%d %H:%M:%S\""
              cmd | getline d
              close(cmd)
              print GREEN "[" s "]" RESET " [" d "] " $0
          }'
        ) &
         tail_pid=$!

        # Sleep until next hour
        sleep_time=$(( (60 - $(date +%M)) * 60 ))
        sleep $sleep_time

        kill $tail_pid 2>/dev/null
      else
        echo "[$(date)] [WARN] Log file not found for $service: $current_file"
        sleep $SLEEP_INTERVAL
      fi
    else
      sleep $SLEEP_INTERVAL
    fi
  done
}

# === START ALL SERVICES ===
for svc in "${SERVICES[@]}"; do
  monitor_service "$svc" &
done

wait
