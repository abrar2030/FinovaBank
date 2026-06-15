"""Endpoint tests for the FinovaBank risk-assessment service.

Covers the stateless compute endpoints and the stateful risk-profile
persistence flow (create, update with history, retrieval, validation).
"""

import uuid


def _unique_customer():
    return "CUST-" + uuid.uuid4().hex[:8]


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["service"] == "FinovaBank Risk Assessment Service"


def test_credit_score(client):
    resp = client.post(
        "/api/risk/credit-score",
        json={
            "customer_id": "c1",
            "payment_history": {"on_time_payments": 95, "total_payments": 100},
            "total_credit_limit": 10000,
            "total_credit_used": 2000,
            "credit_history_months": 60,
        },
    )
    assert resp.status_code == 200
    assert 300 <= resp.get_json()["credit_score"] <= 850


def test_loan_assessment(client):
    resp = client.post(
        "/api/risk/loan-assessment",
        json={
            "application_id": "a1",
            "credit_score": 720,
            "monthly_income": 6000,
            "loan_amount": 20000,
            "collateral_value": 25000,
        },
    )
    assert resp.status_code == 200
    assert resp.get_json()["risk_level"] in {"LOW", "MEDIUM", "HIGH", "VERY_HIGH"}


def test_default_probability(client):
    resp = client.post(
        "/api/risk/default-probability",
        json={
            "customer_id": "c1",
            "credit_score": 700,
            "annual_income": 60000,
            "loan_amount": 15000,
        },
    )
    assert resp.status_code == 200
    assert 0.0 <= resp.get_json()["default_probability"] <= 1.0


def test_portfolio_risk_serializes(client):
    # Exercises the numpy aggregation path (np.mean) through the JSON provider.
    loans = [
        {
            "loan_id": i,
            "loan_amount": 10000 + i * 1000,
            "credit_score": 680,
            "annual_income": 60000,
        }
        for i in range(4)
    ]
    resp = client.post(
        "/api/risk/portfolio-risk", json={"portfolio_id": "p1", "loans": loans}
    )
    assert resp.status_code == 200
    body = resp.get_json()
    assert body["total_loans"] == 4
    assert isinstance(body["average_default_probability"], (int, float))


def test_portfolio_risk_requires_loans(client):
    resp = client.post("/api/risk/portfolio-risk", json={"loans": []})
    assert resp.status_code == 400


def test_profile_create_update_history(client):
    customer = _unique_customer()

    # Create from customer_data (credit score computed and mapped to risk score).
    create = client.post(
        "/api/risk/profiles",
        json={
            "customer_id": customer,
            "payment_history": {"on_time_payments": 90, "total_payments": 100},
            "total_credit_limit": 10000,
            "total_credit_used": 3000,
            "assessed_by": "tester",
        },
    )
    assert create.status_code == 201
    created = create.get_json()
    assert created["customer_id"] == customer
    assert 0 <= created["risk_score"] <= 1000
    assert created["latest_assessment"]["previous_score"] is None

    # Update with an explicit score; previous_score must be recorded.
    update = client.post(
        "/api/risk/profiles",
        json={
            "customer_id": customer,
            "risk_score": 820,
            "assessed_by": "tester",
            "assessment_reason": "manual override",
        },
    )
    assert update.status_code == 200
    updated = update.get_json()
    assert updated["risk_score"] == 820
    assert updated["fraud_likelihood"] == "CRITICAL"
    assert updated["latest_assessment"]["previous_score"] == created["risk_score"]

    # Retrieve and check history has two entries.
    got = client.get(f"/api/risk/profiles/{customer}")
    assert got.status_code == 200

    history = client.get(f"/api/risk/profiles/{customer}/history")
    assert history.status_code == 200
    assert len(history.get_json()["assessments"]) == 2


def test_profile_not_found(client):
    resp = client.get("/api/risk/profiles/does-not-exist")
    assert resp.status_code == 404


def test_profile_invalid_fraud_likelihood(client):
    resp = client.post(
        "/api/risk/profiles",
        json={
            "customer_id": _unique_customer(),
            "risk_score": 100,
            "fraud_likelihood": "BOGUS",
        },
    )
    assert resp.status_code == 400


def test_profile_requires_customer_id(client):
    resp = client.post("/api/risk/profiles", json={"risk_score": 100})
    assert resp.status_code == 400
