package com.finova.account.service.impl;

import com.finova.account.model.Account;
import com.finova.account.repository.AccountRepository;
import com.finova.account.service.AccountService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AccountServiceImpl implements AccountService {

  @Autowired private AccountRepository accountRepository;

  @Override
  public Account getAccountById(Long id) {
    return accountRepository.findById(id).orElse(null);
  }

  @Override
  public List<Account> getAllAccounts() {
    return accountRepository.findAll();
  }

  @Override
  public Account createAccount(Account account) {
    return accountRepository.save(account);
  }

  @Override
  public Account updateAccount(Long id, Account account) {
    Account existingAccount = accountRepository.findById(id).orElse(null);
    if (existingAccount != null) {
      // Use Lombok's generated methods to set name and balance
      existingAccount.setName(account.getName());
      existingAccount.setBalance(account.getBalance());
      return accountRepository.save(existingAccount);
    }
    return null;
  }

  @Override
  public void deleteAccount(Long id) {
    accountRepository.deleteById(id);
  }
}
