#/bin/bash

endpoint=$1
software=$2
version=$3
step=$4
label=$5

curl -F "label=${label}" -X POST ${endpoint}/create/release-${software}/version-${version}/step-${step}/attachments/label.json
