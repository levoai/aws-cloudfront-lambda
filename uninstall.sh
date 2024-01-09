#/usr/bin/env bash

echo Deleting the lambda functions...
aws lambda delete-function --function-name levoRequestHandler --region us-east-1
aws lambda delete-function --function-name levoResponseHandler --region us-east-1

echo Deleting the role used by the lambda functions...
aws iam delete-role --role-name levoCloudFrontLambdaRole

echo Done!
