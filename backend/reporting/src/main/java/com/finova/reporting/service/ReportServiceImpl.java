package com.finova.reporting.service.impl;

import com.finova.reporting.model.Report;
import com.finova.reporting.repository.ReportRepository;
import com.finova.reporting.service.ReportService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ReportServiceImpl implements ReportService {

  @Autowired private ReportRepository reportRepository;

  @Override
  public Report getReportById(Long id) {
    return reportRepository.findById(id).orElse(null);
  }

  @Override
  public List<Report> getAllReports() {
    return reportRepository.findAll();
  }

  @Override
  public Report createReport(Report report) {
    return reportRepository.save(report);
  }
}
