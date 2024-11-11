package com.finova.savings.model;

import java.math.BigDecimal;
import javax.persistence.*;

@Entity
@Table(name = "savings_goal")
public class SavingsGoal {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private String goalName;
  private BigDecimal targetAmount;
  private BigDecimal currentAmount;

  // Getters and Setters
}
