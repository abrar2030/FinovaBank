package com.finova.loan.integration;

import com.finova.loan.LoanManagementApplication;
import com.finova.loan.model.Loan;
import com.finova.loan.service.LoanService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ContextConfiguration(classes = LoanManagementApplication.class)
public class LoanServiceIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private LoanService loanService;

    @Test
    public void testCreateAndGetLoan() {
        // Create a test loan
        Loan loan = new Loan();
        loan.setLoanNumber("LOAN123456");
        loan.setAmount(new BigDecimal("10000.00"));
        loan.setInterestRate(new BigDecimal("5.25"));
        loan.setTermMonths(36);
        loan.setCustomerId("customer123");

        Loan savedLoan = loanService.createLoan(loan);

        // Verify the loan was created
        assertNotNull(savedLoan.getId());

        // Retrieve the loan
        Loan retrievedLoan = loanService.getLoanById(savedLoan.getId());

        // Verify retrieved loan matches
        assertEquals(savedLoan.getId(), retrievedLoan.getId());
        assertEquals("LOAN123456", retrievedLoan.getLoanNumber());
        assertEquals(0, new BigDecimal("10000.00").compareTo(retrievedLoan.getAmount()));
        assertEquals(0, new BigDecimal("5.25").compareTo(retrievedLoan.getInterestRate()));
        assertEquals(36, retrievedLoan.getTermMonths());
        assertEquals("customer123", retrievedLoan.getCustomerId());
    }
}
