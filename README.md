# Multi-Cluster GitOps with FluxCD

This repository contains Kubernetes manifests and Helm releases managed by FluxCD for deploying infrastructure and applications across multiple clusters.

## Repository Structure

- `bootstrap/`: Scripts to bootstrap Flux on new clusters
- `clusters/`: Contains cluster-specific configurations and variables
- `infrastructure/`: Shared infrastructure components (ingress, DNS, etc.)
- `apps/`: Application deployments

## Prerequisites

- Kubernetes clusters ready for Flux installation
- `flux` CLI installed locally
- `kubectl` configured with access to your cluster
- Cloudflare account with Tunnel configured (for external access)

## Adding a New Cluster

1. Run the bootstrap script with your cluster name and GitHub username:

```bash
./bootstrap.sh demo-lab your-github-username

```