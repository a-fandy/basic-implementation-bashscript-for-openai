#!/bin/bash

# chatgpt.sh
# This script interacts with the OpenAI API using specified parameters.

# Prerequisites:
# - An OpenAI API key set as an environment variable (OPENAI_API_KEY).
# - The `jq` JSON processor must be installed.
# - Internet connectivity to reach the OpenAI API.

# Usage:
# ./chatgpt.sh -p "Your message here" [-t "Type"] [-m "Model"] [-s "User Session"] [-f "file uplaod"] [-a "assistant"] 

function usage() {
    echo "Usage: $0 -p \"Your message here\" [-t \"Type\"] [-m \"Model\"] [-s \"User Session\"] [-f \"file upload\"] [-a \"assistant\"] [-h]"
    echo
    echo "Options:"
    echo "  -p \"Your message here\"    Required. The prompt message to send to the API."
    echo "  -t \"Type\"                 Optional. The type of interaction (default is 1)."
    echo "  -m \"Model\"                Optional. Specify the model to use (default is gpt-4o)."
    echo "  -s \"User Session\"         Optional. A session identifier for tracking history."
    echo "  -f \"file upload\"          Optional. A file to upload, used with types 2 and 3."
    echo "  -a \"assistant\"            Optional. Set the assistant's initial message."
    echo "  -h                        Display this help message."
    echo
    echo "Example:"
    echo "  $0 -p \"Hello, how are you?\" -t 1"
    exit 0
}

# Determine the directory of the current script
script_dir="$(dirname "$(realpath "$0")")"

# The directory to store history files
history_filename="$script_dir/history-chat"

# Initialize variables
type=1                          # Default type
model="gpt-4o"                  # Default model
# model="gpt-4.1-mini" 
user_session=""
message=""
file_upload=""
assistant="You are a helpful assistant."

# Make sure OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY is not set."
    exit 1
fi

# Parse arguments
while getopts ":t:m:p:s:f:a:h" opt; do
    case ${opt} in
    h)
        usage
        ;;
    t)
        type=$OPTARG
        ;;
    m)
        model=$OPTARG
        ;;
    p)
        message=$OPTARG
        ;;
    s)
        user_session=$OPTARG
        ;;
    f)
        file_upload=$OPTARG
        ;;
    a)
        assistant=$OPTARG
        ;;
    \?)
        echo "Invalid option: -$OPTARG" 1>&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." 1>&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# Ensure a prompt is provided
if [ -z "$message" ]; then
    echo "Error: Please provide a message with -p option."
    exit 1
fi

if [ -z "$user_session" ]; then
    HISTORY_FILE="$history_filename.json"
else
    HISTORY_FILE="$history_filename-$user_session.json"
fi

# Create history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
    echo "[]" >"$HISTORY_FILE"
    assis_mode=$(jq --arg msg "$assistant" '. += [{"role":"system", "content":$msg}]' "$HISTORY_FILE")
    echo "$assis_mode" >"$HISTORY_FILE"
fi

# Function to read contents of a file
read_file_content() {
    cat "$1"
}

# Display the provided arguments
echo "Type: $type"
echo "Model: $model"
echo "Prompt: $message"
echo "User Session: $user_session"
echo "History File: $HISTORY_FILE"
echo "File upload: $file_upload"
echo "assistant: $assistant"

# exit 1

# Get content based on user choice
case $type in
1)
    prompt="$message"
    ;;
2)
    if [ -z "$file_upload" ]; then
        echo "no file uploaded"
        exit 1
    fi
    prompt="$message \n$(read_file_content "$file_upload")"
    ;;
3)
    prompt="$message"
    if [ -z "$file_upload" ]; then
        echo "no file uploaded"
        exit 1
    fi
    image_data=$(base64 -w 0 "$file_upload")
    ;;
*)
    echo "Invalid option type"
    exit 1
    ;;
esac

# Add GPT Query logic here
if [ "$type" != "3" ]; then
    # Add user's message to history
    body=$(jq --arg msg "$prompt" '. += [{"role":"user", "content":$msg}]' "$HISTORY_FILE")
    # body=$(echo "$tmp_history" | jq --arg msg "$assistant" '. += [{"role":"system", "content":$msg}]')
    json_payload=$(
    cat <<EOF
        {
        "model": "$model",
        "tools": [{"type": "web_search_preview"}],
        "input": $(echo "$body")
        }
EOF
    )
else
    body=$(jq \
    --arg msg "$prompt" \
    --arg img "$image_data" \
    '. += [{
        "role": "user",
        "content": [
        { "type": "input_text", "text": $msg },
        { "type": "input_image", "image_url": ("data:image/jpeg;base64,"+$img) }
        ]
    }]' "$HISTORY_FILE")
    # echo $body
    # exit 0
    # body=$(echo "$tmp_history" | jq --arg msg "$assistant" '. += [{"role":"system", "content":$msg}]')
    json_payload=$(
        cat <<EOF
        {
        "model": "$model",
        "tools": [{"type": "web_search_preview"}],
        "input": $(echo "$body")
        }
EOF
    )
fi

# Call OpenAI API via curl
response_raw=$(curl https://api.openai.com/v1/responses \
    -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$json_payload")

# echo "$response_raw"

response=$(echo "$response_raw" | jq -r '.output [] | select(.type == "message") | .content[0].text')
echo -e "\n$response\n"


if [ "$response" != "null" ]; then
    echo "$body" | jq --arg msg "$response" '. += [{"role":"assistant", "content":$msg}]' >"$HISTORY_FILE"
fi

exit 0
