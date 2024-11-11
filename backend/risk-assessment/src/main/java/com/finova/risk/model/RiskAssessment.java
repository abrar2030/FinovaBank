package com.finova.risk.model;

import java.math.BigDecimal;
import javax.persistence.*;

@Entity
@Table(name = "risk_assessment")
public class RiskAssessment {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private BigDecimal creditScore;
  private BigDecimal riskFactor;
  private String riskLevel;

  // Getters and Setters
}
