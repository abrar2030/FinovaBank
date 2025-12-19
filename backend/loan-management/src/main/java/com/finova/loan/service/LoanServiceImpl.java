package com.finova.loan.service;

import com.finova.loan.model.Loan;
import com.finova.loan.repository.LoanRepository;
import com.finova.loan.service.LoanService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LoanServiceImpl implements LoanService {

  @Autowired private LoanRepository loanRepository;

  @Override
  public Loan getLoanById(Long id) {
    return loanRepository.findById(id).orElse(null);
  }

  @Override
  public List<Loan> getAllLoans() {
    return loanRepository.findAll();
  }

  @Override
  public Loan createLoan(Loan loan) {
    return loanRepository.save(loan);
  }

  @Override
  public Loan updateLoan(Long id, Loan loan) {
    Loan existingLoan = loanRepository.findById(id).orElse(null);
    if (existingLoan != null) {
      existingLoan.setAmount(loan.getAmount());
      existingLoan.setInterestRate(loan.getInterestRate());
      existingLoan.setStartDate(loan.getStartDate());
      existingLoan.setEndDate(loan.getEndDate());
      existingLoan.setStatus(loan.getStatus());
      return loanRepository.save(existingLoan);
    }
    return null;
  }

  @Override
  public void deleteLoan(Long id) {
    loanRepository.deleteById(id);
  }
}
