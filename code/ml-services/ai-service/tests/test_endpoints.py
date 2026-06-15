"""Endpoint and regression tests for the FinovaBank AI service.

The serialization tests guard the fix for numpy/pandas values reaching jsonify,
which previously caused HTTP 500 on the analytics and risk endpoints.
"""


def _sample_transactions():
    return [
        {
            "date": f"2024-0{m}-15T{h:02d}:00:00",
            "amount": 100 * m + h,
            "transaction_type": "PURCHASE" if h % 2 else "WITHDRAWAL",
        }
        for m in range(1, 4)
        for h in range(0, 5)
    ]


def _sample_portfolio():
    return [
        {
            "loan_amount": 10000 + i * 500,
            "credit_score": 600 + i * 20,
            "debt_to_income_ratio": 0.3,
            "default_probability": 0.05 + i * 0.01,
            "risk_level": "LOW",
            "industry": "tech",
        }
        for i in range(6)
    ]


def _sample_products():
    return [
        {
            "product_type": "savings",
            "revenue": 1000 + i * 100,
            "customer_id": f"u{i % 3}",
            "date": f"2024-0{(i % 3) + 1}-01",
        }
        for i in range(9)
    ]


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"


def test_fraud_analyze(client):
    resp = client.post(
        "/api/ai/fraud/analyze",
        json={
            "transaction_id": "t1",
            "amount": 12000,
            "timestamp": "2024-01-01T03:00:00",
            "transaction_type": "WITHDRAWAL",
            "country": "FR",
            "home_country": "US",
        },
    )
    assert resp.status_code == 200
    body = resp.get_json()
    assert body["risk_level"] in {"MINIMAL", "LOW", "MEDIUM", "HIGH"}


def test_fraud_batch_analyze(client):
    resp = client.post(
        "/api/ai/fraud/batch-analyze",
        json={"transactions": [{"transaction_id": "t1", "amount": 12000}]},
    )
    assert resp.status_code == 200
    assert resp.get_json()["total_transactions"] == 1


def test_risk_credit_score(client):
    resp = client.post(
        "/api/ai/risk/credit-score",
        json={
            "customer_id": "c1",
            "payment_history": {"on_time_payments": 90, "total_payments": 100},
        },
    )
    assert resp.status_code == 200
    assert 300 <= resp.get_json()["credit_score"] <= 850


def test_risk_loan_assessment(client):
    resp = client.post(
        "/api/ai/risk/loan-assessment",
        json={"application_id": "a1", "credit_score": 720, "monthly_income": 6000},
    )
    assert resp.status_code == 200


def test_risk_default_probability(client):
    resp = client.post(
        "/api/ai/risk/default-probability",
        json={"customer_id": "c1", "credit_score": 700},
    )
    assert resp.status_code == 200


def test_risk_portfolio(client):
    resp = client.post(
        "/api/ai/risk/portfolio-risk", json={"loans": _sample_portfolio()}
    )
    assert resp.status_code == 200


def test_recommendations_products(client):
    resp = client.post(
        "/api/ai/recommendations/products",
        json={
            "customer_id": "c1",
            "age": 30,
            "annual_income": 80000,
            "current_savings": 2000,
        },
    )
    assert resp.status_code == 200


def test_recommendations_advice(client):
    resp = client.post(
        "/api/ai/recommendations/financial-advice",
        json={"customer_id": "c1", "annual_income": 80000},
    )
    assert resp.status_code == 200


def test_recommendations_spending_insights(client):
    resp = client.post(
        "/api/ai/recommendations/spending-insights",
        json={
            "transaction_history": [
                {"category": "food", "amount": 50, "date": "2024-01-01"}
            ]
        },
    )
    assert resp.status_code == 200


# Regression tests for the numpy/pandas serialization fix.


def test_analytics_transaction_patterns_serializes(client):
    resp = client.post(
        "/api/ai/analytics/transaction-patterns",
        json={"transactions": _sample_transactions()},
    )
    assert resp.status_code == 200
    body = resp.get_json()
    # peak_hour was a numpy.int64 that previously broke jsonify.
    assert isinstance(body["patterns"]["peak_hour"], int)


def test_analytics_risk_analytics_serializes(client):
    resp = client.post(
        "/api/ai/analytics/risk-analytics", json={"portfolio": _sample_portfolio()}
    )
    assert resp.status_code == 200


def test_analytics_product_performance_serializes(client):
    resp = client.post(
        "/api/ai/analytics/product-performance", json={"products": _sample_products()}
    )
    assert resp.status_code == 200


def test_analytics_dashboard_metrics_serializes(client):
    resp = client.post(
        "/api/ai/analytics/dashboard-metrics",
        json={
            "transactions": _sample_transactions(),
            "portfolio": _sample_portfolio(),
            "products": _sample_products(),
        },
    )
    assert resp.status_code == 200
    assert resp.get_json()["metrics_count"] == 3


def test_analytics_predictive_revenue(client):
    hist = [
        {"date": f"2024-0{m}-01", "revenue": 1000 * m, "customer_id": f"u{m}"}
        for m in range(1, 6)
    ]
    resp = client.post(
        "/api/ai/analytics/predictive-analytics",
        json={"historical_data": hist, "prediction_type": "revenue_forecast"},
    )
    assert resp.status_code == 200


def test_analytics_predictive_churn(client):
    hist = [
        {"date": f"2024-0{m}-01", "revenue": 1000 * m, "customer_id": f"u{m}"}
        for m in range(1, 6)
    ]
    resp = client.post(
        "/api/ai/analytics/predictive-analytics",
        json={"historical_data": hist, "prediction_type": "customer_churn"},
    )
    assert resp.status_code == 200
