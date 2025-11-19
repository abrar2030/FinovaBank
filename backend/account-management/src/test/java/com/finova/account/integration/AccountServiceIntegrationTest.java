package com.finova.account.integration;

import com.finova.account.model.Account;
import com.finova.account.service.AccountService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class AccountServiceIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private AccountService accountService;

    @Test
    public void testCreateAndGetAccount() {
        // Create a test account
        Account account = new Account();
        account.setAccountNumber("TEST123456");
        account.setBalance(new BigDecimal("1000.00"));
        account.setCustomerId("customer123");

        Account savedAccount = accountService.createAccount(account);

        // Verify the account was created
        assertNotNull(savedAccount.getId());

        // Retrieve the account
        Account retrievedAccount = accountService.getAccountById(savedAccount.getId());

        // Verify retrieved account matches
        assertEquals(savedAccount.getId(), retrievedAccount.getId());
        assertEquals("TEST123456", retrievedAccount.getAccountNumber());
        // Use compareTo for BigDecimal to avoid scale issues
        assertEquals(0, new BigDecimal("1000.00").compareTo(retrievedAccount.getBalance()));
        assertEquals("customer123", retrievedAccount.getCustomerId());
    }
}
