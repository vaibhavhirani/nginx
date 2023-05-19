#!/bin/sh
rm -rf sp.json
ARM_SUBSCRIPTION_ID=`az account show | jq .id -r`
`az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}" >> sp.json`
export ARM_CLIENT_ID=`jq ".appId" -r sp.json`
export ARM_CLIENT_SECRET=`jq ".password" -r sp.json`
export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
export ARM_TENANT_ID=`jq ".tenant" -r sp.json`
rm -rf sp.json


