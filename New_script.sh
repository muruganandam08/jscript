# Set variables
SONAR_HOST_URL="http://localhost:9000"  # Replace with your SonarQube server URL
SONAR_AUTH_TOKEN="YOUR_SONAR_AUTH_TOKEN"  # Replace with your SonarQube authentication token
QUALITY_PROFILE_NAME="Custom Quality Profile"
LANGUAGE="java"

# Create a new quality profile
create_profile_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/create" \
  -d "language=$LANGUAGE" \
  -d "name=$QUALITY_PROFILE_NAME")

profile_key=$(echo $create_profile_response | jq -r '.profile.key')

if [ "$profile_key" == "null" ]; then
  echo "Failed to create quality profile. Response: $create_profile_response"
  exit 1
fi

echo "Created quality profile '$QUALITY_PROFILE_NAME' with key: $profile_key"

# Fetch all rules for the specified language
rules_response=$(curl -s -u $SONAR_AUTH_TOKEN: "$SONAR_HOST_URL/api/rules/search?languages=$LANGUAGE&ps=500")

# Extract rule keys from the response
rule_keys=$(echo $rules_response | jq -r '.rules[].key')

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




≈===========≈==========≡

# Variables for SonarQube and profile creation
SONAR_HOST_URL="http://localhost:9000"
SONAR_AUTH_TOKEN="YOUR_SONAR_AUTH_TOKEN"
QUALITY_PROFILE_NAME="New_Custom_Quality_Profile"
LANGUAGE="java"

# Step 1: Create a quality profile and sanitize the response
create_profile_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/create" \
  -d "language=$LANGUAGE" \
  -d "name=$QUALITY_PROFILE_NAME" | sed 's/[\x00-\x1F\x7F]//g')

# Log raw response (optional for debugging)
echo "Create Profile Response: $create_profile_response" > create_profile_response.log

# Step 2: Extract profile key using jq with error handling
profile_key=$(echo "$create_profile_response" | jq -r '.profile.key // empty')

# Check if the profile key was successfully extracted
if [ -z "$profile_key" ]; then
  echo "Failed to create quality profile or retrieve the key. Response logged in create_profile_response.log"
  exit 1
fi
echo "Created quality profile '$QUALITY_PROFILE_NAME' with key: $profile_key"

# Step 3: Fetch all rules for the specified language and sanitize the response
rules_response=$(curl -s -u $SONAR_AUTH_TOKEN: "$SONAR_HOST_URL/api/rules/search?languages=$LANGUAGE&ps=500" | sed 's/[\x00-\x1F\x7F]//g')

# Optional debugging: Log the raw response
echo "Rules Response: $rules_response" > rules_response.log

# Step 4: Extract rule keys and handle any potential parsing errors
rule_keys=$(echo "$rules_response" | jq -r '.rules[].key // empty')

# Step 5: Activate each rule in the quality profile, with error handling
for rule_key in $rule_keys; do
  activate_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/activate_rule" \
    -d "rule=$rule_key" \
    -d "key=$profile_key" \
    -d "severity=MAJOR")  # Adjust severity as needed

  # Check if activation was successful
  if echo "$activate_response" | grep -q '"errors"'; then
    echo "Failed to activate rule $rule_key. Response: $activate_response"
  else
    echo "Activated rule $rule_key for quality profile '$QUALITY_PROFILE_NAME'"
  fi
done


≈=======================


# Variables for SonarQube and profile creation
SONAR_HOST_URL="http://localhost:9000"
SONAR_AUTH_TOKEN="YOUR_SONAR_AUTH_TOKEN"
QUALITY_PROFILE_NAME="New_Custom_Quality_Profile"
LANGUAGE="java"

# Step 1: Create a quality profile and further clean the response
create_profile_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/create" \
  -d "language=$LANGUAGE" \
  -d "name=$QUALITY_PROFILE_NAME" | tr -d '\r\n' | sed 's/[\x00-\x1F\x7F]//g' | sed 's/\\/\\\\/g')

# Log raw response (optional for debugging)
echo "Create Profile Response: $create_profile_response" > create_profile_response.log

# Step 2: Check if JSON is valid and extract profile key
if echo "$create_profile_response" | jq empty > /dev/null 2>&1; then
  profile_key=$(echo "$create_profile_response" | jq -r '.profile.key // empty')
else
  echo "Error: Invalid JSON response. Check create_profile_response.log for details."
  exit 1
fi

# Check if the profile key was successfully extracted
if [ -z "$profile_key" ]; then
  echo "Failed to create quality profile or retrieve the key. Response logged in create_profile_response.log"
  exit 1
fi
echo "Created quality profile '$QUALITY_PROFILE_NAME' with key: $profile_key"

# Step 3: Fetch all rules for the specified language and sanitize the response
rules_response=$(curl -s -u $SONAR_AUTH_TOKEN: "$SONAR_HOST_URL/api/rules/search?languages=$LANGUAGE&ps=500" \
  | tr -d '\r\n' | sed 's/[\x00-\x1F\x7F]//g' | sed 's/\\/\\\\/g')

# Optional debugging: Log the raw response
echo "Rules Response: $rules_response" > rules_response.log

# Step 4: Check if JSON is valid and extract rule keys
if echo "$rules_response" | jq empty > /dev/null 2>&1; then
  rule_keys=$(echo "$rules_response" | jq -r '.rules[].key // empty')
else
  echo "Error: Invalid JSON response for rules. Check rules_response.log for details."
  exit 1
fi

# Step 5: Activate each rule in the quality profile, with error handling
for rule_key in $rule_keys; do
  activate_response=$(curl -s -u $SONAR_AUTH_TOKEN: -X POST "$SONAR_HOST_URL/api/qualityprofiles/activate_rule" \
    -d "rule=$rule_key" \
    -d "key=$profile_key" \
    -d "severity=MAJOR")  # Adjust severity as needed

  # Check if activation was successful
  if echo "$activate_response" | grep -q '"errors"'; then
    echo "Failed to activate rule $rule_key. Response: $activate_response"
  else
    echo "Activated rule $rule_key for quality profile '$QUALITY_PROFILE_NAME'"
  fi
done
