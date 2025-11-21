package com.finovabank.repositories;

import static org.junit.jupiter.api.Assertions.*;

import com.finova.loan.LoanManagementApplication;
import com.finova.loan.model.Loan;
import com.finova.loan.repository.LoanRepository;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ContextConfiguration;

@DataJpaTest
@ContextConfiguration(classes = LoanManagementApplication.class)
public class LoanRepositoryTest {

  @Autowired private LoanRepository loanRepository;

  @Test
  public void testSaveAndFindLoan() {
    // Create a test loan
    Loan loan = new Loan();
    loan.setLoanNumber("LOAN123456");
    loan.setAmount(new BigDecimal("10000.00"));
    loan.setInterestRate(new BigDecimal("5.25"));
    loan.setTermMonths(36);
    loan.setCustomerId("customer123");
    loan.setStatus("PENDING");

    // Save the loan
    Loan savedLoan = loanRepository.save(loan);

    // Verify the loan was saved with an ID
    assertNotNull(savedLoan.getId());
  }
}
