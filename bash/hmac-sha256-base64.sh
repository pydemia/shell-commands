message=message
echo -en $message | openssl dgst -sha256 -hmac "key" -binary | base64 | sed -e 's/+/-/g' -e 's/\//_/g' | tr -d =
