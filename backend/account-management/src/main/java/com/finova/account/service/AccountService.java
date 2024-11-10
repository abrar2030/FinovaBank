package com.finova.account.service;

import com.finova.account.model.Account;
import java.util.List;

public interface AccountService {
    Account getAccountById(Long id);
    List<Account> getAllAccounts();
    Account createAccount(Account account);
    Account updateAccount(Long id, Account account);
    void deleteAccount(Long id);
}
