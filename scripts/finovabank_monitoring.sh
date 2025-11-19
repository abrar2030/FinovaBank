#!/bin/bash
# =====================================================
# FinovaBank Monitoring Setup Script
# =====================================================
# This script automates the setup and configuration of
# monitoring tools for the FinovaBank platform, including
# Prometheus, Grafana, and ELK Stack.
#
# Author: Manus AI
# Date: May 22, 2025
# =====================================================

set -e

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MONITORING_DIR="./monitoring"
CONFIG_DIR="./monitoring/config"
DATA_DIR="./monitoring/data"
GRAFANA_PORT=3000
PROMETHEUS_PORT=9090
KIBANA_PORT=5601
ELASTICSEARCH_PORT=9200
SETUP_PROMETHEUS=true
SETUP_GRAFANA=true
SETUP_ELK=true
SETUP_ALERTS=true

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [options]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help                  Display this help message"
    echo -e "  --monitoring-dir DIR    Monitoring directory (default: $MONITORING_DIR)"
    echo -e "  --config-dir DIR        Configuration directory (default: $CONFIG_DIR)"
    echo -e "  --data-dir DIR          Data directory (default: $DATA_DIR)"
    echo -e "  --grafana-port PORT     Grafana port (default: $GRAFANA_PORT)"
    echo -e "  --prometheus-port PORT  Prometheus port (default: $PROMETHEUS_PORT)"
    echo -e "  --kibana-port PORT      Kibana port (default: $KIBANA_PORT)"
    echo -e "  --elasticsearch-port P  Elasticsearch port (default: $ELASTICSEARCH_PORT)"
    echo -e "  --skip-prometheus       Skip Prometheus setup"
    echo -e "  --skip-grafana          Skip Grafana setup"
    echo -e "  --skip-elk              Skip ELK Stack setup"
    echo -e "  --skip-alerts           Skip alerts configuration"
    echo -e ""
    exit 0
}

# Function to display a step message
step_msg() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Function to display an error message
error_msg() {
    echo -e "\n${RED}ERROR:${NC} $1"
    exit 1
}

# Function to display a warning message
warning_msg() {
    echo -e "\n${YELLOW}WARNING:${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    step_msg "Checking monitoring prerequisites..."

    # Check for Docker and Docker Compose
    if ! command_exists docker || ! command_exists docker-compose; then
        error_msg "Docker and Docker Compose are required for monitoring setup"
    fi

    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        error_msg "Docker daemon is not running"
    fi

    # Create directories
    mkdir -p "$MONITORING_DIR" "$CONFIG_DIR" "$DATA_DIR"

    echo -e "${GREEN}All prerequisites satisfied!${NC}"
}

# Function to setup Prometheus
setup_prometheus() {
    if [ "$SETUP_PROMETHEUS" != true ]; then
        warning_msg "Skipping Prometheus setup as requested"
        return
    fi

    step_msg "Setting up Prometheus..."

    # Create Prometheus configuration directory
    mkdir -p "$CONFIG_DIR/prometheus"

    # Create Prometheus configuration file
    cat > "$CONFIG_DIR/prometheus/prometheus.yml" << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'backend-services'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['backend:8080', 'account-service:8081', 'payment-service:8082']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
EOF

    # Create alert rules file
    cat > "$CONFIG_DIR/prometheus/alert_rules.yml" << EOF
groups:
  - name: FinovaBank Alerts
    rules:
      - alert: HighCPULoad
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU load (instance {{ \$labels.instance }})"
          description: "CPU load is above 80% for 5 minutes\n  VALUE = {{ \$value }}\n  LABELS = {{ \$labels }}"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage (instance {{ \$labels.instance }})"
          description: "Memory usage is above 80% for 5 minutes\n  VALUE = {{ \$value }}\n  LABELS = {{ \$labels }}"

      - alert: HighDiskUsage
        expr: 100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes) > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage (instance {{ \$labels.instance }})"
          description: "Disk usage is above 85% for 5 minutes\n  VALUE = {{ \$value }}\n  LABELS = {{ \$labels }}"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service down (instance {{ \$labels.instance }})"
          description: "Service {{ \$labels.job }} is down\n  VALUE = {{ \$value }}\n  LABELS = {{ \$labels }}"
EOF

    # Create AlertManager configuration
    mkdir -p "$CONFIG_DIR/alertmanager"

    cat > "$CONFIG_DIR/alertmanager/alertmanager.yml" << EOF
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alertmanager@finovabank.com'
  smtp_auth_username: 'alertmanager'
  smtp_auth_password: 'password'

