package com.finova.account.repository;

import com.finova.account.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AccountRepository extends JpaRepository<Account, Long> {
    List<Account> findByCustomerId(String customerId);
}
