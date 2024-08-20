kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-deployment
  namespace: default  # Replace with your namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs
  template:
    metadata:
      labels:
        app: nodejs
      annotations:
        sidecar.opentelemetry.io/inject: "true"  # Enable OpenTelemetry Collector as sidecar
        instrumentation.opentelemetry.io/inject-nodejs: "true"  # Enable Node.js auto-instrumentation
    spec:
      containers:
      - name: nodejs-container
        image: node:18
        command: ["node", "/usr/src/app/index.js"]
        volumeMounts:
          - name: app-volume
            mountPath: /usr/src/app
      volumes:
      - name: app-volume
        emptyDir: {}
EOF
