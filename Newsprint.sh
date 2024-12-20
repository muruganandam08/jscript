# Set variables
SONAR_HOST_URL="http://localhost:9000"  # Replace with your SonarQube server URL
SONAR_AUTH_TOKEN="YOUR_SONAR_AUTH_TOKEN"  # Replace with your SonarQube authentication token
QUALITY_PROFILE_NAME="New_Custom Quality Profile"
LANGUAGE="java"

# Create a new quality profile and escape any control characters in the response
create_profile_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/create" \
  -d "language=$LANGUAGE" \
  -d "name=$QUALITY_PROFILE_NAME" | sed 's/[\x00-\x1F\x7F]//g')

# Debug: Print the raw response
echo "Raw create profile response: $create_profile_response"

# Extract profile key
profile_key=$(echo $create_profile_response | jq -r '.profile.key')

if [ "$profile_key" == "null" ]; then
  echo "Failed to create quality profile. Response: $create_profile_response"
  exit 1
fi

echo "Created quality profile '$QUALITY_PROFILE_NAME' with key: $profile_key"

# Fetch all rules for the specified language
rules_response=$(curl -s -u $SONAR_AUTH_TOKEN: "$SONAR_HOST_URL/api/rules/search?languages=$LANGUAGE&ps=500")

# Debug: Print the raw rules response
echo "Raw rules response: $rules_response"

# Extract rule keys from the response, escaping any control characters
rule_keys=$(echo "$rules_response" | sed 's/[\x00-\x1F\x7F]//g' | jq -r '.rules[].key')

# Activate each rule in the quality profile
for rule_key in $rule_keys; do
  activate_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/activate_rule" \
    -d "rule=$rule_key" \
    -d "key=$profile_key" \
    -d "severity=MAJOR")  # Set severity level as desired

  # Check for errors in the activation response
  if echo "$activate_response" | grep -q '"errors"'; then
    echo "Failed to activate rule $rule_key. Response: $activate_response"
  else
    echo "Activated rule $rule_key for quality profile '$QUALITY_PROFILE_NAME'"
  fi
done
