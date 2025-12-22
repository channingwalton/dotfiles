#!/bin/bash
# Polls Tesla Wall Connector vitals API and logs to CSV

LOG_FILE="$HOME/Desktop/wallcharger.csv"
API_URL="http://192.168.178.38/api/1/vitals"
INTERVAL=10

# Write header if file doesn't exist
if [[ ! -f "$LOG_FILE" ]]; then
    echo "timestamp,contactor_closed,vehicle_connected,session_s,grid_v,grid_hz,vehicle_current_a,currentA_a,currentB_a,currentC_a,currentN_a,voltageA_v,voltageB_v,voltageC_v,relay_coil_v,pcba_temp_c,handle_temp_c,mcu_temp_c,uptime_s,input_thermopile_uv,prox_v,pilot_high_v,pilot_low_v,session_energy_wh,config_status,evse_state,current_alerts,evse_not_ready_reasons" > "$LOG_FILE"
fi

echo "Logging to $LOG_FILE every ${INTERVAL}s (Ctrl+C to stop)"

while true; do
    json=$(curl -s "$API_URL")
    if [[ -n "$json" ]]; then
        timestamp=$(date -Iseconds)
        csv=$(echo "$json" | jq -r --arg ts "$timestamp" '
            [$ts,
             .contactor_closed,
             .vehicle_connected,
             .session_s,
             .grid_v,
             .grid_hz,
             .vehicle_current_a,
             .currentA_a,
             .currentB_a,
             .currentC_a,
             .currentN_a,
             .voltageA_v,
             .voltageB_v,
             .voltageC_v,
             .relay_coil_v,
             .pcba_temp_c,
             .handle_temp_c,
             .mcu_temp_c,
             .uptime_s,
             .input_thermopile_uv,
             .prox_v,
             .pilot_high_v,
             .pilot_low_v,
             .session_energy_wh,
             .config_status,
             .evse_state,
             (.current_alerts | join(";")),
             (.evse_not_ready_reasons | join(";"))]
            | @csv')
        echo "$csv" >> "$LOG_FILE"
    fi
    sleep "$INTERVAL"
done
