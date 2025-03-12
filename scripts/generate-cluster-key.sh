#!/usr/bin/env bash
set -e


if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <cluster-name> <key-path>"
  exit 1
fi

CLUSTER_NAME=$1
KEY_PATH=$2

cluster_key="${KEY_PATH}/${CLUSTER_NAME}.key"

mkdir -p "${KEY_PATH}"


if [ ! -f "${cluster_key}" ]; then
    echo "Age key ${cluster_key} not found, generating a new one..."
    age-keygen -o "${cluster_key}"
fi

# Get public key
age_pub_key=$(grep "public key" "${cluster_key}" | awk '{print $4}')

if kubectl get secret flux-sops-agekey --namespace flux-system > /dev/null 2>&1; then
    echo "Secret flux-sops-agekey already exists. Recreating it..."
    kubectl delete secret flux-sops-agekey --namespace flux-system
fi

# Create Kubernetes secret
kubectl create secret generic flux-sops-agekey \
    --namespace flux-system \
    --from-literal=age.agekey="$(cat "${cluster_key}")"

echo "Your age public key: ${age_pub_key} has been installed into the cluster"
echo "Remember to update your .sops.yaml file with this key and execute just update-keys"