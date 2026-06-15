"""Risk assessment routes for the standalone risk-assessment service.

The RiskAssessmentEngine compute logic (credit scoring, loan underwriting,
probability of default, portfolio risk) mirrors the proven implementation in
ai-service/src/routes/risk_assessment.py. This service additionally persists
per-customer risk profiles and an assessment history, matching the
risk_profiles / risk_assessments schema defined in the infrastructure
migrations, which is what makes risk-assessment a stateful service in its own
right rather than a stateless route.
"""

import logging
import math
from datetime import datetime, timezone
from typing import Any, Dict

import numpy as np
from flask import Blueprint, jsonify, request
from src.models.risk import FRAUD_LIKELIHOOD_VALUES, RiskAssessment, RiskProfile, db

risk_bp = Blueprint("risk", __name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class RiskAssessmentEngine:
    """Credit scoring and loan underwriting risk engine."""

    def __init__(self):
        self.credit_score_weights = {
            "payment_history": 0.35,
            "credit_utilization": 0.30,
            "length_of_credit_history": 0.15,
            "credit_mix": 0.10,
            "new_credit": 0.10,
        }
        self.loan_risk_weights = {
            "credit_score": 0.25,
            "debt_to_income": 0.20,
            "employment_stability": 0.15,
            "loan_to_value": 0.15,
            "income_verification": 0.10,
            "collateral_value": 0.10,
            "market_conditions": 0.05,
        }

    def calculate_credit_score(self, customer_data: Dict) -> Dict[str, Any]:
        payment_history = customer_data.get("payment_history", {})
        on_time_payments = payment_history.get("on_time_payments", 0)
        total_payments = payment_history.get("total_payments", 1)
        late_payments = payment_history.get("late_payments", 0)

        payment_score = max(
            0, min(100, (on_time_payments / total_payments) * 100 - late_payments * 5)
        )

        total_credit_limit = customer_data.get("total_credit_limit", 1)
        total_credit_used = customer_data.get("total_credit_used", 0)
        utilization_ratio = (
            total_credit_used / total_credit_limit if total_credit_limit > 0 else 0
        )

        if utilization_ratio <= 0.1:
            utilization_score = 100
        elif utilization_ratio <= 0.3:
            utilization_score = 90 - (utilization_ratio - 0.1) * 100
        else:
            utilization_score = max(0, 70 - (utilization_ratio - 0.3) * 100)

        credit_history_months = customer_data.get("credit_history_months", 0)
        history_score = min(100, (credit_history_months / 120) * 100)

        credit_types = customer_data.get("credit_types", [])
        mix_score = min(100, len(credit_types) * 20)

        recent_inquiries = customer_data.get("recent_inquiries", 0)
        new_credit_score = max(0, 100 - recent_inquiries * 10)

        weighted_score = (
            payment_score * self.credit_score_weights["payment_history"]
            + utilization_score * self.credit_score_weights["credit_utilization"]
            + history_score * self.credit_score_weights["length_of_credit_history"]
            + mix_score * self.credit_score_weights["credit_mix"]
            + new_credit_score * self.credit_score_weights["new_credit"]
        )

        credit_score = int(300 + (weighted_score / 100) * 550)

        if credit_score >= 800:
            grade = "Excellent"
        elif credit_score >= 740:
            grade = "Very Good"
        elif credit_score >= 670:
            grade = "Good"
        elif credit_score >= 580:
            grade = "Fair"
        else:
            grade = "Poor"

        return {
            "credit_score": credit_score,
            "grade": grade,
            "components": {
                "payment_history": round(payment_score, 1),
                "credit_utilization": round(utilization_score, 1),
                "credit_history_length": round(history_score, 1),
                "credit_mix": round(mix_score, 1),
                "new_credit": round(new_credit_score, 1),
            },
            "utilization_ratio": round(utilization_ratio * 100, 2),
        }

    def assess_loan_risk(self, loan_application: Dict) -> Dict[str, Any]:
        credit_score = loan_application.get("credit_score", 650)
        if credit_score >= 750:
            credit_score_factor = 1.0
        elif credit_score >= 700:
            credit_score_factor = 0.8
        elif credit_score >= 650:
            credit_score_factor = 0.6
        elif credit_score >= 600:
            credit_score_factor = 0.4
        else:
            credit_score_factor = 0.2

        monthly_income = loan_application.get("monthly_income", 1)
        monthly_debt = loan_application.get("monthly_debt", 0)
        loan_payment = loan_application.get("estimated_monthly_payment", 0)
        dti_ratio = (
            (monthly_debt + loan_payment) / monthly_income if monthly_income > 0 else 1
        )

        if dti_ratio <= 0.28:
            dti_factor = 1.0
        elif dti_ratio <= 0.36:
            dti_factor = 0.8
        elif dti_ratio <= 0.43:
            dti_factor = 0.6
        else:
            dti_factor = 0.3

        employment_months = loan_application.get("employment_months", 0)
        if employment_months >= 24:
            employment_factor = 1.0
        elif employment_months >= 12:
            employment_factor = 0.8
        elif employment_months >= 6:
            employment_factor = 0.6
        else:
            employment_factor = 0.4

        loan_amount = loan_application.get("loan_amount", 0)
        collateral_value = loan_application.get("collateral_value", loan_amount)
        ltv_ratio = loan_amount / collateral_value if collateral_value > 0 else 1

        if ltv_ratio <= 0.8:
            ltv_factor = 1.0
        elif ltv_ratio <= 0.9:
            ltv_factor = 0.8
        elif ltv_ratio <= 0.95:
            ltv_factor = 0.6
        else:
            ltv_factor = 0.3

        income_verified = loan_application.get("income_verified", False)
        income_factor = 1.0 if income_verified else 0.7

        has_collateral = loan_application.get("has_collateral", False)
        collateral_factor = 1.0 if has_collateral else 0.8

        market_factor = 0.9

        risk_score = (
            credit_score_factor * self.loan_risk_weights["credit_score"]
            + dti_factor * self.loan_risk_weights["debt_to_income"]
            + employment_factor * self.loan_risk_weights["employment_stability"]
            + ltv_factor * self.loan_risk_weights["loan_to_value"]
            + income_factor * self.loan_risk_weights["income_verification"]
            + collateral_factor * self.loan_risk_weights["collateral_value"]
            + market_factor * self.loan_risk_weights["market_conditions"]
        )

        risk_percentage = (1 - risk_score) * 100

        if risk_percentage <= 15:
            risk_level = "LOW"
            recommendation = "APPROVE"
            interest_rate_adjustment = 0.0
        elif risk_percentage <= 30:
            risk_level = "MEDIUM"
            recommendation = "APPROVE_WITH_CONDITIONS"
            interest_rate_adjustment = 1.0
        elif risk_percentage <= 50:
            risk_level = "HIGH"
            recommendation = "MANUAL_REVIEW"
            interest_rate_adjustment = 2.5
        else:
            risk_level = "VERY_HIGH"
            recommendation = "DECLINE"
            interest_rate_adjustment = 5.0

        return {
            "risk_score": round(risk_score, 3),
            "risk_percentage": round(risk_percentage, 2),
            "risk_level": risk_level,
            "recommendation": recommendation,
            "interest_rate_adjustment": interest_rate_adjustment,
            "factors": {
                "credit_score": round(credit_score_factor, 3),
                "debt_to_income": round(dti_factor, 3),
                "employment_stability": round(employment_factor, 3),
                "loan_to_value": round(ltv_factor, 3),
                "income_verification": round(income_factor, 3),
                "collateral_value": round(collateral_factor, 3),
                "market_conditions": round(market_factor, 3),
            },
            "ratios": {
                "debt_to_income": round(dti_ratio * 100, 2),
                "loan_to_value": round(ltv_ratio * 100, 2),
            },
        }

    def calculate_probability_of_default(self, customer_data: Dict) -> Dict[str, Any]:
        credit_score = customer_data.get("credit_score", 650)
        dti_ratio = customer_data.get("debt_to_income_ratio", 0.3)
        employment_months = customer_data.get("employment_months", 12)
        loan_amount = customer_data.get("loan_amount", 10000)
        annual_income = customer_data.get("annual_income", 50000)

        credit_score_norm = (credit_score - 300) / 550
        dti_norm = min(dti_ratio, 1.0)
        employment_norm = min(employment_months / 60, 1.0)
        loan_to_income = loan_amount / annual_income if annual_income > 0 else 1

        intercept = -2.5
        coefficients = {
            "credit_score": 3.0,
            "dti_ratio": -2.0,
            "employment": 1.5,
            "loan_to_income": -1.0,
        }

        linear_combination = (
            intercept
            + coefficients["credit_score"] * credit_score_norm
            + coefficients["dti_ratio"] * (1 - dti_norm)
            + coefficients["employment"] * employment_norm
            + coefficients["loan_to_income"] * (1 - min(loan_to_income, 1.0))
        )

        probability = 1 / (1 + math.exp(-linear_combination))
        default_probability = 1 - probability

        if default_probability <= 0.05:
            category = "Very Low Risk"
        elif default_probability <= 0.15:
            category = "Low Risk"
        elif default_probability <= 0.30:
            category = "Medium Risk"
        elif default_probability <= 0.50:
            category = "High Risk"
        else:
            category = "Very High Risk"

        return {
            "default_probability": round(default_probability, 4),
            "default_percentage": round(default_probability * 100, 2),
            "risk_category": category,
            "confidence_interval": {
                "lower": round(max(0, default_probability - 0.05), 4),
                "upper": round(min(1, default_probability + 0.05), 4),
            },
        }

    def assess_portfolio(self, loans):
        portfolio_results = []
        total_exposure = 0
        weighted_risk = 0

        for loan in loans:
            risk_result = self.assess_loan_risk(loan)
            default_prob = self.calculate_probability_of_default(loan)
            loan_amount = loan.get("loan_amount", 0)
            total_exposure += loan_amount
            weighted_risk += risk_result["risk_percentage"] * loan_amount
            portfolio_results.append(
                {
                    "loan_id": loan.get("loan_id"),
                    "loan_amount": loan_amount,
                    "risk_level": risk_result["risk_level"],
                    "risk_percentage": risk_result["risk_percentage"],
                    "default_probability": default_prob["default_percentage"],
                }
            )

        portfolio_risk = weighted_risk / total_exposure if total_exposure > 0 else 0
        high_risk_count = len(
            [l for l in portfolio_results if l["risk_level"] in ["HIGH", "VERY_HIGH"]]
        )
        avg_default_prob = (
            np.mean([l["default_probability"] for l in portfolio_results])
            if portfolio_results
            else 0
        )

        return {
            "total_loans": len(loans),
            "total_exposure": total_exposure,
            "portfolio_risk_percentage": round(portfolio_risk, 2),
            "average_default_probability": round(avg_default_prob, 2),
            "high_risk_loans": high_risk_count,
            "risk_distribution": {
                "low": len([l for l in portfolio_results if l["risk_level"] == "LOW"]),
                "medium": len(
                    [l for l in portfolio_results if l["risk_level"] == "MEDIUM"]
                ),
                "high": len(
                    [l for l in portfolio_results if l["risk_level"] == "HIGH"]
                ),
                "very_high": len(
                    [l for l in portfolio_results if l["risk_level"] == "VERY_HIGH"]
                ),
            },
            "loans": portfolio_results,
        }


risk_engine = RiskAssessmentEngine()


def _fraud_likelihood_for_score(risk_score: int) -> str:
    """Map an internal 0-1000 risk score to a fraud likelihood band."""
    if risk_score >= 750:
        return "CRITICAL"
    if risk_score >= 500:
        return "HIGH"
    if risk_score >= 250:
        return "MEDIUM"
    return "LOW"


# Stateless compute endpoints


@risk_bp.route("/credit-score", methods=["POST"])
def credit_score():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400
        result = risk_engine.calculate_credit_score(data)
        result["customer_id"] = data.get("customer_id")
        result["calculation_timestamp"] = datetime.now(timezone.utc).isoformat()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error calculating credit score: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500


@risk_bp.route("/loan-assessment", methods=["POST"])
def loan_assessment():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400
        result = risk_engine.assess_loan_risk(data)
        result["application_id"] = data.get("application_id")
        result["assessment_timestamp"] = datetime.now(timezone.utc).isoformat()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error assessing loan risk: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500


@risk_bp.route("/default-probability", methods=["POST"])
def default_probability():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400
        result = risk_engine.calculate_probability_of_default(data)
        result["customer_id"] = data.get("customer_id")
        result["calculation_timestamp"] = datetime.now(timezone.utc).isoformat()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error calculating default probability: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500


@risk_bp.route("/portfolio-risk", methods=["POST"])
def portfolio_risk():
    try:
        data = request.get_json()
        loans = data.get("loans", []) if data else []
        if not loans:
            return jsonify({"error": "No loans provided"}), 400
        result = risk_engine.assess_portfolio(loans)
        result["portfolio_id"] = data.get("portfolio_id")
        result["assessment_timestamp"] = datetime.now(timezone.utc).isoformat()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error assessing portfolio risk: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500


# Stateful risk-profile endpoints (persistence layer)


@risk_bp.route("/profiles", methods=["POST"])
def upsert_profile():
    """Create or update a customer risk profile, recording assessment history.

    Accepts either an explicit risk_score (0-1000) or customer_data from which a
    credit score is computed and mapped onto the 0-1000 risk scale.
    """
    try:
        data = request.get_json()
        if not data or not data.get("customer_id"):
            return jsonify({"error": "customer_id is required"}), 400

        customer_id = str(data["customer_id"])
        credit_score = data.get("credit_score")

        if "risk_score" in data:
            risk_score = int(data["risk_score"])
        else:
            computed = risk_engine.calculate_credit_score(data)
            credit_score = computed["credit_score"]
            # Map a 300-850 credit score to a 0-1000 risk score (inverted:
            # a higher credit score means lower risk).
            risk_score = int(round((850 - credit_score) / 550 * 1000))

        risk_score = max(0, min(1000, risk_score))
        fraud_likelihood = data.get(
            "fraud_likelihood", _fraud_likelihood_for_score(risk_score)
        )
        if fraud_likelihood not in FRAUD_LIKELIHOOD_VALUES:
            return (
                jsonify(
                    {
                        "error": "invalid fraud_likelihood",
                        "allowed": list(FRAUD_LIKELIHOOD_VALUES),
                    }
                ),
                400,
            )

        assessed_by = data.get("assessed_by", "risk-engine")
        reason = data.get("assessment_reason", "automated risk assessment")

        profile = RiskProfile.query.filter_by(customer_id=customer_id).first()
        created = profile is None

        if created:
            profile = RiskProfile(
                customer_id=customer_id,
                risk_score=risk_score,
                credit_score=credit_score,
                fraud_likelihood=fraud_likelihood,
                last_assessment_date=datetime.now(timezone.utc),
            )
            db.session.add(profile)
            db.session.flush()  # assign profile.id
            previous_score = None
        else:
            previous_score = profile.risk_score
            profile.risk_score = risk_score
            profile.credit_score = credit_score
            profile.fraud_likelihood = fraud_likelihood
            profile.last_assessment_date = datetime.now(timezone.utc)

        assessment = RiskAssessment(
            profile_id=profile.id,
            previous_score=previous_score,
            new_score=risk_score,
            assessment_reason=reason,
            assessed_by=assessed_by,
        )
        db.session.add(assessment)
        db.session.commit()

        body = profile.to_dict()
        body["latest_assessment"] = assessment.to_dict()
        return jsonify(body), (201 if created else 200)
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error upserting risk profile: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500


@risk_bp.route("/profiles/<customer_id>", methods=["GET"])
def get_profile(customer_id):
    profile = RiskProfile.query.filter_by(customer_id=str(customer_id)).first()
    if profile is None:
        return jsonify({"error": "Risk profile not found"}), 404
    return jsonify(profile.to_dict()), 200


@risk_bp.route("/profiles/<customer_id>/history", methods=["GET"])
def get_profile_history(customer_id):
    profile = RiskProfile.query.filter_by(customer_id=str(customer_id)).first()
    if profile is None:
        return jsonify({"error": "Risk profile not found"}), 404
    return (
        jsonify(
            {
                "customer_id": profile.customer_id,
                "assessments": [a.to_dict() for a in profile.assessments],
            }
        ),
        200,
    )
