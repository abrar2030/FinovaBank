package com.finova.account.model;

import java.math.BigDecimal;
import javax.persistence.*;

@Entity
@Table(name = "account")
public class Account {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String name;
  private BigDecimal balance;

  // Getters and Setters
}
