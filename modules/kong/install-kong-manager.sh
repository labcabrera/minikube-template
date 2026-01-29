#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/Kong/kong-manager.git"
DEFAULT_NAMESPACE="kong-manager"

info(){ echo "[INFO] $*"; }
err(){ echo "[ERROR] $*" >&2; }

check_cmd(){
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Requiere '$1' pero no está instalado."
    exit 1
  fi
}

usage(){
  cat <<EOF
Usage: $(basename "$0") [--namespace NAMESPACE] [--repo REPO] [--keep]

Instala Kong Manager desde el repositorio upstream.

Options:
  --namespace NAMESPACE  Kubernetes namespace to use (default: $DEFAULT_NAMESPACE)
  --repo REPO            Git repo URL to clone (default: $REPO_URL)
  --keep                 Keep temporary clone dir for debugging
  -h, --help             Show this help

Notes:
 - This script will try to detect a Helm chart (Chart.yaml) in the repo. If found,
   it will `helm upgrade --install` the chart. Otherwise it will apply any YAML
   manifests found under common directories (deploy/, manifests/, k8s/).
 - Kong Manager may require enterprise licensing or additional configuration
   (DB credentials, admin endpoints). Adjust values or manifests before installing.
EOF
}

NAMESPACE="$DEFAULT_NAMESPACE"
REPO="$REPO_URL"
KEEP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --namespace) NAMESPACE="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --keep) KEEP=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Opción desconocida: $1"; usage; exit 1 ;;
  esac
done

info "Comprobando dependencias: git, kubectl, helm"
check_cmd git
check_cmd kubectl
check_cmd helm

TMPDIR=$(mktemp -d)
cleanup(){
  if [ "$KEEP" = true ]; then
    info "Manteniendo dir temporal: $TMPDIR"
  else
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

info "Clonando repo $REPO -> $TMPDIR"
git clone --depth 1 "$REPO" "$TMPDIR" >/dev/null 2>&1 || { err "Fallo al clonar $REPO"; exit 1; }

info "Asegurando namespace '$NAMESPACE'"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Buscar un Chart.yaml
CHART_PATH=""
while IFS= read -r -d '' file; do
  CHART_PATH=$(dirname "$file")
  break
done < <(find "$TMPDIR" -maxdepth 4 -type f -name Chart.yaml -print0)

if [ -n "$CHART_PATH" ]; then
  info "Encontrado Helm chart en: $CHART_PATH"
  info "Instalando via Helm (release: kong-manager)"
  helm upgrade --install kong-manager "$CHART_PATH" -n "$NAMESPACE" --wait --timeout 3m
  info "Helm install done"
  exit 0
fi

# Si no hay chart, buscar manifest dirs
MANIFEST_DIR=""
for d in deploy manifests k8s chart; do
  if [ -d "$TMPDIR/$d" ]; then
    MANIFEST_DIR="$TMPDIR/$d"
    break
  fi
done

if [ -z "$MANIFEST_DIR" ]; then
  # fallback: collect all yaml files
  YAML_FILES=$(find "$TMPDIR" -type f \( -name '*.yaml' -o -name '*.yml' \) -print)
else
  YAML_FILES=$(find "$MANIFEST_DIR" -type f \( -name '*.yaml' -o -name '*.yml' \) -print)
fi

if [ -z "$YAML_FILES" ]; then
  err "No se encontraron manifests ni chart en el repo. Inspecciona $TMPDIR"
  exit 1
fi

info "Aplicando manifests al namespace '$NAMESPACE'"
# Aplicar cada fichero en orden
for f in $YAML_FILES; do
  info "kubectl apply -f $f"
  kubectl -n "$NAMESPACE" apply -f "$f" || true
done

info "Instalación completada (manifests aplicados). Revisa pods y logs en namespace: $NAMESPACE"
kubectl -n "$NAMESPACE" get all

exit 0
