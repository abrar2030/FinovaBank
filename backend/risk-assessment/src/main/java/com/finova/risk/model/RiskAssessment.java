package com.finova.risk.model;

import java.math.BigDecimal;
import javax.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "risk_assessment")
@Getter
@Setter
@NoArgsConstructor
public class RiskAssessment {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private BigDecimal creditScore;
  private BigDecimal riskFactor;
  private String riskLevel;
}
