#!/usr/bin/env bash

if [[ -z "${LEVO_ORG_ID}" ]]; then
    echo LEVO_ORG_ID environment variable is not set.
    echo Please set it to your Levo Organization ID.
    echo You may find it at https://app.levo.ai/settings/organizations.
    exit 1
fi

echo Adding the lambda code to a zip file...
sed -i "s/LEVO_ORG_ID/$LEVO_ORG_ID/g" src/index.mjs
zip -j function.zip src/index.mjs
sed -i "s/$LEVO_ORG_ID/LEVO_ORG_ID/g" src/index.mjs
echo

echo Creating a role for the lambda functions...
aws iam create-role \
    --role-name levoCloudFrontLambdaRole \
    --description "Execution Role for Levo CloudFront Lambda@Edge Functions" \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["lambda.amazonaws.com","edgelambda.amazonaws.com"]},"Action":"sts:AssumeRole"}]}'

role_arn=$(aws iam get-role --role-name levoCloudFrontLambdaRole --query "Role.Arn" --output text)
echo

echo Creating lambda functions...
sleep 5
aws lambda create-function \
    --function-name levoRequestHandler \
    --runtime nodejs20.x \
    --zip-file fileb://function.zip \
    --handler index.requestHandler \
    --region us-east-1 \
    --timeout 10 \
    --role $role_arn

aws lambda create-function \
    --function-name levoResponseHandler \
    --runtime nodejs20.x \
    --zip-file fileb://function.zip \
    --handler index.responseHandler \
    --region us-east-1 \
    --timeout 10 \
    --role $role_arn

echo Publishing the lambda functions...
sleep 5
aws lambda publish-version --function-name levoRequestHandler --region us-east-1
aws lambda publish-version --function-name levoResponseHandler --region us-east-1
echo

echo Deleting the zip file...
rm function.zip

request_handler_arn=$(aws lambda list-versions-by-function --function-name levoRequestHandler --region us-east-1 --query "Versions[1].FunctionArn" --output text)
response_handler_arn=$(aws lambda list-versions-by-function --function-name levoResponseHandler --region us-east-1 --query "Versions[1].FunctionArn" --output text)

echo "########## READ ME! ##########"
echo
echo Please note the values below and follow further instructions at https://github.com/levoai/aws-cloudfront-lambda.
echo
echo Request Handler ARN
echo $request_handler_arn
echo
echo Response Handler ARN
echo $response_handler_arn
echo
echo "##############################"

echo Done!
