package com.finova.account;

import com.finova.account.model.Account;
import com.finova.account.service.AccountService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AccountServiceApplicationTests {

    @Autowired
    private AccountService accountService;

    @Test
    void contextLoads() {
    }

    @Test
    void testCreateAccount() {
        Account account = new Account();
        account.setName("Test User");
        account.setBalance(new BigDecimal("1000.00"));
        Account savedAccount = accountService.createAccount(account);
        assertNotNull(savedAccount);
        assertEquals("Test User", savedAccount.getName());
    }
}
