#!/bin/sh
sp=`cat sp.json`
ARM_SUBSCRIPTION_ID=`az account show | jq .id -r`
if [ -z "$sp" ]
then
    echo "Creating Service Prinicipal"
    `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}" >> sp.json`
else
    echo "Proceeds with following details"
    cat sp.json
fi
export ARM_CLIENT_ID=`jq ".appId" -r sp.json`
export ARM_CLIENT_SECRET=`jq ".password" -r sp.json`
export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
export ARM_TENANT_ID=`jq ".tenant" -r sp.json`
rm -rf sp.json


