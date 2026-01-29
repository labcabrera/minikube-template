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
Uso: $(basename "$0")

Instala Kong en Minikube en el namespace 'kong'.

Requiere: helm, kubectl, minikube.
EOF
}

main() {
	if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
		usage
		exit 0
	fi

    PROFILE="minikube-template"

	info "Comprobando dependencias: helm, kubectl, minikube"
	check_cmd helm
	check_cmd kubectl
    check_cmd minikube
	# check_cmd minikube --profile "$PROFILE"

	if ! minikube status --profile "$PROFILE" >/dev/null 2>&1; then
		err "minikube no parece estar corriendo. Inicia minikube y vuelve a ejecutar el script."
		exit 1
	fi

	NAMESPACE=kong
	info "Añadiendo repositorio Helm de Kong y actualizando repositorios"
	helm repo add kong https://charts.konghq.com || true
	helm repo update

	info "Creando namespace '$NAMESPACE' (si no existe)"
	kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

	info "Instalando/actualizando Kong en namespace '$NAMESPACE'"
	helm upgrade --install kong kong/kong \
		--namespace "$NAMESPACE" \
		--set proxy.type=NodePort \
		--set proxy.http.nodePort=30080 \
		--set proxy.tls.nodePort=30443 \
		--set admin.type=ClusterIP \
		--wait --timeout 5m

	info "Esperando que los pods estén listos"
	kubectl -n "$NAMESPACE" rollout status deploy/kong-kong --timeout=180s || true

	info "Servicios en namespace '$NAMESPACE':"
	kubectl -n "$NAMESPACE" get svc

	MINIKUBE_IP=$(minikube ip --profile "$PROFILE")
	echo
	info "Acceso a Kong Proxy (HTTP): http://$MINIKUBE_IP:30080"
	info "Acceso a Kong Proxy (TLS): https://$MINIKUBE_IP:30443"
	info "Admin API: use 'kubectl -n $NAMESPACE port-forward svc/kong-kong-admin 8001:8001' o exponlo según necesites"
}

main "$@"

