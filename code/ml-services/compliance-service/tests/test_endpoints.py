"""Endpoint and regression tests for the FinovaBank compliance service.

Regression coverage:
- audit retention ordering (SOX events must retain for 7 years).
- audit /log must not crash when no `resource` is supplied.
- audit /statistics must not crash when events omit a `service`.
"""


def _log(client, payload):
    return client.post("/api/compliance/audit/log", json=payload)


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"


# Audit


def test_audit_log_minimal_no_resource(client):
    # Previously crashed with "'NoneType' object has no attribute 'lower'".
    resp = _log(client, {"event_type": "view", "user_id": "u2", "data": {}})
    assert resp.status_code == 201


def test_audit_log_sox_event_retention_is_seven_years(client):
    resp = _log(
        client,
        {
            "event_type": "txn",
            "user_id": "u1",
            "action": "financial_transaction",
            "service": "transaction-service",
            "risk_level": "HIGH",
            "data": {"ssn": "123456789", "amount": 50000},
        },
    )
    assert resp.status_code == 201
    audit_id = resp.get_json()["audit_id"]

    from src.routes.audit import audit_manager

    event = next(e for e in audit_manager.audit_events if e["audit_id"] == audit_id)
    assert event["sox_relevant"] is True
    assert event["retention_period_years"] == 7
    # Sensitive field should be masked.
    assert event["data"]["ssn"].endswith("6789")
    assert event["data"]["ssn"].startswith("*")


def test_audit_verify_integrity(client):
    resp = _log(client, {"event_type": "x", "user_id": "u3", "data": {"k": "v"}})
    audit_id = resp.get_json()["audit_id"]
    verify = client.get(f"/api/compliance/audit/verify-integrity/{audit_id}")
    assert verify.status_code == 200
    assert verify.get_json()["integrity_status"] == "VERIFIED"


def test_audit_search(client):
    _log(client, {"event_type": "x", "user_id": "u4", "data": {}})
    resp = client.post("/api/compliance/audit/search", json={"limit": 10})
    assert resp.status_code == 200


def test_audit_compliance_report(client):
    resp = client.post(
        "/api/compliance/audit/compliance-report", json={"compliance_type": "SOX"}
    )
    assert resp.status_code == 200


def test_audit_statistics_with_event_missing_service(client):
    # Log an event with no `service`, then ensure statistics does not crash on
    # the resulting None distribution key.
    _log(client, {"event_type": "y", "user_id": "u5", "data": {}})
    resp = client.get("/api/compliance/audit/statistics")
    assert resp.status_code == 200


# Compliance monitoring


def test_compliance_check_transaction(client):
    resp = client.post(
        "/api/compliance/monitoring/check-transaction",
        json={
            "transaction_id": "t1",
            "amount": 15000,
            "approvers": ["a"],
            "initiator": "x",
            "approver": "x",
        },
    )
    assert resp.status_code == 200


def test_compliance_check_data_access(client):
    resp = client.post(
        "/api/compliance/monitoring/check-data-access",
        json={
            "request_id": "r1",
            "data_type": "personal",
            "consent_obtained": False,
            "purpose": "marketing",
        },
    )
    assert resp.status_code == 200


def test_compliance_check_system_access(client):
    resp = client.post(
        "/api/compliance/monitoring/check-system-access",
        json={
            "access_id": "s1",
            "user_role": "ADMIN",
            "resource": "financial_reporting",
            "mfa_used": False,
        },
    )
    assert resp.status_code == 200


def test_compliance_dashboard(client):
    assert client.get("/api/compliance/monitoring/dashboard").status_code == 200


def test_compliance_violations(client):
    assert client.get("/api/compliance/monitoring/violations").status_code == 200


def test_compliance_rules(client):
    assert client.get("/api/compliance/monitoring/rules").status_code == 200


# Security


def test_security_analyze_login(client):
    resp = client.post(
        "/api/compliance/security/analyze-login",
        json={
            "username": "bob",
            "ip_address": "192.168.1.5",
            "user_agent": "curl/7",
            "success": False,
            "location": {"country": "RU"},
        },
    )
    assert resp.status_code == 200


def test_security_monitor_api(client):
    resp = client.post(
        "/api/compliance/security/monitor-api",
        json={
            "endpoint": "/api/admin/users",
            "method": "GET",
            "ip_address": "1.2.3.4",
            "user_id": "u1",
            "response_code": 403,
            "parameters": {"q": "1 OR 1=1 SELECT"},
        },
    )
    assert resp.status_code == 200


def test_security_report(client):
    assert (
        client.get("/api/compliance/security/security-report?hours=24").status_code
        == 200
    )


def test_security_blocked_ips_and_unblock(client):
    assert client.get("/api/compliance/security/blocked-ips").status_code == 200
    resp = client.post(
        "/api/compliance/security/unblock-ip", json={"ip_address": "1.2.3.4"}
    )
    assert resp.status_code == 200


def test_security_policies(client):
    assert client.get("/api/compliance/security/security-policies").status_code == 200


# Reporting


def test_reporting_sox(client):
    resp = client.post(
        "/api/compliance/reporting/generate-sox-report",
        json={"start_date": "2024-01-01", "end_date": "2024-02-01"},
    )
    assert resp.status_code == 200


def test_reporting_pci(client):
    resp = client.post(
        "/api/compliance/reporting/generate-pci-report",
        json={"start_date": "2024-01-01", "end_date": "2024-02-01"},
    )
    assert resp.status_code == 200


def test_reporting_gdpr(client):
    resp = client.post(
        "/api/compliance/reporting/generate-gdpr-report",
        json={"start_date": "2024-01-01", "end_date": "2024-02-01"},
    )
    assert resp.status_code == 200


def test_reporting_reports_and_templates(client):
    assert client.get("/api/compliance/reporting/reports").status_code == 200
    assert client.get("/api/compliance/reporting/report-templates").status_code == 200
