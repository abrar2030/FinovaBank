package com.finova.compliance.controller;

import com.finova.compliance.model.ComplianceCheck;
import com.finova.compliance.service.ComplianceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/compliance")
public class ComplianceController {

    @Autowired
    private ComplianceService complianceService;

    @GetMapping("/{id}")
    public ComplianceCheck getComplianceCheckById(@PathVariable Long id) {
        return complianceService.getComplianceCheckById(id);
    }

    @GetMapping
    public List<ComplianceCheck> getAllComplianceChecks() {
        return complianceService.getAllComplianceChecks();
    }

    @PostMapping
    public ComplianceCheck createComplianceCheck(@RequestBody ComplianceCheck complianceCheck) {
        return complianceService.createComplianceCheck(complianceCheck);
    }
}
