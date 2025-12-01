const client = require('prom-client');

// Create a Registry to register metrics
const register = new client.Registry();

// Add default metrics (CPU, memory, etc.)
client.collectDefaultMetrics({ register });

// Custom metrics for gateway
const httpRequestDuration = new client.Histogram({
  name: 'gateway_http_request_duration_seconds',
  help: 'Duration of HTTP requests through gateway in seconds',
  labelNames: ['method', 'path', 'status_code', 'target'],
  buckets: [0.001, 0.005, 0.015, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 1, 2, 5],
});

const httpRequestsTotal = new client.Counter({
  name: 'gateway_http_requests_total',
  help: 'Total number of HTTP requests through gateway',
  labelNames: ['method', 'path', 'status_code', 'target'],
});

const httpRequestsInProgress = new client.Gauge({
  name: 'gateway_http_requests_in_progress',
  help: 'Number of HTTP requests in progress through gateway',
  labelNames: ['method'],
});

const proxyErrorsTotal = new client.Counter({
  name: 'gateway_proxy_errors_total',
  help: 'Total number of proxy errors',
  labelNames: ['method', 'path', 'error_type'],
});

// Register custom metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(httpRequestsInProgress);
register.registerMetric(proxyErrorsTotal);

module.exports = {
  register,
  httpRequestDuration,
  httpRequestsTotal,
  httpRequestsInProgress,
  proxyErrorsTotal,
};
