# Define variables
flux_version := "2.0.1"
repo_name := "gitops-test"
age_key_dir := "$HOME/.config/secrets"
age_key_path := "$HOME/.config/secrets/age.key"

# List available commands
default:
    @just --list

# Create a new cluster with FluxCD
bootstrap cluster_name github_user:
    @echo "Bootstrapping cluster {{cluster_name}}..."
    ./scripts/bootstrap.sh {{cluster_name}} {{github_user}}

# Generate a cluster age key and install it into the cluster
generate-cluster-key cluster_name:
    #!/usr/bin/env bash
    ./scripts/generate-cluster-key.sh {{cluster_name}} {{age_key_dir}}

# Update SOPS keys in all clusters
update-keys:
    @sops updatekeys clusters/*/*-secrets.yaml
## Set up Flux to use SOPS for secret decryption
#setup-flux-sops:
#    @echo "Setting up Flux SOPS integration..."
#    kubectl -n flux-system create secret generic sops-age \
#        --from-file=age.agekey={{age_key_path}}
#
## Encrypt a Kubernetes secret
#encrypt-secret file:
#    @echo "Encrypting {{file}} with SOPS..."
#    sops --encrypt --in-place {{file}}
#

#
## Create Cloudflare tunnel secret interactively
#create-cloudflare-secret namespace="cloudflare":
#    @echo "Creating Cloudflare tunnel secret in namespace {{namespace}}..."
#    @read -p "Enter Tunnel ID: " TUNNEL_ID; \
#    read -p "Enter Tunnel Name: " TUNNEL_NAME; \
#    read -p "Enter Domain: " DOMAIN; \
#    read -sp "Enter Tunnel Token: " TUNNEL_TOKEN; \
#    echo ""; \
#    cat > cloudflare-tunnel-secret.yaml << EOF
#    apiVersion: v1
#    kind: Secret
#    metadata:
#      name: tunnel-credentials
#      namespace: {{namespace}}
#    type: Opaque
#    stringData:
#      tunnelID: "$$TUNNEL_ID"
#      tunnelName: "$$TUNNEL_NAME"
#      domain: "$$DOMAIN"
#      tunnelToken: "$$TUNNEL_TOKEN"
#    EOF
#    @echo "Created cloudflare-tunnel-secret.yaml"
#    @echo "Run 'just encrypt-secret cloudflare-tunnel-secret.yaml' to encrypt it"
#
## Create a new cluster overlay from template
#create-cluster-overlay cluster_name:
#    @echo "Creating overlay structure for cluster {{cluster_name}}..."
#    @mkdir -p infrastructure/cloudflare/overlays/{{cluster_name}}
#    @mkdir -p infrastructure/ingress-nginx/overlays/{{cluster_name}}
#    @mkdir -p clusters/{{cluster_name}}
#    @echo "Created overlay directories"
#    @echo "Don't forget to create appropriate kustomization.yaml files"
#
## Validate kustomize overlays
#validate-kustomize path:
#    @echo "Validating kustomize configuration at {{path}}..."
#    kustomize build {{path}} > /dev/null && echo "✓ Kustomize validation passed" || echo "✗ Kustomize validation failed"
#
## Install Flux CLI (if not available)
#install-flux:
#    @echo "Installing Flux CLI version {{flux_version}}..."
#    @if ! command -v flux &> /dev/null; then \
#        curl -s https://fluxcd.io/install.sh | FLUX_VERSION={{flux_version}} bash; \
#    else \
#        echo "Flux CLI is already installed"; \
#    fi
#
## Generate a complete cluster structure
#init-cluster cluster_name domain="example.com":
#    @echo "Initializing structure for cluster {{cluster_name}}..."
#    @mkdir -p clusters/{{cluster_name}}/flux-system
#    @mkdir -p infrastructure/base
#    @mkdir -p infrastructure/cloudflare/overlays/{{cluster_name}}
#    @mkdir -p infrastructure/ingress-nginx/overlays/{{cluster_name}}
#    @mkdir -p apps/base
#
#    @echo "Creating infrastructure.yaml for {{cluster_name}}..."
#    @cat > clusters/{{cluster_name}}/infrastructure.yaml << EOF
#    apiVersion: kustomize.toolkit.fluxcd.io/v1
#    kind: Kustomization
#    metadata:
#      name: infrastructure-sources
#      namespace: flux-system
#    spec:
#      interval: 1h
#      sourceRef:
#        kind: GitRepository
#        name: flux-system
#      path: ./infrastructure/base
#      prune: true
#    ---
#    apiVersion: kustomize.toolkit.fluxcd.io/v1
#    kind: Kustomization
#    metadata:
#      name: cloudflare-tunnel
#      namespace: flux-system
#    spec:
#      dependsOn:
#        - name: infrastructure-sources
#      interval: 1h
#      sourceRef:
#        kind: GitRepository
#        name: flux-system
#      path: ./infrastructure/cloudflare/overlays/{{cluster_name}}
#      prune: true
#    EOF
#
#    @echo "Creating cloudflare overlay for {{cluster_name}}..."
#    @cat > infrastructure/cloudflare/overlays/{{cluster_name}}/kustomization.yaml << EOF
#    apiVersion: kustomize.config.k8s.io/v1beta1
#    kind: Kustomization
#    resources:
#      - ../../base
#    patchesStrategicMerge:
#      - values.yaml
#    EOF
#
#    @cat > infrastructure/cloudflare/overlays/{{cluster_name}}/values.yaml << EOF
#    apiVersion: helm.toolkit.fluxcd.io/v2beta1
#    kind: HelmRelease
#    metadata:
#      name: cloudflare-tunnel
#      namespace: cloudflare
#    spec:
#      values:
#        cloudflare:
#          tunnelName: "{{cluster_name}}-tunnel"
#          tunnelId: "xxxx-xxxx-xxxx-xxxx"
#          ingress:
#            - hostname: "*.{{domain}}"
#              service: "https://ingress-nginx-controller.ingress-system.svc.cluster.local:443"
#              originRequest:
#                noTLSVerify: true
#    EOF
#
#    @echo "Cluster structure for {{cluster_name}} created successfully!"