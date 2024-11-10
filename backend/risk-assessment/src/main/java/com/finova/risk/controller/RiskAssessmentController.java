package com.finova.risk.controller;

import com.finova.risk.model.RiskAssessment;
import com.finova.risk.service.RiskAssessmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/risk")
public class RiskAssessmentController {

    @Autowired
    private RiskAssessmentService riskAssessmentService;

    @GetMapping("/{id}")
    public RiskAssessment getRiskAssessmentById(@PathVariable Long id) {
        return riskAssessmentService.getRiskAssessmentById(id);
    }

    @GetMapping
    public List<RiskAssessment> getAllRiskAssessments() {
        return riskAssessmentService.getAllRiskAssessments();
    }

    @PostMapping
    public RiskAssessment createRiskAssessment(@RequestBody RiskAssessment riskAssessment) {
        return riskAssessmentService.createRiskAssessment(riskAssessment);
    }
}
