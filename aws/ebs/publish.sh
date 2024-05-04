#!/bin/bash -x


#
#   really basic parameter check.
#       We're just checking to see if the proper ENV variables have been set.
#
if [ -z ${AMI_PREFIX} ];
then 
    echo "AMI_PREFIX NOT SET. Exiting"
    exit 1
fi

if [ -z ${BASE_AMI_NAME} ];
then
    echo "BASE_AMI_NAME NOT SET. Exiting."
    exit 1
fi

if [ -z ${BASE_AMI_ID} ];
then
    echo "BASE_AMI_ID NOT SET. Exiting."
    exit 1
fi

if [ -z ${PACKER_MANIFEST} ];
then
    echo "PACKER_MANIFEST NOT SET. Exiting."
    exit 1
fi

if [ -z ${APP_NAME} ];
then
    echo "APP_NAME NOT SET. Exiting."
    exit 1
fi

if [ -z ${AMI_NAME} ];
then
    echo "APP_NAME NOT SET. Exiting."
    exit 1
fi



echo "Loading $PACKER_MANIFEST"
echo "APP_NAME: $APP_NAME"


#
#   Get the last run out of the manifest
#
LAST_RUN_UUID=`jq ".last_run_uuid" $PACKER_MANIFEST | sed -e 's/^"//' -e 's/"$//'`

echo "Last Run UUID: $LAST_RUN_UUID"

#
#   Get the artifact information from the manifest
#
ARTIFACT_IDS=`jq --arg LAST_RUN_UUID "$LAST_RUN_UUID" '.builds[] | select(.packer_run_uuid==$LAST_RUN_UUID) | .artifact_id' $PACKER_MANIFEST | sed -e 's/^"//' -e 's/"$//'`
BUILD_TIME=`jq --arg LAST_RUN_UUID "$LAST_RUN_UUID" '.builds[] | select(.packer_run_uuid==$LAST_RUN_UUID) | .build_time' $PACKER_MANIFEST | sed -e 's/^"//' -e 's/"$//'`

echo "Artifact ID: $ARTIFACT_IDS"
echo "BUILD_TIME: $BUILD_TIME"

#
#   Process everything and get 'region' and 'ami_id' into a format we can use'
#
ARTIFACTS=($(echo $ARTIFACT_IDS | tr "," "\n"))

#
#   Possible 'modes' for an AMI: stable or unstable. Param key takes the form of "/ami/<stable|unstable>/<app name>"
#
for i in "${ARTIFACTS[@]}"
do
    AMI=($(echo $i | tr ":" "\n"))

    REGION=${AMI[0]}
    AMI_ID=${AMI[1]}

    echo "Storing REGION: $REGION, AMI_ID: $AMI_ID in SSM Parameter Store"

    KEY="/ami/unstable/$APP_NAME"

    JSON_BLOB=$(cat <<EOF
{
    "image_name": "$AMI_NAME",
    "image_id": "$AMI_ID",
    "BASE_AMI_NAME": "$BASE_AMI_NAME",
    "BASE_AMI_ID": "$BASE_AMI_ID",
    "build_time": "$BUILD_TIME",
    "app_name": "$APP_NAME"
}
EOF
)

    echo "KEY: $KEY"
    echo "VALUE: $JSON_BLOB"

    aws ssm put-parameter --type String --name $KEY --value "$JSON_BLOB" --region $REGION --overwrite
    echo
done

exit 0
