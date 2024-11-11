package com.finova.transaction.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "transaction")
public class Transaction {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private BigDecimal amount;
  private String type;
  private LocalDateTime timestamp;

  // Getters and Setters
}
