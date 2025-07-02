#!/bin/bash

set -euo pipefail

# Default values
WORKLOAD_TYPE=""
APP_NAME=""
PVC_NAME=""
NAMESPACE=""
CHOWN_UID="1000"
MOUNT_PATH="/pvc"

# Function to show usage
show_usage() {
	echo "Usage: $0 --deployment/-d <name> --statefulset/-s <name> --pvc/-p <name> --namespace/-n <namespace> [--chown/-c <uid>]"
	echo ""
	echo "Options:"
	echo "  --deployment, -d    Target deployment name"
	echo "  --statefulset, -s   Target statefulset name"
	echo "  --pvc, -p          PVC name"
	echo "  --namespace, -n   Namespace"
	echo "  --chown, -c        UID for chown (default: 1000)"
	echo ""
	echo "Examples:"
	echo "  $0 --deployment myapp --pvc myapp-data --namespace default"
	echo "  $0 -s myapp -p myapp-data -n default -c 568"
	exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		--deployment|-d)
			WORKLOAD_TYPE="deployment"
			APP_NAME="$2"
			shift 2
			;;
		--statefulset|-s)
			WORKLOAD_TYPE="statefulset"
			APP_NAME="$2"
			shift 2
			;;
		--pvc|-p)
			PVC_NAME="$2"
			shift 2
			;;
		--namespace|-n)
			NAMESPACE="$2"
			shift 2
			;;
		--chown|-c)
			CHOWN_UID="$2"
			shift 2
			;;
		--help|-h)
			show_usage
			;;
		*)
			echo "Unknown option: $1"
			show_usage
			;;
	esac
done

# Validate required parameters
if [[ -z "$WORKLOAD_TYPE" || -z "$APP_NAME" || -z "$PVC_NAME" || -z "$NAMESPACE" ]]; then
	echo "Error: Missing required parameters"
	show_usage
fi

REPAIR_POD="${APP_NAME}-fix-perms"

echo "📦 Target workload: $WORKLOAD_TYPE/$APP_NAME"
echo "🔖 PVC: $PVC_NAME"
echo "📁 Mount path: $MOUNT_PATH"
echo "🧭 Namespace: $NAMESPACE"
echo "👤 Chown UID: $CHOWN_UID"

# Scale down workload
echo "🔻 Scaling down $WORKLOAD_TYPE/$APP_NAME..."
kubectl -n "$NAMESPACE" scale "$WORKLOAD_TYPE" "$APP_NAME" --replicas=0

# Wait for pods to terminate
echo "⏳ Waiting for pods to terminate..."
kubectl -n "$NAMESPACE" wait --for=delete pod -l app="$APP_NAME" --timeout=60s || true

# Apply repair pod
echo "🔧 Launching fix-perms pod..."
cat <<EOF | kubectl -n "$NAMESPACE" apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $REPAIR_POD
spec:
  restartPolicy: Never
  containers:
  - name: chown
    image: alpine
    command: ["sh", "-c", "chown -R $CHOWN_UID:$CHOWN_UID $MOUNT_PATH"]
    volumeMounts:
    - mountPath: $MOUNT_PATH
      name: data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: $PVC_NAME
EOF

# Wait for pod to succeed
echo "🕒 Waiting for chown to complete..."
for i in {1..30}; do
	STATUS=$(kubectl -n "$NAMESPACE" get pod "$REPAIR_POD" -o jsonpath='{.status.phase}')
	if [[ "$STATUS" == "Succeeded" ]]; then
		echo "✅ chown completed successfully."
		break
	elif [[ "$STATUS" == "Failed" ]]; then
		echo "❌ Pod failed. Showing logs:"
		kubectl -n "$NAMESPACE" logs "$REPAIR_POD"
		exit 1
	fi
	sleep 5
done

# Cleanup
echo "🧹 Cleaning up fix-perms pod..."
kubectl -n "$NAMESPACE" delete pod "$REPAIR_POD"

# Scale back up
echo "🔼 Scaling up $WORKLOAD_TYPE/$APP_NAME..."
kubectl -n "$NAMESPACE" scale "$WORKLOAD_TYPE" "$APP_NAME" --replicas=1

echo "✅ Done."
