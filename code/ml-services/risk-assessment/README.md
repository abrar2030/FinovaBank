# Risk Assessment Service

A standalone Python/Flask machine-learning service for FinovaBank that performs
credit scoring, loan underwriting risk, probability of default, and portfolio
risk, and persists per-customer risk profiles with an assessment history.

This service was added to fill a declared-but-unimplemented gap: `risk-assessment`
is referenced across the project's `docker-compose` files, Kubernetes
`values.yaml`, Ansible playbook, Prometheus targets, and database migrations
(`infrastructure/database/migrations/postgres/risk/`), but had no implementation
directory. The compute logic mirrors the proven `RiskAssessmentEngine` in
`ai-service`; the persistence layer matches the `risk_profiles` /
`risk_assessments` schema from the infrastructure migration.

## Endpoints

Base path: `/api/risk`

Stateless compute:

- `POST /credit-score` - credit score (300-850) with component breakdown
- `POST /loan-assessment` - loan risk level and rate adjustment
- `POST /default-probability` - probability of default
- `POST /portfolio-risk` - aggregate risk across a list of loans

Stateful risk profiles (persisted):

- `POST /profiles` - create or update a customer's risk profile; records
  assessment history. Accepts an explicit `risk_score` (0-1000) or
  `customer_data` from which a score is computed.
- `GET /profiles/<customer_id>` - fetch the current risk profile
- `GET /profiles/<customer_id>/history` - assessment history for a customer

Operational:

- `GET /health` - health check

## Running locally

    pip install -r requirements.txt
    python -m src.main          # serves on PORT (default 8014)

## Tests

    pip install -r requirements-dev.txt
    pytest -q

## Configuration

| Variable     | Default                               | Purpose                 |
| ------------ | ------------------------------------- | ----------------------- |
| PORT         | 8014                                  | Service port            |
| DATABASE_URL | sqlite:///src/database/app.db         | SQLAlchemy database URI |
| CORS_ORIGINS | \*                                    | Allowed CORS origins    |
| SECRET_KEY   | (development default; change in prod) | Flask secret key        |

## Integration notes

The internal port (8014) follows the ML-services sequence (ai-service 8012,
compliance-service 8013). Existing infrastructure references use other ports
(8087 in the root compose, 8100 in the infrastructure compose and Prometheus)
and a Spring-style `/actuator/health` check. Reconciling those port mappings and
the health-check path to this Flask service is part of the integration phase.
