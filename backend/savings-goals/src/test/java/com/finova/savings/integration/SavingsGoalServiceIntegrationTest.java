package com.finova.savings.integration;

import com.finova.savings.SavingsGoalsApplication;
import com.finova.savings.model.SavingsGoal;
import com.finova.savings.service.SavingsGoalService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(classes = SavingsGoalsApplication.class)
@TestPropertySource(properties = {
    "eureka.client.enabled=false",
    "eureka.client.register-with-eureka=false",
    "eureka.client.fetch-registry=false"
})
public class SavingsGoalServiceIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private SavingsGoalService savingsGoalService;

    @Test
    public void testCreateAndGetSavingsGoal() {
        // Create a test savings goal
        SavingsGoal savingsGoal = new SavingsGoal();
        savingsGoal.setName("Vacation Fund");
        savingsGoal.setTargetAmount(new BigDecimal("5000.00"));
        savingsGoal.setCurrentAmount(new BigDecimal("1000.00"));
        savingsGoal.setTargetDate(LocalDate.now().plusMonths(6));
        savingsGoal.setCustomerId("customer123");
        
        SavingsGoal savedGoal = savingsGoalService.createSavingsGoal(savingsGoal);
        
        // Verify the savings goal was created
        assertNotNull(savedGoal.getId());
        
        // Retrieve the savings goal
        SavingsGoal retrievedGoal = savingsGoalService.getSavingsGoalById(savedGoal.getId());
        
        // Verify retrieved savings goal matches
        assertEquals(savedGoal.getId(), retrievedGoal.getId());
        assertEquals("Vacation Fund", retrievedGoal.getName());
        assertEquals(0, new BigDecimal("5000.00").compareTo(retrievedGoal.getTargetAmount()));
        assertEquals(0, new BigDecimal("1000.00").compareTo(retrievedGoal.getCurrentAmount()));
        assertEquals("customer123", retrievedGoal.getCustomerId());
    }
}
