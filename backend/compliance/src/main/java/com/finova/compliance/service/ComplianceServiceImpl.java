package com.finova.compliance.service.impl;

import com.finova.compliance.model.ComplianceCheck;
import com.finova.compliance.repository.ComplianceRepository;
import com.finova.compliance.service.ComplianceService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ComplianceServiceImpl implements ComplianceService {

  @Autowired private ComplianceRepository complianceRepository;

  @Override
  public ComplianceCheck getComplianceCheckById(Long id) {
    return complianceRepository.findById(id).orElse(null);
  }

  @Override
  public List<ComplianceCheck> getAllComplianceChecks() {
    return complianceRepository.findAll();
  }

  @Override
  public ComplianceCheck createComplianceCheck(ComplianceCheck complianceCheck) {
    return complianceRepository.save(complianceCheck);
  }
}
