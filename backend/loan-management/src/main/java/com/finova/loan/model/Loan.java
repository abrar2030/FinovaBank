package com.finova.loan.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import javax.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "loan")
public class Loan {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String loanNumber;
  private Long accountId;
  private String customerId;
  private BigDecimal amount;
  private BigDecimal interestRate;
  private Integer termMonths;
  private LocalDateTime startDate;
  private LocalDateTime endDate;
  private String status;
  private String purpose;

  // Getters and Setters
}
