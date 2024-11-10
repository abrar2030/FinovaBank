package com.finova.savings.model;

import javax.persistence.*;
import java.math.BigDecimal;

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
