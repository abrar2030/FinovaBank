package com.finova.loan.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "loan")
public class Loan {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private BigDecimal amount;
  private BigDecimal interestRate;
  private LocalDateTime startDate;
  private LocalDateTime endDate;
  private String status;

  // Getters and Setters
}