route:
  group_by: ['alertname', 'job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'email'

receivers:
  - name: 'email'
    email_configs:
      - to: 'alerts@finovabank.com'
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'instance']
EOF

    echo -e "${GREEN}Prometheus configuration completed!${NC}"
}

# Function to setup Grafana
setup_grafana() {
    if [ "$SETUP_GRAFANA" != true ]; then
        warning_msg "Skipping Grafana setup as requested"
        return
    fi

    step_msg "Setting up Grafana..."

    # Create Grafana configuration directory
    mkdir -p "$CONFIG_DIR/grafana/provisioning/datasources"
    mkdir -p "$CONFIG_DIR/grafana/provisioning/dashboards"
    mkdir -p "$CONFIG_DIR/grafana/dashboards"

    # Create Grafana datasource configuration
    cat > "$CONFIG_DIR/grafana/provisioning/datasources/datasource.yml" << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
EOF

    # Create Grafana dashboard configuration
    cat > "$CONFIG_DIR/grafana/provisioning/dashboards/dashboards.yml" << EOF
apiVersion: 1

providers:
  - name: 'Default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
EOF

    # Create a sample dashboard
    cat > "$CONFIG_DIR/grafana/dashboards/finovabank-dashboard.json" << EOF
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "panels": [
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\\"idle\\"}[5m])) * 100)",
          "legendFormat": "CPU Usage - {{instance}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "CPU Usage",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percent",
          "label": null,
          "logBase": 1,
          "max": "100",
          "min": "0",
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 4,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
          "legendFormat": "Memory Usage - {{instance}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Memory Usage",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percent",
          "label": null,
          "logBase": 1,
          "max": "100",
          "min": "0",
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "schemaVersion": 22,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ]
  },
  "timezone": "",
  "title": "FinovaBank Dashboard",
  "uid": "finovabank",
  "version": 1
}
EOF

    echo -e "${GREEN}Grafana configuration completed!${NC}"
}

# Function to setup ELK Stack
setup_elk() {
    if [ "$SETUP_ELK" != true ]; then
        warning_msg "Skipping ELK Stack setup as requested"
        return
    fi

    step_msg "Setting up ELK Stack..."

    # Create ELK configuration directories
    mkdir -p "$CONFIG_DIR/elasticsearch/config"
    mkdir -p "$CONFIG_DIR/logstash/config"
    mkdir -p "$CONFIG_DIR/logstash/pipeline"
    mkdir -p "$CONFIG_DIR/kibana/config"

    # Create Elasticsearch configuration
    cat > "$CONFIG_DIR/elasticsearch/config/elasticsearch.yml" << EOF
---
cluster.name: "finovabank-cluster"
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
EOF

    # Create Logstash configuration
    cat > "$CONFIG_DIR/logstash/config/logstash.yml" << EOF
---
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://elasticsearch:9200" ]
EOF

    # Create Logstash pipeline configuration
    cat > "$CONFIG_DIR/logstash/pipeline/logstash.conf" << EOF
input {
  beats {
    port => 5044
  }

  tcp {
    port => 5000
    codec => json
  }
}

filter {
  if [type] == "finovabank-logs" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:log_level} %{GREEDYDATA:log_message}" }
    }

    date {
      match => [ "timestamp", "ISO8601" ]
      target => "@timestamp"
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "finovabank-logs-%{+YYYY.MM.dd}"
  }
}
EOF

    # Create Kibana configuration
    cat > "$CONFIG_DIR/kibana/config/kibana.yml" << EOF
---
server.name: kibana
server.host: "0.0.0.0"
elasticsearch.hosts: [ "http://elasticsearch:9200" ]
xpack.monitoring.ui.container.elasticsearch.enabled: true
EOF

    echo -e "${GREEN}ELK Stack configuration completed!${NC}"
}

