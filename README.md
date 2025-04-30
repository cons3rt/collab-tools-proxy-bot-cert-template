# collab-tools-proxy-bot-cert-template
CollabTools Proxy Bot Cert Template Asset
# Collab Tools Proxy - Bot Cert

Stages the bot cert for the Collab Tools Proxy. Does the following:

1. Creates a directory for the certs - /usr/local/openresty/nginx/conf/ssl
2. Copies the client.crt and client.key to the directory
3. Changes the permissions on the key to 400 and the crt to 444

### Notes:

* Only tested on Red Hat Enterprise Linux 8
* The client.crt and client.key must be in the media directory

### Asset Update:
* Get the subject CN `openssl x509 -in client.crt -noout -subject | sed -n 's/.*CN[ ]*=[ ]*\(.*\)/\1/p'`
* Get the cert expiration `openssl x509 -in client.crt -noout -enddate | cut -d= -f2 | xargs -I{} date -d "{}" +"%Y%m%d"`
* Update the asset name. e.g., `Collab Tools Proxy - Bot Cert - my.cert.com (20251119)`
* From SUT
  ```
  sudo cp /usr/local/openresty/nginx/conf/ssl/client.{crt,key} .
  sudo chown -R proxy:proxy client.*
  openssl x509 -in client.crt -noout -subject | sed -n 's/.*CN[ ]*=[ ]*\(.*\)/\1/p'
  openssl x509 -in client.crt -noout -enddate | cut -d= -f2 | xargs -I{} date -d "{}" +"%Y%m%d"
  ```

### Exit Codes:

* 12 - client.crt not found
* 13 - client.key not found
