# PorkbunDDNS
This script can be used to check and update your Porkbun DNS "A" records to the IP address of your current external IP.

## INSTRUCTIONS
### Setting up variables
First, retrieve record IDs by running the following command, replacing the key for both ```secretapikey``` and ```apikey```, as well as ```example.com``` in the URL at the end of the command:

```curl --header "Content-Type: application/json" --request POST --data '{"secretapikey": "key","apikey": "key"}' https://porkbun.com/api/json/v3/dns/retrieve/example.com/```

Looking at the output of the command, look for the ```"id":"#########"``` string for each of the record you want this script to update.
Replace the data in the variables at the start of the file to match your findings.

### Setting up crontab
Run ```crontab -e``` and add ```0 0 * * * bash /path/to/script/PorkbunDDNS.sh```. This will run the script daily at midnight.

Ensure that the script is executable by running  ```chmod +x /path/to/script/PorkbunDDNS.sh``` to modify its permissions.

## Porkbun API reference documentation :
https://porkbun.com/api/json/v3/documentation

## Generate your API keys here :
https://porkbun.com/account/api
