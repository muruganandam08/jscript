#!/bin/bash

# Set variables
SONARQUBE_URL="https://your-sonarqube-server.com"
SONARQUBE_TOKEN="your_sonarqube_token"  # Replace with your actual SonarQube token
LANGUAGE="java"  # Specify the language for the quality profile
QUALITY_PROFILE_NAME="Custom_Quality_Profile"  # Name for the quality profile

# Step 1: Create Quality Profile
echo "Creating quality profile '$QUALITY_PROFILE_NAME' for language '$LANGUAGE'..."
create_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SONARQUBE_URL/api/qualityprofiles/create" \
    -u "$SONARQUBE_TOKEN:" \
    -d "language=$LANGUAGE&name=$QUALITY_PROFILE_NAME")

if [ "$create_response" -eq 200 ]; then
    echo "Quality profile '$QUALITY_PROFILE_NAME' created successfully."
elif [ "$create_response" -eq 400 ]; then
    echo "Quality profile '$QUALITY_PROFILE_NAME' already exists."
else
    echo "Failed to create quality profile. HTTP Status: $create_response"
    exit 1
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
    activate_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SONARQUBE_URL/api/qualityprofiles/activate_rule" \
        -u "$SONARQUBE_TOKEN:" \
        -d "rule=$rule&qualityProfile=$QUALITY_PROFILE_NAME&language=$LANGUAGE")
    if [ "$activate_response" -eq 200 ]; then
        echo "Activated rule: $rule"
    else
        echo "Failed to activate rule: $rule, HTTP Status: $activate_response"
    fi
done

echo "All rules activated for quality profile '$QUALITY_PROFILE_NAME'."
