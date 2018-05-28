#!/bin/bash 


printf "\n\n\nExecuting within the container...\n\n"

# environment variables set by "docker run -e .."
# CONJUR_AUTHN_LOGIN - Conjur Login ID
# CONJUR_AUTHN_API_KEY - Conjur API Key
# CONJUR_APPLIANCE_URL - Conjur Appliance URL
# CONJUR_ACCOUNT - Conjur Account name
# CONJUR_SSL_CERTIFICATE - Conjur public certificate
# CONJUR_VARIABLE - Variable to pull from conjur
# SLEEP_TIME - The amount of time between password pulls

function urlify(){
  local str=$1; shift
  str=$(echo $str | sed 's= =%20=g')
  str=$(echo $str | sed 's=/=%2F=g')
  str=$(echo $str | sed 's=:=%3A=g')
  URLIFIED=$str
}

$secret_name=$(urlify $CONJUR_VARIABLE)
declare LOGFILE=cc.log

# for logfile to see whats going on
touch $LOGFILE

while [ 1=1 ]; do
	# Login container w/ its API key, authenticate and get API key for session
	hostname=host%2F$CONJUR_AUTHN_LOGIN
	response=$(curl -s -k \
	 --request POST \
	 --data-binary $CONJUR_AUTHN_API_KEY \
	 $CONJUR_APPLIANCE_URL/authn/$CONJUR_ACCOUNT/$hostname/authenticate)
	CONT_SESSION_TOKEN=$(echo -n $response| base64 | tr -d '\r\n')

#echo "CONT_SESSION_TOKEN: " $CONT_SESSION_TOKEN >> $LOGFILE

	# FETCH variable value
	secret=$(curl -s -k \
         --request GET \
         -H "Content-Type: application/json" \
         -H "Authorization: Token token=\"$CONT_SESSION_TOKEN\"" \
         $CONJUR_APPLIANCE_URL/secrets/$CONJUR_ACCOUNT/variable/$secret_name)

  	echo $(date) "The DB Password is: " $secret >> $LOGFILE
	sleep $SLEEP_TIME 
done

exit

