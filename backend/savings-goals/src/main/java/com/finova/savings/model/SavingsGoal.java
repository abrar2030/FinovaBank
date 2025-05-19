package com.finova.savings.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import javax.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "savings_goal")
public class SavingsGoal {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private String name;
  private String goalName;
  private BigDecimal targetAmount;
  private BigDecimal currentAmount;
  private LocalDate targetDate;
  private String customerId;
  private String status;

  // Getters and Setters
}
