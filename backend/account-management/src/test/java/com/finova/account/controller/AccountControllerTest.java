package com.finovabank.controllers;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finova.account.AccountManagementApplication;
import com.finova.account.controller.AccountController;
import com.finova.account.model.Account;
import com.finova.account.service.AccountService;
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

@WebMvcTest(AccountController.class)
@ContextConfiguration(classes = AccountManagementApplication.class)
public class AccountControllerTest {

  @Autowired private MockMvc mockMvc;

  @MockBean private AccountService accountService;

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
  public void testGetAccountById() throws Exception {
    // Arrange
    Account account = new Account();
    account.setId(1L);
    account.setAccountNumber("1234567890");
    account.setBalance(new BigDecimal("1000.0"));

    when(accountService.getAccountById(1L)).thenReturn(account);

    // Act & Assert
    mockMvc
        .perform(get("/account/{id}", 1L).contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.accountNumber", is("1234567890")))
        .andExpect(jsonPath("$.balance", is(1000.0)));

    verify(accountService, times(1)).getAccountById(1L);
  }

  @Test
  public void testGetAllAccounts() throws Exception {
    // Arrange
    Account account1 = new Account();
    account1.setId(1L);
    account1.setAccountNumber("111");
    account1.setBalance(new BigDecimal("100.0"));

    Account account2 = new Account();
    account2.setId(2L);
    account2.setAccountNumber("222");
    account2.setBalance(new BigDecimal("200.0"));

    List<Account> accounts = Arrays.asList(account1, account2);

    when(accountService.getAllAccounts()).thenReturn(accounts);

    // Act & Assert
    mockMvc
        .perform(get("/account").contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(2)))
        .andExpect(jsonPath("$[0].accountNumber", is("111")))
        .andExpect(jsonPath("$[1].accountNumber", is("222")));

    verify(accountService, times(1)).getAllAccounts();
  }

  @Test
  public void testCreateAccount() throws Exception {
    // Arrange
    Account accountToCreate = new Account();
    accountToCreate.setAccountNumber("9876543210");
    accountToCreate.setBalance(new BigDecimal("50.0"));

    Account createdAccount = new Account();
    createdAccount.setId(2L);
    createdAccount.setAccountNumber("9876543210");
    createdAccount.setBalance(new BigDecimal("50.0"));

    when(accountService.createAccount(any(Account.class))).thenReturn(createdAccount);

    // Act & Assert
    mockMvc
        .perform(
            post("/account")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(accountToCreate)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(2)))
        .andExpect(jsonPath("$.accountNumber", is("9876543210")));

    verify(accountService, times(1)).createAccount(any(Account.class));
  }

  @Test
  public void testUpdateAccount() throws Exception {
    // Arrange
    Account accountUpdates = new Account();
    accountUpdates.setBalance(new BigDecimal("1500.0"));

    Account updatedAccount = new Account();
    updatedAccount.setId(1L);
    updatedAccount.setAccountNumber("1234567890");
    updatedAccount.setBalance(new BigDecimal("1500.0"));

    when(accountService.updateAccount(eq(1L), any(Account.class))).thenReturn(updatedAccount);

    // Act & Assert
    mockMvc
        .perform(
            put("/account/{id}", 1L)
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(accountUpdates)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.balance", is(1500.0)));

    verify(accountService, times(1)).updateAccount(eq(1L), any(Account.class));
  }

  @Test
  public void testDeleteAccount() throws Exception {
    // Arrange
    doNothing().when(accountService).deleteAccount(1L);

    // Act & Assert
    mockMvc.perform(delete("/account/{id}", 1L)).andExpect(status().isOk());

    verify(accountService, times(1)).deleteAccount(1L);
  }
}
