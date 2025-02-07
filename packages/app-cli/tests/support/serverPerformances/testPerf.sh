#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../../../../.."

COMMANDS=($(echo $1 | tr "," "\n"))
PROFILE_DIR=~/.config/joplindev-testperf

CMD_FILE="$SCRIPT_DIR/testPerfCommands.txt"
rm -f "$CMD_FILE"
touch "$CMD_FILE"

for CMD in "${COMMANDS[@]}"
do
    if [[ $CMD == "createUsers" ]]; then

		curl --data '{"action": "createTestUsers"}' -H 'Content-Type: application/json' http://api.joplincloud.local:22300/api/debug

	# elif [[ $CMD == "createData" ]]; then
		
	# 	echo 'mkbook "shared"' >> "$CMD_FILE"
	# 	echo 'mkbook "other"' >> "$CMD_FILE"
	# 	echo 'use "shared"' >> "$CMD_FILE"
	# 	echo 'mknote "note 1"' >> "$CMD_FILE"
	# 	echo 'mknote "note 2"' >> "$CMD_FILE"
	
	elif [[ $CMD == "reset" ]]; then
	
		USER_EMAIL="user1@example.com"
		rm -rf "$PROFILE_DIR"
		echo "config keychain.supported 0" >> "$CMD_FILE" 
		echo "config sync.target 9" >> "$CMD_FILE" 
		echo "config sync.9.path http://api.joplincloud.local:22300" >> "$CMD_FILE" 
		echo "config sync.9.username $USER_EMAIL" >> "$CMD_FILE" 
		echo "config sync.9.password 123456" >> "$CMD_FILE" 
	
	# elif [[ $CMD == "e2ee" ]]; then
	
	# 	echo "e2ee enable --password 111111" >> "$CMD_FILE" 
	
	else
	
		echo "Unknown command: $CMD"
		exit 1
	
	fi
done

cd "$ROOT_DIR/packages/app-cli"
npm start -- --profile "$PROFILE_DIR" batch "$CMD_FILE"
npm start -- --profile "$PROFILE_DIR" import ~/Desktop/Joplin_17_06_2021.jex
npm start -- --profile "$PROFILE_DIR" sync

