package com.finova.reporting.model;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "report")
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long accountId;
    private String reportType;
    private String details;
    private LocalDateTime generatedAt;

    // Getters and Setters
}