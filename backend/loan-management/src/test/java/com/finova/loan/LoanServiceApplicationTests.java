package com.finova.loan;

import com.finova.loan.model.Loan;
import com.finova.loan.service.LoanService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class LoanServiceApplicationTests {

    @Autowired
    private LoanService loanService;

    @Test
    void contextLoads() {
    }

    @Test
    void testCreateLoan() {
        Loan loan = new Loan();
        loan.setAccountId(1L);
        loan.setAmount(new BigDecimal("5000.00"));
        loan.setInterestRate(new BigDecimal("3.5"));
        loan.setStartDate(LocalDateTime.now());
        loan.setEndDate(LocalDateTime.now().plusYears(1));
        loan.setStatus("APPROVED");

        Loan savedLoan = loanService.createLoan(loan);
        assertNotNull(savedLoan);
        assertEquals("APPROVED", savedLoan.getStatus());
    }
}
