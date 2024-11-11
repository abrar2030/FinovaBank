package com.finova.compliance.service;

import com.finova.compliance.model.ComplianceCheck;
import java.util.List;

public interface ComplianceService {
  ComplianceCheck getComplianceCheckById(Long id);

  List<ComplianceCheck> getAllComplianceChecks();

  ComplianceCheck createComplianceCheck(ComplianceCheck complianceCheck);
}
