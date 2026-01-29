apiVersion: apps/v1
kind: Deployment
metadata:
  name: konga
  labels:
    app: konga
spec:
  replicas: 1
  selector:
    matchLabels:
      app: konga
  template:
    metadata:
      labels:
        app: konga
    spec:
      containers:
        - name: konga
          image: pantsel/konga:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 1337
          env:
            - name: NODE_ENV
              value: production
            - name: KONGA_PORT
              value: "1337"
            - name: DB_ADAPTER
              value: "${DB_ADAPTER}"
${EXTRA_ENV}
