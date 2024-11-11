package com.finova.risk.service;

import com.finova.risk.model.RiskAssessment;
import java.util.List;

public interface RiskAssessmentService {
  RiskAssessment getRiskAssessmentById(Long id);

  List<RiskAssessment> getAllRiskAssessments();

  RiskAssessment createRiskAssessment(RiskAssessment riskAssessment);
}
