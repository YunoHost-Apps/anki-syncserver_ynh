#!/bin/bash

gen_sync_user() {
    local n
    n="$1"
    local value
    value="$2"
    local pwd
    pwd="$(ynh_app_setting_get --app=$app --key=sync_password_${n})"

    if [ -n "$value" ]; then
        echo "SYNC_USER${n}=${value}:${pwd}" 
    else
        echo "#SYNC_USER${n}="
    fi
}

gen_max_sync_payload() {
    local value
    value="$1"


    if [ -n "$value" ]; then
        echo "Environment=\"MAX_SYNC_PAYLOAD_MEGS=${value}\""
    else
        echo "#Environment=\"MAX_SYNC_PAYLOAD_MEGS=\""
    fi
}

# Configure systemd service with environment variables
configure_systemd_service() {
    sync_user_1=$(ynh_app_setting_get --app=$app --key=sync_user_1)
    sync_user_2=$(ynh_app_setting_get --app=$app --key=sync_user_2)
    sync_user_3=$(ynh_app_setting_get --app=$app --key=sync_user_3)
    sync_user_4=$(ynh_app_setting_get --app=$app --key=sync_user_4)
    sync_user_5=$(ynh_app_setting_get --app=$app --key=sync_user_5)
    max_sync_payload_megs=$(ynh_app_setting_get --app=$app --key=max_sync_payload_megs)

    sync_line_1=$(gen_sync_user "1" "$sync_user_1")
    sync_line_2=$(gen_sync_user "2" "$sync_user_2")
    sync_line_3=$(gen_sync_user "3" "$sync_user_3")
    sync_line_4=$(gen_sync_user "4" "$sync_user_4")
    sync_line_5=$(gen_sync_user "5" "$sync_user_5")
    max_sync_payload_megs=$(gen_max_sync_payload "$max_sync_payload_megs")

    ynh_add_config --template="env" --destination="$install_dir/.env.systemd"
    chown $app:$app "$install_dir/.env.systemd"
    chmod 600 "$install_dir/.env.systemd"

    ynh_add_systemd_config
}


function password_hash() {
    retval=$(python3 -c "import sys; import hashlib; import secrets; import base64; salt=secrets.token_bytes(32); print(f\"\$pbkdf2-sha256\$i=100000\${base64.b64encode(salt).decode('utf-8').rstrip('=')}\${base64.b64encode(hashlib.pbkdf2_hmac('sha256',sys.argv[1].encode('utf-8'),salt,100_000)).decode('utf-8').rstrip('=')}\")" "$1")
    echo $retval
}