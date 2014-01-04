#/bin/bash

endpoint=$1
software=$2
version=$3
step=$4
state=$5

echo curl -s -w "%{http_code}\n" -F "status=${state}" -X POST ${endpoint}/create-or-replace/release-${software}/version-${version}/step-${step}.json
curl -s -w "%{http_code}\n" -F "status=${state}" -X POST ${endpoint}/create-or-replace/release-${software}/version-${version}/step-${step}.json
