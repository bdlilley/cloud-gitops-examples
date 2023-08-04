
openssl req -new -newkey rsa:4096 -x509 -sha256 \
        -days 3650 -nodes -out relay-root-ca.crt -keyout relay-root-ca.key \
        -subj "/CN=relay-root-ca" \
        -addext "extendedKeyUsage = clientAuth, serverAuth"

# create on all clusters for cert-manager
kubectl create secret generic root-issuer \
  --from-file=tls.key=relay-root-ca.key \
  --from-file=tls.crt=relay-root-ca.crt \
  --from-file=ca.crt=relay-root-ca.crt \
  --namespace gloo-mesh \
  --dry-run=client \
  -oyaml

# create on all clustesr for CA ref to issuer 
kubectl create secret generic root-issuer-ca \
  -n gloo-mesh \
  --from-file ca.crt=relay-root-ca.crt  \
  --dry-run=client \
  -oyaml