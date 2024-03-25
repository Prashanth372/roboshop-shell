#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web" )
INSTANCE_TYPE=""
IMAGE_ID=ami-0f3c7d07486cad139
SECURITY_GROUP_ID=sg-0143478f1ecc67d53
DOMAIN_NAME=suvarnalaxmiinfradevelopers.online


#for mysql and mangodb instance_type should be t3.medium, for all others it t2.micro
for i in "${NAMES[@]}"
do
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then 
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo "creating $i instance"

    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GROUP_ID  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance : $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z0355686B9U964BDJZ0B --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                "Name": "'$i.$DOMAIN_NAME'",
                                "Type": "A",
                                "TTL": 300,
                                "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                            }}]
    }
    '
 done   