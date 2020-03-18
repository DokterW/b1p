#!/bin/bash
# b1p v0.2
# Made by Dr. Waldijk
# Convert Bitwarden JSON to 1Password CSV.
# Read the README.md for more info.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
B1PNAM="b1p"
B1PVER="0.2"
B1PFIL=$1
B1PFLD=$2
# Dependencies ----------------------------------------------------------------------
if [ ! -e /usr/bin/jq ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install jq
    elif [[ "$FNUOSD" = "ubuntu" ]]; then
        sudo apt install jq
    else
        echo "You need to install jq."
        exit
    fi
fi
# Functions -------------------------------------------------------------------------
website() {
    B1PNULL=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].login.uris[0].uri")
    if [[ "$B1PNULL" != "null" ]]; then
        echo "$B1PJSN" | jq -r ".items[$B1PCNTX].login.uris[0].uri"
    else
        B1PWEBSITE=""
    fi
}
notes() {
    B1PNULL=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].notes")
    if [[ "$B1PNULL" != "null" ]]; then
        echo "$B1PJSN" | jq -r ".items[$B1PCNTX].notes"
    else
        B1PNOTES=""
    fi
    B1PNULL=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].fields[0].value")
    if [[ "$B1PNULL" != "null" ]]; then
        B1PLIN=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].fields[].name" | wc -l)
        # B1PLIN=$(expr $B1PLIN - 1)
        B1PCNT=0
        if [[ "$B1PLIN" != "0" ]]; then
            echo "----------------"
            until [[ "$B1PCNT" = "$B1PLIN" ]]; do
                echo "$B1PJSN" | jq -r ".items[$B1PCNTX].fields[$B1PCNT].name"
                echo "$B1PJSN" | jq -r ".items[$B1PCNTX].fields[$B1PCNT].value"
                B1PCNT=$(expr $B1PCNT + 1)
            done
        fi
    else
        B1PNOTES=""
    fi
}
folder() {
    if [[ -n "$B1PFLD" ]]; then
        B1PLIN=$(echo "$B1PJSN" | jq -r '.folders[].id' | wc -l)
        # B1PLIN=$(expr $B1PLIN - 1)
        B1PCNT=0
        until [[ "$B1PCNT" = "$B1PLIN" ]]; do
            B1PTST=$(echo "$B1PJSN" | jq -r ".folders[$B1PCNT].name")
            if [[ "$B1PTST" = "$B1PFLD" ]]; then
                B1PFID=$(echo "$B1PJSN" | jq -r ".folders[$B1PCNT].id")
            fi
            B1PCNT=$(expr $B1PCNT + 1)
        done
    fi
}
# -----------------------------------------------------------------------------------
if [[ -n "$B1PFIL" ]]; then
    if [[ "$B1PFLD" = "list-folders" ]]; then
        cat $B1PFIL | jq -r '.folders[].name'
    else
        B1PJSN=$(cat $B1PFIL)
        folder
        B1PLINX=$(echo "$B1PJSN" | jq -r '.items[].name' | wc -l)
        # B1PLIN=$(expr $B1PLIN - 1)
        B1PCNTX=0
        if [[ "$B1PLINX" != "0" ]]; then
            until [[ "$B1PCNTX" = "$B1PLINX" ]]; do
                if [[ -z "$B1PFID" ]] || [[ "$B1PFID" = "All" ]]; then
                    B1PFID="All"
                    B1PFIT="All"
                    if [[ -z "$B1PFLD" ]]; then
                        B1PFLD="All"
                    fi
                else
                    B1PFIT=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].folderId")
                fi
                if [[ "$B1PFIT" = "$B1PFID" ]]; then
                    echo "$B1PJSN" | jq -r ".items[$B1PCNTX].name"
                    B1PTITLE=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].name")
                    B1PWEBSITE=$(website)
                    B1PNULL=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].login.username")
                    if [[ "$B1PNULL" != "null" ]]; then
                        B1PUSERNAME=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].login.username")
                    else
                        B1PUSERNAME=""
                    fi
                    B1PNULL=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].login.password")
                    if [[ "$B1PNULL" != "null" ]]; then
                        B1PPASSWORD=$(echo "$B1PJSN" | jq -r ".items[$B1PCNTX].login.password")
                    else
                        B1PPASSWORD=""
                    fi
                    B1PNOTES=$(notes)
                    # https://support.1password.com/create-csv-files/
                    if [[ -z "$B1PNOTES" ]]; then
                        echo "$B1PTITLE,$B1PWEBSITE,$B1PUSERNAME,$B1PPASSWORD" >> $B1PFLD.csv
                    else
                        echo "$B1PTITLE,$B1PWEBSITE,$B1PUSERNAME,$B1PPASSWORD,\"$B1PNOTES\"" >> $B1PFLD.csv
                    fi
                    B1PTITLE=""
                    B1PWEBSITE=""
                    B1PUSERNAME=""
                    B1PPASSWORD=""
                    B1PNOTES=""
        #            echo "$B1PTITLE"
                fi
                B1PCNTX=$(expr $B1PCNTX + 1)
            done
        fi
    fi
else
    echo "$B1PNAM v$B1PVER"
    echo ""
    echo "b1p <file> <folder>"
fi
