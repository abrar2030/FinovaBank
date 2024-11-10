package com.finova.reporting;

import com.finova.reporting.model.Report;
import com.finova.reporting.service.ReportService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class ReportingServiceApplicationTests {

    @Autowired
    private ReportService reportService;

    @Test
    void contextLoads() {
    }

    @Test
    void testCreateReport() {
        Report report = new Report();
        report.setAccountId(1L);
        report.setReportType("TRANSACTION_SUMMARY");
        report.setDetails("Summary of transactions for Q1.");
        report.setGeneratedAt(LocalDateTime.now());

        Report savedReport = reportService.createReport(report);
        assertNotNull(savedReport);
        assertEquals("TRANSACTION_SUMMARY", savedReport.getReportType());
    }
}
