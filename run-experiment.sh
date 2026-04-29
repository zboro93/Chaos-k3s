#!/bin/bash
TYPE=${1:-}
TIMESTAMP=$(date +%s)
JOB_NAME="chaos-${TIMESTAMP}"
NAMESPACE="chaos-testing"
# Buduj blok env osobno
if [ -n "$TYPE" ]; then
  EXTRA_ENV="
            - name: EXPERIMENT_TYPE
              value: \"${TYPE}\""
else
  EXTRA_ENV=""
fi
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: ${JOB_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: chaos-agent
    run-type: manual
    experiment-type: ${TYPE:-random}
spec:
  backoffLimit: 0
  activeDeadlineSeconds: 900
  template:
    metadata:
      labels:
        app: chaos-agent
        run-type: manual
    spec:
      serviceAccountName: chaos-agent
      restartPolicy: Never
      nodeSelector:
        kubernetes.io/hostname: k3s-worker-node2
      containers:
        - name: chaos-agent
          image: zboromir/chaos-agent:latest
          imagePullPolicy: Always
          envFrom:
            - configMapRef:
                name: chaos-agent-config
          env:
            - name: ANTHROPIC_API_KEY
              valueFrom:
                secretKeyRef:
                  name: chaos-agent-secrets
                  key: anthropic-api-key
            - name: SLACK_WEBHOOK_URL
              valueFrom:
                secretKeyRef:
                  name: chaos-agent-secrets
                  key: slack-webhook-url${EXTRA_ENV}
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
EOF
echo "✅ Job ${JOB_NAME} started (type: ${TYPE:-random})"
echo "📋 Logs: kubectl logs -n ${NAMESPACE} -l job-name=${JOB_NAME} -f"
