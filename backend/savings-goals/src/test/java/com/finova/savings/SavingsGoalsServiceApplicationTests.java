package com.finova.savings;

import com.finova.savings.model.SavingsGoal;
import com.finova.savings.service.SavingsGoalService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class SavingsGoalsServiceApplicationTests {

    @Autowired
    private SavingsGoalService savingsGoalService;

    @Test
    void contextLoads() {
    }

    @Test
    void testCreateSavingsGoal() {
        SavingsGoal goal = new SavingsGoal();
        goal.setAccountId(1L);
        goal.setGoalName("Vacation");
        goal.setTargetAmount(new BigDecimal("5000.00"));
        goal.setCurrentAmount(new BigDecimal("1000.00"));

        SavingsGoal savedGoal = savingsGoalService.createSavingsGoal(goal);
        assertNotNull(savedGoal);
        assertEquals("Vacation", savedGoal.getGoalName());
    }
}
