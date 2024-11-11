package com.finova.compliance.repository;

import com.finova.compliance.model.ComplianceCheck;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ComplianceRepository extends JpaRepository<ComplianceCheck, Long> {}
