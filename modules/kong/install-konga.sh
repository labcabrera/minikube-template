#!/usr/bin/env bash

set -euo pipefail

info() { echo "[INFO] $*"; }
err() { echo "[ERROR] $*" >&2; }

check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Requiere '$1' pero no está instalado. Instálalo y reintenta."
    exit 1
  fi
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [--with-postgres]

Instala Konga en el namespace 'kong' de Minikube.

Opciones:
  --with-postgres   Configura Konga para usar PostgreSQL (se asume release 'kong-postgres' en el mismo namespace).
EOF
}

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPTDIR/config"

main() {
  WITH_POSTGRES=false
  for arg in "$@"; do
    case "$arg" in
      --with-postgres) WITH_POSTGRES=true ;;
      -h|--help) usage; exit 0 ;;
      *) err "Opción desconocida: $arg"; usage; exit 1 ;;
    esac
  done

  info "Comprobando dependencias: kubectl, minikube"
  check_cmd kubectl
  check_cmd minikube

  # prefer envsubst if available for template rendering, fallback to python3
  RENDER_CMD="envsubst"
  if ! command -v envsubst >/dev/null 2>&1; then
    if command -v python3 >/dev/null 2>&1; then
      RENDER_CMD="python3"
    else
      err "Se necesita 'envsubst' o 'python3' para renderizar plantillas. Instala gettext (envsubst) o Python3."
      exit 1
    fi
  fi

  PROFILE="minikube-template"
  if ! minikube status --profile "$PROFILE" >/dev/null 2>&1; then
    err "minikube no parece estar corriendo (perfil: $PROFILE). Inicia minikube y vuelve a ejecutar el script."
    exit 1
  fi

  NAMESPACE=kong
  info "Creando namespace '$NAMESPACE' (si no existe)"
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

  if [ "$WITH_POSTGRES" = true ]; then
    DB_ADAPTER=postgres
    DB_HOST=${DB_HOST:-kong-postgres-postgresql}
    DB_PORT=${DB_PORT:-5432}
    DB_USER=${DB_USER:-kong}
    DB_PASSWORD=${DB_PASSWORD:-kong}
    DB_DATABASE=${DB_DATABASE:-kong}
    read -r -d '' EXTRA_ENV <<EOV || true
            - name: DB_HOST
              value: "${DB_HOST}"
            - name: DB_PORT
              value: "${DB_PORT}"
            - name: DB_USER
              value: "${DB_USER}"
            - name: DB_PASSWORD
              value: "${DB_PASSWORD}"
            - name: DB_DATABASE
              value: "${DB_DATABASE}"
EOV
  else
    DB_ADAPTER=sqlite
    EXTRA_ENV=""
  fi

  # Render deployment template
  TMP_DEPLOY=$(mktemp)
  export DB_ADAPTER
  export EXTRA_ENV
  if [ "$RENDER_CMD" = "envsubst" ]; then
    envsubst < "$TEMPLATES_DIR/konga-deployment.yaml.tpl" > "$TMP_DEPLOY"
  else
    # python fallback: replace ${DB_ADAPTER} and ${EXTRA_ENV}
    python3 - <<PY > "$TMP_DEPLOY"
import os,sys
tpl=open(sys.argv[1]).read()
tpl=tpl.replace('${DB_ADAPTER}', os.environ.get('DB_ADAPTER',''))
tpl=tpl.replace('${EXTRA_ENV}', os.environ.get('EXTRA_ENV',''))
print(tpl)
PY
    "$TEMPLATES_DIR/konga-deployment.yaml.tpl"
  fi

  info "Aplicando Deployment de Konga desde plantilla"
  kubectl -n "$NAMESPACE" apply -f "$TMP_DEPLOY"

  info "Aplicando Service de Konga"
  kubectl -n "$NAMESPACE" apply -f "$TEMPLATES_DIR/konga-service.yaml"

  rm -f "$TMP_DEPLOY"

  info "Esperando despliegue de Konga..."
  kubectl -n "$NAMESPACE" rollout status deploy/konga --timeout=120s || true

  MINIKUBE_IP=$(minikube ip --profile "$PROFILE")
  info "Konga disponible en: http://$MINIKUBE_IP:32080"
  if [ "$WITH_POSTGRES" = true ]; then
    info "Konga configurado para usar PostgreSQL en $DB_HOST:5432"
  else
    info "Konga usando sqlite (persistencia local en el contenedor). Para producción, use --with-postgres."
  fi
}

main "$@"
