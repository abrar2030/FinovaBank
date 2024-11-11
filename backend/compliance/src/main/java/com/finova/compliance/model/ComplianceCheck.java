package com.finova.compliance.model;

import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "compliance_check")
public class ComplianceCheck {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long accountId;
  private String checkType;
  private String status;
  private LocalDateTime timestamp;

  // Getters and Setters
}
