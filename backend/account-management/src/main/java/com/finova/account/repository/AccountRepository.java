package com.finova.account.repository;

import com.finova.account.model.Account;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountRepository extends JpaRepository<Account, Long> {
  List<Account> findByCustomerId(String customerId);
}
