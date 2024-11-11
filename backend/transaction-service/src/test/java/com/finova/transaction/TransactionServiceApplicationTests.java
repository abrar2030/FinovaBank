package com.finova.transaction;

import static org.junit.jupiter.api.Assertions.*;

import com.finova.transaction.model.Transaction;
import com.finova.transaction.service.TransactionService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class TransactionServiceApplicationTests {

  @Autowired private TransactionService transactionService;

  @Test
  void contextLoads() {}

  @Test
  void testCreateTransaction() {
    Transaction transaction = new Transaction();
    transaction.setAccountId(1L);
    transaction.setAmount(new BigDecimal("200.00"));
    transaction.setType("DEPOSIT");
    transaction.setTimestamp(LocalDateTime.now());

    Transaction savedTransaction = transactionService.createTransaction(transaction);
    assertNotNull(savedTransaction);
    assertEquals("DEPOSIT", savedTransaction.getType());
  }
}
