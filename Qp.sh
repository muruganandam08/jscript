#!/bin/bash

# Set variables
SONARQUBE_URL="https://your-sonarqube-server.com"
SONARQUBE_TOKEN="your_sonarqube_token"
LANGUAGE="java"
QUALITY_PROFILE_NAME="Custom_Quality_Profile"

# Step 1: Fetch the profile key for the quality profile
echo "Fetching profile key for '$QUALITY_PROFILE_NAME'..."
profile_key=$(curl -s -X GET "$SONARQUBE_URL/api/qualityprofiles/search" \
    -u "$SONARQUBE_TOKEN:" \
    -d "language=$LANGUAGE" | jq -r ".profiles[] | select(.name == \"$QUALITY_PROFILE_NAME\") | .key")

if [ -z "$profile_key" ]; then
    echo "Error: Failed to retrieve profile key for '$QUALITY_PROFILE_NAME' in language '$LANGUAGE'."
    exit 1
else
    echo "Profile key for '$QUALITY_PROFILE_NAME': $profile_key"
fi

# Step 2: Fetch all rules for the specified language
echo "Fetching all rules for language '$LANGUAGE'..."
rules=$(curl -s -X GET "$SONARQUBE_URL/api/rules/search?languages=$LANGUAGE&p=1&ps=500" \
    -u "$SONARQUBE_TOKEN:" | jq -r '.rules[].key')

if [ -z "$rules" ]; then
    echo "No rules found for language '$LANGUAGE'. Exiting."
    exit 1
fi

# Step 3: Activate each rule in the quality profile
echo "Activating rules for quality profile '$QUALITY_PROFILE_NAME'..."
for rule in $rules; do
    activate_response=$(curl -s -X POST "$SONARQUBE_URL/api/qualityprofiles/activate_rule" \
        -u "$SONARQUBE_TOKEN:" \
        -d "rule=$rule&targetKey=$profile_key&language=$LANGUAGE")

    echo "Activate rule response for $rule: $activate_response"
    if echo "$activate_response" | grep -q "\"errors\""; then
        echo "Failed to activate rule: $rule. Response: $activate_response"
    else
        echo "Activated rule: $rule"
    fi
done

echo "All rules activated for quality profile '$QUALITY_PROFILE_NAME'."
