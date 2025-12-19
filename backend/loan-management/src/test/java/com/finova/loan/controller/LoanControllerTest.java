package com.finova.loan.controller;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finova.loan.LoanManagementApplication;
import com.finova.loan.controller.LoanController;
import com.finova.loan.model.Loan;
import com.finova.loan.service.LoanService;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(LoanController.class)
@ContextConfiguration(classes = LoanManagementApplication.class)
public class LoanControllerTest {

  @Autowired private MockMvc mockMvc;

  @MockBean private LoanService loanService;

  // Helper to convert object to JSON string
  private static final ObjectMapper objectMapper = new ObjectMapper();

  private static String asJsonString(final Object obj) {
    try {
      return objectMapper.writeValueAsString(obj);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  @Test
  public void contextLoads() throws Exception {
    // Basic test to ensure the context loads and controller is wired
    assert (mockMvc != null);
  }

  @Test
  public void testGetLoanById() throws Exception {
    // Arrange
    Loan loan = new Loan();
    loan.setId(1L);
    loan.setAmount(new BigDecimal("5000.0"));
    loan.setStatus("APPROVED");

    when(loanService.getLoanById(1L)).thenReturn(loan);

    // Act & Assert
    mockMvc
        .perform(get("/loan/{id}", 1L).contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.amount", is(5000.0)))
        .andExpect(jsonPath("$.status", is("APPROVED")));

    verify(loanService, times(1)).getLoanById(1L);
  }

  @Test
  public void testGetAllLoans() throws Exception {
    // Arrange
    Loan loan1 = new Loan();
    loan1.setId(1L);
    loan1.setAmount(new BigDecimal("5000.0"));
    loan1.setStatus("APPROVED");

    Loan loan2 = new Loan();
    loan2.setId(2L);
    loan2.setAmount(new BigDecimal("10000.0"));
    loan2.setStatus("PENDING");

    List<Loan> loans = Arrays.asList(loan1, loan2);

    when(loanService.getAllLoans()).thenReturn(loans);

    // Act & Assert
    mockMvc
        .perform(get("/loan").contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(2)))
        .andExpect(jsonPath("$[0].status", is("APPROVED")))
        .andExpect(jsonPath("$[1].status", is("PENDING")));

    verify(loanService, times(1)).getAllLoans();
  }

  @Test
  public void testCreateLoan() throws Exception {
    // Arrange
    Loan loanToCreate = new Loan();
    loanToCreate.setAmount(new BigDecimal("7500.0"));
    loanToCreate.setCustomerId("123");

    Loan createdLoan = new Loan();
    createdLoan.setId(3L);
    createdLoan.setAmount(new BigDecimal("7500.0"));
    createdLoan.setCustomerId("123");
    createdLoan.setStatus("PENDING");

    when(loanService.createLoan(any(Loan.class))).thenReturn(createdLoan);

    // Act & Assert
    mockMvc
        .perform(
            post("/loan")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(loanToCreate)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(3)))
        .andExpect(jsonPath("$.status", is("PENDING")));

    verify(loanService, times(1)).createLoan(any(Loan.class));
  }

  @Test
  public void testUpdateLoan() throws Exception {
    // Arrange
    Loan loanUpdates = new Loan();
    loanUpdates.setStatus("REJECTED");

    Loan updatedLoan = new Loan();
    updatedLoan.setId(1L);
    updatedLoan.setAmount(new BigDecimal("5000.0"));
    updatedLoan.setStatus("REJECTED");

    when(loanService.updateLoan(eq(1L), any(Loan.class))).thenReturn(updatedLoan);

    // Act & Assert
    mockMvc
        .perform(
            put("/loan/{id}", 1L)
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(loanUpdates)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.status", is("REJECTED")));

    verify(loanService, times(1)).updateLoan(eq(1L), any(Loan.class));
  }

  @Test
  public void testDeleteLoan() throws Exception {
    // Arrange
    doNothing().when(loanService).deleteLoan(1L);

    // Act & Assert
    mockMvc.perform(delete("/loan/{id}", 1L)).andExpect(status().isOk());

    verify(loanService, times(1)).deleteLoan(1L);
  }
}
