package com.finova.compliance.model;

import javax.persistence.*;
import java.time.LocalDateTime;

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
