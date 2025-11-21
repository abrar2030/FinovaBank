package com.finovabank.controllers;

import static org.hamcrest.Matchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finova.transaction.controller.TransactionController;
import com.finova.transaction.model.Transaction;
import com.finova.transaction.service.TransactionService;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(TransactionController.class)
public class TransactionControllerTest {

  @Autowired private MockMvc mockMvc;

  @MockBean private TransactionService transactionService;

  // Helper to convert object to JSON string
  private static final ObjectMapper objectMapper = new ObjectMapper();

  static {
    objectMapper.findAndRegisterModules(); // Register modules like JavaTimeModule
  }

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
    assert (mockMvc != null);
  }

  @Test
  public void testGetTransactionById() throws Exception {
    // Arrange
    Transaction transaction = new Transaction(); // Assuming a default constructor and setters
    transaction.setId(1L);
    transaction.setAccountId(101L);
    transaction.setAmount(-50.0);
    transaction.setDescription("Coffee");
    // transaction.setTimestamp(LocalDateTime.now()); // Set based on actual model

    when(transactionService.getTransactionById(1L)).thenReturn(transaction);

    // Act & Assert
    mockMvc
        .perform(get("/transaction/{id}", 1L).contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.accountId", is(101)))
        .andExpect(jsonPath("$.amount", is(-50.0)))
        .andExpect(jsonPath("$.description", is("Coffee")));

    verify(transactionService, times(1)).getTransactionById(1L);
  }

  @Test
  public void testGetAllTransactions() throws Exception {
    // Arrange
    Transaction tx1 = new Transaction();
    tx1.setId(1L);
    tx1.setDescription("Coffee");
    tx1.setAmount(-50.0);
    Transaction tx2 = new Transaction();
    tx2.setId(2L);
    tx2.setDescription("Salary");
    tx2.setAmount(2000.0);
    List<Transaction> transactions = Arrays.asList(tx1, tx2);

    when(transactionService.getAllTransactions()).thenReturn(transactions);

    // Act & Assert
    mockMvc
        .perform(get("/transaction").contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(2)))
        .andExpect(jsonPath("$[0].description", is("Coffee")))
        .andExpect(jsonPath("$[1].description", is("Salary")));

    verify(transactionService, times(1)).getAllTransactions();
  }

  @Test
  public void testCreateTransaction() throws Exception {
    // Arrange
    Transaction transactionToCreate = new Transaction();
    transactionToCreate.setAccountId(102L);
    transactionToCreate.setAmount(100.0);
    transactionToCreate.setDescription("Grocery");

    Transaction createdTransaction = new Transaction();
    createdTransaction.setId(3L); // Assume service returns the created transaction with ID
    createdTransaction.setAccountId(102L);
    createdTransaction.setAmount(100.0);
    createdTransaction.setDescription("Grocery");
    // createdTransaction.setTimestamp(LocalDateTime.now());

    when(transactionService.createTransaction(any(Transaction.class)))
        .thenReturn(createdTransaction);

    // Act & Assert
    mockMvc
        .perform(
            post("/transaction")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(transactionToCreate)))
        .andExpect(status().isOk()) // Assuming 200 OK, could be 201 Created
        .andExpect(jsonPath("$.id", is(3)))
        .andExpect(jsonPath("$.description", is("Grocery")));

    verify(transactionService, times(1)).createTransaction(any(Transaction.class));
  }

  // NOTE: TransactionController provided does not have update or delete methods.
  // Tests for these are omitted.
}
