# Manual

## Development

Start development environment
```bash
make dev-up
```

Stop development environment
```bash
make dev-down
```

View development logs
```bash
make dev-logs
```

Restart development services
```bash
make dev-restart
```

## Production

Start production environment
```bash
make prod-up
```

Build production containers
```bash
make prod-build
```

Stop production environment
```bash
make prod-down
```

## Utilities

Check service health
```bash
make health
```

Clean up containers
```bash
make clean
```

Show all commands
```bash
make help
```

## Monitoring

Grafana URL
```
http://localhost:3001
```

Grafana Credentials
```
Username: admin
Password: admin123
```

Prometheus URL
```
http://localhost:9090
```
