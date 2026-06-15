"""SQLAlchemy models for the risk-assessment service.

These mirror the schema in
infrastructure/database/migrations/postgres/risk/V1__Initial_Schema.sql so the
service is coherent with the existing infrastructure: a risk_profiles table
keyed by customer, and a risk_assessments history table recording score
changes.
"""

from datetime import datetime, timezone

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


def _utcnow():
    return datetime.now(timezone.utc)


class RiskProfile(db.Model):
    __tablename__ = "risk_profiles"

    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.String(36), unique=True, nullable=False, index=True)
    risk_score = db.Column(db.Integer, nullable=False)
    credit_score = db.Column(db.Integer, nullable=True)
    fraud_likelihood = db.Column(db.String(10), nullable=False, default="LOW")
    last_assessment_date = db.Column(db.DateTime, nullable=False, default=_utcnow)
    created_at = db.Column(db.DateTime, nullable=False, default=_utcnow)
    updated_at = db.Column(
        db.DateTime, nullable=False, default=_utcnow, onupdate=_utcnow
    )

    assessments = db.relationship(
        "RiskAssessment",
        backref="profile",
        cascade="all, delete-orphan",
        order_by="RiskAssessment.assessed_at.desc()",
    )

    def to_dict(self):
        return {
            "id": self.id,
            "customer_id": self.customer_id,
            "risk_score": self.risk_score,
            "credit_score": self.credit_score,
            "fraud_likelihood": self.fraud_likelihood,
            "last_assessment_date": (
                self.last_assessment_date.isoformat()
                if self.last_assessment_date
                else None
            ),
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class RiskAssessment(db.Model):
    __tablename__ = "risk_assessments"

    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(
        db.Integer,
        db.ForeignKey("risk_profiles.id", ondelete="CASCADE"),
        nullable=False,
    )
    previous_score = db.Column(db.Integer, nullable=True)
    new_score = db.Column(db.Integer, nullable=False)
    assessment_reason = db.Column(db.Text, nullable=False)
    assessed_by = db.Column(db.String(50), nullable=False)
    assessed_at = db.Column(db.DateTime, nullable=False, default=_utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "profile_id": self.profile_id,
            "previous_score": self.previous_score,
            "new_score": self.new_score,
            "assessment_reason": self.assessment_reason,
            "assessed_by": self.assessed_by,
            "assessed_at": self.assessed_at.isoformat() if self.assessed_at else None,
        }


# Valid fraud likelihood values, matching the CHECK constraint in the migration.
FRAUD_LIKELIHOOD_VALUES = ("LOW", "MEDIUM", "HIGH", "CRITICAL")
