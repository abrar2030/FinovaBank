package com.finova.account.repository;

import static org.junit.jupiter.api.Assertions.*;

import com.finova.account.AccountManagementApplication;
import com.finova.account.model.Account;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ContextConfiguration;

@DataJpaTest
@ContextConfiguration(classes = AccountManagementApplication.class)
public class AccountRepositoryTest {

  @Autowired private AccountRepository accountRepository;

  @Test
  public void testSaveAndFindAccount() {
    // Create a test account
    Account account = new Account();
    account.setAccountNumber("TEST123456");
    account.setBalance(new BigDecimal("1000.00"));
    account.setCustomerId("customer123");

    // Save the account
    Account savedAccount = accountRepository.save(account);

    // Verify the account was saved with an ID
    assertNotNull(savedAccount.getId());

    // Find the account by ID
    Optional<Account> foundAccount = accountRepository.findById(savedAccount.getId());

    // Verify the account was found
    assertTrue(foundAccount.isPresent());
    assertEquals("TEST123456", foundAccount.get().getAccountNumber());
    assertEquals(0, new BigDecimal("1000.00").compareTo(foundAccount.get().getBalance()));
    assertEquals("customer123", foundAccount.get().getCustomerId());
  }

  @Test
  public void testFindByCustomerId() {
    // Create test accounts
    Account account1 = new Account();
    account1.setAccountNumber("ACC1");
    account1.setBalance(new BigDecimal("1000.00"));
    account1.setCustomerId("customer123");

    Account account2 = new Account();
    account2.setAccountNumber("ACC2");
    account2.setBalance(new BigDecimal("2000.00"));
    account2.setCustomerId("customer123");

    Account account3 = new Account();
    account3.setAccountNumber("ACC3");
    account3.setBalance(new BigDecimal("3000.00"));
    account3.setCustomerId("customer456");

    // Save the accounts
    accountRepository.save(account1);
    accountRepository.save(account2);
    accountRepository.save(account3);

    // Find accounts by customer ID
    List<Account> customerAccounts = accountRepository.findByCustomerId("customer123");

    // Verify the correct accounts were found
    assertEquals(2, customerAccounts.size());
    assertTrue(customerAccounts.stream().anyMatch(a -> a.getAccountNumber().equals("ACC1")));
    assertTrue(customerAccounts.stream().anyMatch(a -> a.getAccountNumber().equals("ACC2")));
  }
}
