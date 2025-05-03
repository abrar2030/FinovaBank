package com.finovabank.controllers;

import com.fasterxml.jackson.databind.ObjectMapper; // Added for JSON conversion
import com.finova.loan.controller.LoanController; // Corrected import
import com.finova.loan.model.Loan; // Assuming model exists and has necessary fields/methods
import com.finova.loan.service.LoanService; // Corrected import
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

// Import static methods for MockMvc request builders and result matchers
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.mockito.Mockito.*;
import static org.hamcrest.Matchers.*;

@WebMvcTest(LoanController.class) // Uncommented and corrected class
public class LoanControllerTest {

    @Autowired // Uncommented
    private MockMvc mockMvc;

    @MockBean // Uncommented
    private LoanService loanService;

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
    public void contextLoads() throws Exception { // Added throws Exception
        // Basic test to ensure the context loads and controller is wired
        assert(mockMvc != null);
    }

    @Test
    public void testGetLoanById() throws Exception {
        // Arrange
        Loan loan = new Loan(); // Assuming a default constructor and setters
        loan.setId(1L);
        loan.setAmount(5000.0);
        loan.setStatus("APPROVED"); // Example property

        when(loanService.getLoanById(1L)).thenReturn(loan);

        // Act & Assert
        mockMvc.perform(get("/loan/{id}", 1L)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.amount", is(5000.0)))
                .andExpect(jsonPath("$.status", is("APPROVED")));

        verify(loanService, times(1)).getLoanById(1L);
    }

    @Test
    public void testGetAllLoans() throws Exception {
        // Arrange
        Loan loan1 = new Loan(); loan1.setId(1L); loan1.setAmount(5000.0); loan1.setStatus("APPROVED");
        Loan loan2 = new Loan(); loan2.setId(2L); loan2.setAmount(10000.0); loan2.setStatus("PENDING");
        List<Loan> loans = Arrays.asList(loan1, loan2);

        when(loanService.getAllLoans()).thenReturn(loans);

        // Act & Assert
        mockMvc.perform(get("/loan")
                .contentType(MediaType.APPLICATION_JSON))
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
        loanToCreate.setAmount(7500.0);
        loanToCreate.setUserId(123L); // Example property

        Loan createdLoan = new Loan();
        createdLoan.setId(3L); // Assume service returns the created loan with ID
        createdLoan.setAmount(7500.0);
        createdLoan.setUserId(123L);
        createdLoan.setStatus("PENDING"); // Default status

        when(loanService.createLoan(any(Loan.class))).thenReturn(createdLoan);

        // Act & Assert
        mockMvc.perform(post("/loan")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(loanToCreate)))
                .andExpect(status().isOk()) // Assuming 200 OK, could be 201 Created
                .andExpect(jsonPath("$.id", is(3)))
                .andExpect(jsonPath("$.status", is("PENDING")));

        verify(loanService, times(1)).createLoan(any(Loan.class));
    }

    @Test
    public void testUpdateLoan() throws Exception {
        // Arrange
        Loan loanUpdates = new Loan();
        loanUpdates.setStatus("REJECTED"); // Only updating status

        Loan updatedLoan = new Loan();
        updatedLoan.setId(1L);
        updatedLoan.setAmount(5000.0);
        updatedLoan.setStatus("REJECTED");

        when(loanService.updateLoan(eq(1L), any(Loan.class))).thenReturn(updatedLoan);

        // Act & Assert
        mockMvc.perform(put("/loan/{id}", 1L)
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
        mockMvc.perform(delete("/loan/{id}", 1L))
                .andExpect(status().isOk()); // Assuming 200 OK on delete

        verify(loanService, times(1)).deleteLoan(1L);
    }
}

