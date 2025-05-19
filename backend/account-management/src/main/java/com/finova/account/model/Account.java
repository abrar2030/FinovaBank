package com.finova.account.model;

import java.math.BigDecimal;
import javax.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "account")
public class Account {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String name;
  private BigDecimal balance;
  private String accountNumber;
  private String customerId;
  private String accountType;
  private String status;

  // Getters and Setters
}
