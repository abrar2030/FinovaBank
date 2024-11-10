package com.finova.risk.service.impl;

import com.finova.risk.model.RiskAssessment;
import com.finova.risk.repository.RiskAssessmentRepository;
import com.finova.risk.service.RiskAssessmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RiskAssessmentServiceImpl implements RiskAssessmentService {

    @Autowired
    private RiskAssessmentRepository riskAssessmentRepository;

    @Override
    public RiskAssessment getRiskAssessmentById(Long id) {
        return riskAssessmentRepository.findById(id).orElse(null);
    }

    @Override
    public List<RiskAssessment> getAllRiskAssessments() {
        return riskAssessmentRepository.findAll();
    }

    @Override
    public RiskAssessment createRiskAssessment(RiskAssessment riskAssessment) {
        return riskAssessmentRepository.save(riskAssessment);
    }
}
