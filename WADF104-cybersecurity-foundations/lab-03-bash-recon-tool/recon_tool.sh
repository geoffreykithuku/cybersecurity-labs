#!/usr/bin/env bash

echo "ICDFA Beginner Reconnaissance Tool"
echo "---------------------------------"
echo "Use only against authorised lab targets."
echo

read -rp "Enter authorised target IP address or domain: " target

echo "Target entered: $target"

if [[ -z "$target" ]]; then
    echo "Error: no target was entered."
    exit 1
fi

echo
echo "Select a reconnaissance tool:"
echo "1) WhatWeb"
echo "2) Nmap"
echo "3) DIRB"
echo "4) Exit"
read -rp "Enter your choice [1-4]: " choice

# REMOVED THE TEST CASE HERE

check_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required tool '$1' is not installed or not in PATH."
        exit 1
    fi
}

case "$choice" in
    1)
        check_tool whatweb
        echo "[+] Running WhatWeb against $target"
        whatweb "http://$target"
        ;;
    2)
        check_tool nmap
        echo "[+] Running Nmap service detection against $target"
        nmap -sV "$target"
        ;;
    3)
        check_tool dirb
        echo "[+] Running DIRB against $target"
        dirb "http://$target"
        ;;
    4)
        echo "Exiting. No scan was run."
        exit 0
        ;;
    *)
        echo "Error: invalid menu choice."
        exit 1
        ;;
esac