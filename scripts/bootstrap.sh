#!/usr/bin/env bash
set -e

# Usage: ./bootstrap.sh <cluster-name> <github-username>
# Example: ./bootstrap.sh demo-lab johndoe

# Validate input
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <cluster-name> <github-username>"
  exit 1
fi

CLUSTER_NAME=$1
GITHUB_USER=$2
FLUX_NAMESPACE="flux-system"
REPO_NAME="gitops-test"

# Ensure prerequisites are installed
command -v flux >/dev/null 2>&1 || { echo "flux CLI is required. Install from https://fluxcd.io/flux/installation/"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required"; exit 1; }

# Verify kubectl context
echo "Current kubectl context: $(kubectl config current-context)"
read -p "Is this the correct cluster? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Please set the correct kubectl context and try again"
  exit 1
fi

# Bootstrap Flux
echo "Bootstrapping Flux on cluster: $CLUSTER_NAME"
#flux bootstrap github \
#  --owner=$GITHUB_USER \
#  --repository=$REPO_NAME \
#  --branch=main \
#  --path=./clusters/$CLUSTER_NAME \
#  --personal \
#  --components-extra=image-reflector-controller,image-automation-controller
kubectl apply -k ./clusters/$CLUSTER_NAME/flux-system



echo "Flux bootstrap complete. Cluster $CLUSTER_NAME is now managed by Flux."
echo "Please commit and push any changes to your repository."