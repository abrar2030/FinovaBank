package com.finova.risk;

import com.finova.risk.model.RiskAssessment;
import com.finova.risk.service.RiskAssessmentService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class RiskAssessmentServiceApplicationTests {

    @Autowired
    private RiskAssessmentService riskAssessmentService;

    @Test
    void contextLoads() {
    }

    @Test
    void testCreateRiskAssessment() {
        RiskAssessment riskAssessment = new RiskAssessment();
        riskAssessment.setAccountId(1L);
        riskAssessment.setCreditScore(new BigDecimal("750.00"));
        riskAssessment.setRiskFactor(new BigDecimal("1.2"));
        riskAssessment.setRiskLevel("LOW");

        RiskAssessment savedRiskAssessment = riskAssessmentService.createRiskAssessment(riskAssessment);
        assertNotNull(savedRiskAssessment);
        assertEquals("LOW", savedRiskAssessment.getRiskLevel());
    }
}
