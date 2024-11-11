package com.finova.transaction.service.impl;

import com.finova.transaction.model.Transaction;
import com.finova.transaction.repository.TransactionRepository;
import com.finova.transaction.service.TransactionService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TransactionServiceImpl implements TransactionService {

  @Autowired private TransactionRepository transactionRepository;

  @Override
  public Transaction getTransactionById(Long id) {
    return transactionRepository.findById(id).orElse(null);
  }

  @Override
  public List<Transaction> getAllTransactions() {
    return transactionRepository.findAll();
  }

  @Override
  public Transaction createTransaction(Transaction transaction) {
    return transactionRepository.save(transaction);
  }
}