# Function to create Docker Compose file
create_docker_compose() {
    step_msg "Creating Docker Compose file for monitoring..."

    cat > "$MONITORING_DIR/docker-compose.yml" << EOF
version: '3'

services:
EOF

    # Add Prometheus services if enabled
    if [ "$SETUP_PROMETHEUS" = true ]; then
        cat >> "$MONITORING_DIR/docker-compose.yml" << EOF
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "${PROMETHEUS_PORT}:9090"
    volumes:
      - ${CONFIG_DIR}/prometheus:/etc/prometheus
      - ${DATA_DIR}/prometheus:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    restart: unless-stopped
    networks:
      - monitoring-network

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ${CONFIG_DIR}/alertmanager:/etc/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    restart: unless-stopped
    networks:
      - monitoring-network

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    networks:
      - monitoring-network
EOF
    fi

    # Add Grafana if enabled
    if [ "$SETUP_GRAFANA" = true ]; then
        cat >> "$MONITORING_DIR/docker-compose.yml" << EOF
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "${GRAFANA_PORT}:3000"
    volumes:
      - ${CONFIG_DIR}/grafana/provisioning:/etc/grafana/provisioning
      - ${CONFIG_DIR}/grafana/dashboards:/var/lib/grafana/dashboards
      - ${DATA_DIR}/grafana:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped
    networks:
      - monitoring-network
EOF
    fi

    # Add ELK Stack if enabled
    if [ "$SETUP_ELK" = true ]; then
        cat >> "$MONITORING_DIR/docker-compose.yml" << EOF
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.10.0
    container_name: elasticsearch
    ports:
      - "${ELASTICSEARCH_PORT}:9200"
      - "9300:9300"
    volumes:
      - ${CONFIG_DIR}/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - ${DATA_DIR}/elasticsearch:/usr/share/elasticsearch/data
    environment:
      - "ES_JAVA_OPTS=-Xmx512m -Xms512m"
    restart: unless-stopped
    networks:
      - monitoring-network

  logstash:
    image: docker.elastic.co/logstash/logstash:7.10.0
    container_name: logstash
    ports:
      - "5000:5000"
      - "5044:5044"
    volumes:
      - ${CONFIG_DIR}/logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml
      - ${CONFIG_DIR}/logstash/pipeline:/usr/share/logstash/pipeline
    environment:
      - "LS_JAVA_OPTS=-Xmx256m -Xms256m"
    depends_on:
      - elasticsearch
    restart: unless-stopped
    networks:
      - monitoring-network

  kibana:
    image: docker.elastic.co/kibana/kibana:7.10.0
    container_name: kibana
    ports:
      - "${KIBANA_PORT}:5601"
    volumes:
      - ${CONFIG_DIR}/kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml
    depends_on:
      - elasticsearch
    restart: unless-stopped
    networks:
      - monitoring-network
EOF
    fi

    # Add network configuration
    cat >> "$MONITORING_DIR/docker-compose.yml" << EOF

networks:
  monitoring-network:
    driver: bridge
EOF

    echo -e "${GREEN}Docker Compose file created: $MONITORING_DIR/docker-compose.yml${NC}"
}

# Function to create a startup script
create_startup_script() {
    step_msg "Creating monitoring startup script..."

    cat > "$MONITORING_DIR/start-monitoring.sh" << EOF
#!/bin/bash

# Start monitoring services
cd "\$(dirname "\$0")"
docker-compose up -d

echo "Monitoring services started!"
echo "Access points:"
EOF

    if [ "$SETUP_PROMETHEUS" = true ]; then
        echo "echo \"Prometheus: http://localhost:$PROMETHEUS_PORT\"" >> "$MONITORING_DIR/start-monitoring.sh"
    fi

    if [ "$SETUP_GRAFANA" = true ]; then
        echo "echo \"Grafana: http://localhost:$GRAFANA_PORT (admin/admin)\"" >> "$MONITORING_DIR/start-monitoring.sh"
    fi

    if [ "$SETUP_ELK" = true ]; then
        echo "echo \"Kibana: http://localhost:$KIBANA_PORT\"" >> "$MONITORING_DIR/start-monitoring.sh"
    fi

    chmod +x "$MONITORING_DIR/start-monitoring.sh"

    echo -e "${GREEN}Startup script created: $MONITORING_DIR/start-monitoring.sh${NC}"
}

