
openssl req -new -newkey rsa:4096 -x509 -sha256 \
        -days 3650 -nodes -out relay-root-ca.crt -keyout relay-root-ca.key \
        -subj "/CN=relay-root-ca" \
        -addext "extendedKeyUsage = clientAuth, serverAuth"


# Server certificate configuration
cat > "gloo-mesh-mgmt-server.conf" <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.gloo-mesh
DNS.2 = *.vpc
DNS.3 = *.example.com
DNS.4 = example.com
DNS.5 = *.ha-demo.vpc
DNS.1 = ha-demo.vpc
DNS.7 = *.demo.vpc
DNS.8 = *.demo
DNS.9 = *.elb.us-east-1.amazonaws.com
EOF


# Generate gloo-mesh-mgmt-server private key
openssl genrsa -out "gloo-mesh-mgmt-server.key" 2048
# Generate gloo-mesh-mgmt-server CSR
openssl req -new -key "gloo-mesh-mgmt-server.key" -out gloo-mesh-mgmt-server.csr -subj "/CN=gloo-mesh-mgmt-server" -config "gloo-mesh-mgmt-server.conf"

# Sign certificate with local relay-root-ca
openssl x509 -req \
  -days 3650 \
  -CA relay-root-ca.crt -CAkey relay-root-ca.key \
  -set_serial 0 \
  -in gloo-mesh-mgmt-server.csr -out gloo-mesh-mgmt-server.crt \
  -extensions v3_req -extfile "gloo-mesh-mgmt-server.conf"



#### agent
CLUSTER_NAME="my-workload-cluster"

# DNS = $CLUSTER_NAME must match the clusterName used in the gloo-mesh-agent install !!
echo "[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS = $CLUSTER_NAME" > "gloo-mesh-agent-$CLUSTER_NAME.conf"

# Generate private key
openssl genrsa -out "gloo-mesh-agent-$CLUSTER_NAME.key" 2048
# Create CSR
openssl req -new -key "gloo-mesh-agent-$CLUSTER_NAME.key" -out gloo-mesh-agent-$CLUSTER_NAME.csr -subj "/CN=gloo-mesh-mgmt-server-ca" -config "gloo-mesh-agent-$CLUSTER_NAME.conf"

# Sign certificate with root
openssl x509 -req \
  -days 3650 \
  -CA relay-root-ca.crt -CAkey relay-root-ca.key \
  -set_serial 0 \
  -in gloo-mesh-agent-$CLUSTER_NAME.csr -out gloo-mesh-agent-$CLUSTER_NAME.crt \
  -extensions v3_req -extfile "gloo-mesh-agent-$CLUSTER_NAME.conf"


##### otel gateway 

cat > "gloo-telemetry-gateway.conf" <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS = *.gloo-mesh
EOF

openssl genrsa -out "gloo-telemetry-gateway.key" 2048
openssl req -new -key "gloo-telemetry-gateway.key" -out gloo-telemetry-gateway.csr -subj "/CN=gloo-telemetry-gateway" -config "gloo-telemetry-gateway.conf"

openssl x509 -req \
  -days 3650 \
  -CA relay-root-ca.crt -CAkey relay-root-ca.key \
  -set_serial 0 \
  -in gloo-telemetry-gateway.csr -out gloo-telemetry-gateway.crt \
  -extensions v3_req -extfile "gloo-telemetry-gateway.conf"

# ##########
# secrets #

# root ca secret, create everywhere
kubectl create secret generic relay-root-tls-secret \
  -n gloo-mesh \
  --from-file ca.crt=relay-root-ca.crt  \
  --dry-run=client

# relay-server-tls-secret - mgmt only
kubectl create secret generic relay-server-tls-secret \
  --from-file=tls.key=gloo-mesh-mgmt-server.key \
  --from-file=tls.crt=gloo-mesh-mgmt-server.crt \
  --from-file=ca.crt=relay-root-ca.crt \
  --namespace gloo-mesh \
  --dry-run=client

# otel - mgmt only
kubectl create secret generic gloo-telemetry-gateway-tls-secret \
  --from-file=tls.key=gloo-telemetry-gateway.key \
  --from-file=tls.crt=gloo-telemetry-gateway.crt \
  --from-file=ca.crt=relay-root-ca.crt \
  --namespace gloo-mesh \
  --dry-run=client

# agent cert - 1 per agent
kubectl create secret generic gloo-mesh-agent-$CLUSTER_NAME-tls-cert \
  --from-file=tls.key=gloo-mesh-agent-$CLUSTER_NAME.key \
  --from-file=tls.crt=gloo-mesh-agent-$CLUSTER_NAME.crt \
  --from-file=ca.crt=relay-root-ca.crt \
  --context $CLUSTER_NAME \
  --namespace gloo-mesh \
  --dry-run=client