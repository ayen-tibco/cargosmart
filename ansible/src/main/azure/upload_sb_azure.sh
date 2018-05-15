#!/bin/bash

LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
# Upload blob to Azure storage container.

echo "usage: ${0##*/} <storage-account-name> <container-name> <access-key> <file to upload>"

storage_account="$1"
container_name="$2"
access_key="yK8k+lCCWs+cxhLduI8cYeGbEeKG18cCIRG9KRMygCqEyVc9ulvnN4FW5Qhxc5bEcM1ZLotcAcaRmZgyYlUrGA=="
upload_file="$3"

blob_store_url="blob.core.windows.net"
authorization="SharedKey"

request_method="PUT"
request_date=$(TZ=GMT LC_ALL=en_US.utf8 date "+%a, %d %h %Y %H:%M:%S %Z")
storage_service_version="2015-12-11"

# HTTP Request headers
x_ms_date_h="x-ms-date:$request_date"
x_ms_version_h="x-ms-version:$storage_service_version"
x_ms_blob_type="x-ms-blob-type:BlockBlob"

# Build the signature string
canonicalized_headers="${x_ms_date_h}\n${x_ms_version_h}"
canonicalized_resource="/${storage_account}/${container_name}"

string_to_sign="${request_method}\n\n\n\n\n\n\n\n\n\n\n\n${canonicalized_headers}\n${canonicalized_resource}\nrestype:container\ntimeout:900"

# Decode the Base64 encoded access key, convert to Hex.
decoded_hex_key="$(echo -n $access_key | base64 -d -w0 | xxd -p -c256)"

# Create the HMAC signature for the Authorization header
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary | base64 -w0)

authorization_header="Authorization: $authorization $storage_account:$signature"

curl -v \
  -X $request_method \
  -T $upload_file \
  -H "$x_ms_date_h" \
  -H "$x_ms_version_h" \
  -H "$authorization_header" \
  "https://${storage_account}.${blob_store_url}/${container_name}/${upload_file}"

#  -H "$x_ms_blob_type" \

