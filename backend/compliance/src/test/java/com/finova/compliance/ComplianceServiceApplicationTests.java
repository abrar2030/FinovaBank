package com.finova.compliance;

import static org.junit.jupiter.api.Assertions.*;

import com.finova.compliance.model.ComplianceCheck;
import com.finova.compliance.service.ComplianceService;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class ComplianceServiceApplicationTests {

  @Autowired private ComplianceService complianceService;

  @Test
  void contextLoads() {}

  @Test
  void testCreateComplianceCheck() {
    ComplianceCheck complianceCheck = new ComplianceCheck();
    complianceCheck.setAccountId(1L);
    complianceCheck.setCheckType("AML");
    complianceCheck.setStatus("PASSED");
    complianceCheck.setTimestamp(LocalDateTime.now());

    ComplianceCheck savedCheck = complianceService.createComplianceCheck(complianceCheck);
    assertNotNull(savedCheck);
    assertEquals("PASSED", savedCheck.getStatus());
  }
}
