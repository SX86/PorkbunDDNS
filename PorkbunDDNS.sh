#!/bin/bash
# # PorkbunDDNS
# This script can be used to check and update your Porkbun DNS "A" records to the IP address of your current external IP.
#
# ## INSTRUCTIONS ##
#
# ### Setting up variables
# First, retrieve record IDs by running the following command, replacing the key for both "secretapikey" and "apikey" as well as "example.com" in the URL at the end of the command:
#
#     curl --header "Content-Type: application/json" --request POST --data '{"secretapikey": "key","apikey": "key"}' https://porkbun.com/api/json/v3/dns/retrieve/example.com/
#
# Looking at the output of the command, look for the "id":"#########" string for each of the record you want this script to update.
# Replace the data in the variables at the start of the file to match your findings.
#
#
# ### Setting up crontab
# Run 
#     crontab -e
# and add 
#     0 0 * * * bash /path/to/script/PorkbunDDNS.sh```. This will run the script daily at midnight.
#
# Ensure that the script is executable by running  chmod +x /path/to/script/PorkbunDDNS.sh to modify its permissions.
#
#
# ## Porkbun API reference documentation :
# https://porkbun.com/api/json/v3/documentation
#
# ## Generate your API keys here :
# https://porkbun.com/account/api
#

### IMPORTANT !!! ###
# Update the following variables :
SECRET="secretkey"    # secret for porkbun API
KEY="apikey"    # key for porkbun API
DOMAIN="domain"    # domain name to update
ROOT_A_RECORD_ID="000000000"    # root of domain record ID
SUB_A_RECORD_ID="000000000"    # subdomain record ID

# retrive current porkbun DNS IP for root and subdomain of DOMAIN (@)
RETRIEVE_JSON_STRING='{"secretapikey":"'"$SECRET"'","apikey":"'"$KEY"'"}'

PORKBUN_ROOT_DNS_IP=$(curl --silent --header "Content-Type: application/json" --request POST --data "$RETRIEVE_JSON_STRING" "https://porkbun.com/api/json/v3/dns/retrieve/$DOMAIN/$ROOT_A_RECORD_ID" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "Current Porkbun DNS IP for A record is $PORKBUN_ROOT_DNS_IP"

PORKBUN_SUB_DNS_IP=$(curl --silent --header "Content-Type: application/json" --request POST --data "$RETRIEVE_JSON_STRING" "https://porkbun.com/api/json/v3/dns/retrieve/$DOMAIN/$SUB_A_RECORD_ID" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "Current Porkbun DNS IP for subdomain record is $PORKBUN_SUB_DNS_IP"

# retrive current external IP of local network
CURRENT_IP=$(curl --silent GET "http://ipinfo.io/json" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "Current External IP for local network is $CURRENT_IP"

# compare root DNS IP and External IP, update DNS IP if not equal
if [ "$PORKBUN_ROOT_DNS_IP" != "$CURRENT_IP" ];
 then
 echo "Root domain IPs are not equal."
	# create JSON data string to use for update POST for the root of $DOMAIN
	EDIT_ROOT_JSON_STRING='{"secretapikey":"'"$SECRET"'","apikey":"'"$KEY"'","name":"","type":"A","content":"'"$CURRENT_IP"'","ttl":"600"}'
	curl --header "Content-Type: application/json" --request POST --data "$EDIT_ROOT_JSON_STRING" "https://porkbun.com/api/json/v3/dns/edit/$DOMAIN/$ROOT_A_RECORD_ID"
else
	echo "Root IPs are the same, no changes will be made"
fi

# compare subdomain DNS IP and External IP, update DNS IP if not equal
if [ "$PORKBUN_SUB_DNS_IP" != "$CURRENT_IP" ];
 then
 echo "Subdomain IPs are not equal."
	# create JSON data string to use for update POST for the subdomain of $DOMAIN
	EDIT_SUB_JSON_STRING='{"secretapikey":"'"$SECRET"'","apikey":"'"$KEY"'","name":"*","type":"A","content":"'"$CURRENT_IP"'","ttl":"600"}'
	curl --header "Content-Type: application/json" --request POST --data "$EDIT_SUB_JSON_STRING" "https://porkbun.com/api/json/v3/dns/edit/$DOMAIN/$SUB_A_RECORD_ID"
else
	echo "Subdomain IPs are the same, no changes will be made"
fi
