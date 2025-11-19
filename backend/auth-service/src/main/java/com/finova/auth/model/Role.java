package com.finova.auth.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "roles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(unique = true, nullable = false)
    private RoleName name;

    @Column(length = 255)
    private String description;

    @ManyToMany(mappedBy = "roles")
    @Builder.Default
    private Set<User> users = new HashSet<>();

    public enum RoleName {
        ROLE_CUSTOMER,
        ROLE_EMPLOYEE,
        ROLE_MANAGER,
        ROLE_ADMIN,
        ROLE_COMPLIANCE_OFFICER,
        ROLE_RISK_ANALYST,
        ROLE_AUDITOR
    }
}
