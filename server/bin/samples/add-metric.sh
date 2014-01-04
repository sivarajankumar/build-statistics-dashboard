#/bin/bash

endpoint=$1
software=$2
version=$3
name=$4
value=$5

curl -F "value=${value}" -X POST ${endpoint}/create-or-replace/release-${software}/version-${version}/metric-${name}.json