# Function to create a README file
create_readme() {
    step_msg "Creating monitoring README file..."

    cat > "$MONITORING_DIR/README.md" << EOF
# FinovaBank Monitoring

This directory contains the monitoring setup for the FinovaBank platform.

## Components

EOF

    if [ "$SETUP_PROMETHEUS" = true ]; then
        cat >> "$MONITORING_DIR/README.md" << EOF
- **Prometheus**: Metrics collection and storage
- **AlertManager**: Alert handling and notifications
- **Node Exporter**: System metrics exporter
EOF
    fi

    if [ "$SETUP_GRAFANA" = true ]; then
        cat >> "$MONITORING_DIR/README.md" << EOF
- **Grafana**: Visualization and dashboards
EOF
    fi

    if [ "$SETUP_ELK" = true ]; then
        cat >> "$MONITORING_DIR/README.md" << EOF
- **Elasticsearch**: Log storage and indexing
- **Logstash**: Log processing and forwarding
- **Kibana**: Log visualization and analysis
EOF
    fi

    cat >> "$MONITORING_DIR/README.md" << EOF

## Getting Started

1. Start the monitoring stack:

   ```bash
   ./start-monitoring.sh
   ```

2. Access the monitoring interfaces:

EOF

    if [ "$SETUP_PROMETHEUS" = true ]; then
        cat >> "$MONITORING_DIR/README.md" << EOF
   - Prometheus: http://localhost:$PROMETHEUS_PORT
EOF
    fi

    if [ "$SETUP_GRAFANA" = true ]; then
        cat >> "$MONITORING_DIR/README.md" << EOF
   - Grafana: http://localhost:$GRAFANA_PORT (default credentials: admin/admin)
EOF
    fi

    if [ "$SETUP_ELK" = true ]; then
        cat >> "$MONITORING_DIR/README.md" << EOF
   - Kibana: http://localhost:$KIBANA_PORT
EOF
    fi

    cat >> "$MONITORING_DIR/README.md" << EOF

## Configuration

- Configuration files are located in the \`config\` directory
- Data is stored in the \`data\` directory

## Adding Application Metrics

### Spring Boot Applications

For Spring Boot applications, add the following dependencies to your \`pom.xml\`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

And add the following to your \`application.properties\` or \`application.yml\`:

```properties
management.endpoints.web.exposure.include=health,info,prometheus
management.endpoint.health.show-details=always
management.metrics.export.prometheus.enabled=true
```

### Node.js Applications

For Node.js applications, use the \`prom-client\` package:

```javascript
const express = require('express');
const client = require('prom-client');

// Create a Registry to register the metrics
const register = new client.Registry();
// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: 'finovabank-frontend'
});
// Enable the collection of default metrics
client.collectDefaultMetrics({ register });

const app = express();

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(3000);
```

## Logging Configuration

### Spring Boot Applications

For Spring Boot applications, configure Logback to send logs to Logstash:

```xml
<appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
    <destination>localhost:5000</destination>
    <encoder class="net.logstash.logback.encoder.LogstashEncoder">
        <customFields>{"application":"finovabank-backend","environment":"development"}</customFields>
    </encoder>
</appender>

<root level="INFO">
    <appender-ref ref="LOGSTASH" />
</root>
```

### Node.js Applications

For Node.js applications, use Winston with Logstash transport:

```javascript
const winston = require('winston');
const { LogstashTransport } = require('winston-logstash-transport');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'finovabank-frontend' },
  transports: [
    new LogstashTransport({
      host: 'localhost',
      port: 5000
    })
  ]
});
```

## Alerts

Alerts are configured in Prometheus and sent via AlertManager. To modify alert rules, edit:

\`config/prometheus/alert_rules.yml\`

To modify alert receivers and routes, edit:

\`config/alertmanager/alertmanager.yml\`
EOF

    echo -e "${GREEN}README file created: $MONITORING_DIR/README.md${NC}"
}

# Parse command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --help)
            usage
            ;;
        --monitoring-dir)
            MONITORING_DIR="$2"
            shift
            ;;
        --config-dir)
            CONFIG_DIR="$2"
            shift
            ;;
        --data-dir)
            DATA_DIR="$2"
            shift
            ;;
        --grafana-port)
            GRAFANA_PORT="$2"
            shift
            ;;
        --prometheus-port)
            PROMETHEUS_PORT="$2"
            shift
            ;;
        --kibana-port)
            KIBANA_PORT="$2"
            shift
            ;;
        --elasticsearch-port)
            ELASTICSEARCH_PORT="$2"
            shift
            ;;
        --skip-prometheus)
            SETUP_PROMETHEUS=false
            ;;
        --skip-grafana)
            SETUP_GRAFANA=false
            ;;
        --skip-elk)
            SETUP_ELK=false
            ;;
        --skip-alerts)
            SETUP_ALERTS=false
            ;;
        *)
            error_msg "Unknown option: $1"
            ;;
    esac
    shift
done

# Main execution
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}FinovaBank Monitoring Setup${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check prerequisites
check_prerequisites

# Setup components
setup_prometheus
setup_grafana
setup_elk

# Create Docker Compose file
create_docker_compose

# Create startup script
create_startup_script

# Create README
create_readme

echo -e "\n${GREEN}Monitoring setup completed successfully!${NC}"
echo -e "To start monitoring, run: ${BLUE}$MONITORING_DIR/start-monitoring.sh${NC}"
echo -e "${BLUE}======================================================${NC}"

exit 0
