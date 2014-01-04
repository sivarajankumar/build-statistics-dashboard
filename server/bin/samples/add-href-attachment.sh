#/bin/bash

endpoint=$1
software=$2
version=$3
step=$4
label=$5
link=$6

curl -F "label=${label}" -F "link=${link}" -X POST ${endpoint}/create/release-${software}/version-${version}/step-${step}/attachments/href.json
