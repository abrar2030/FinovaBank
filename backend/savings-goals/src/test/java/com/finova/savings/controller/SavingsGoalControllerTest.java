package com.finovabank.controllers;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finova.savings.SavingsGoalsApplication;
import com.finova.savings.controller.SavingsGoalController;
import com.finova.savings.model.SavingsGoal;
import com.finova.savings.service.SavingsGoalService;
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

@WebMvcTest(SavingsGoalController.class)
@ContextConfiguration(classes = SavingsGoalsApplication.class)
public class SavingsGoalControllerTest {

  @Autowired private MockMvc mockMvc;

  @MockBean private SavingsGoalService savingsGoalService;

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
  public void testGetSavingsGoalById() throws Exception {
    // Arrange
    SavingsGoal goal = new SavingsGoal();
    goal.setId(1L);
    goal.setName("Vacation Fund");
    goal.setTargetAmount(new BigDecimal("2000.0"));
    goal.setCurrentAmount(new BigDecimal("500.0"));

    when(savingsGoalService.getSavingsGoalById(1L)).thenReturn(goal);

    // Act & Assert
    mockMvc
        .perform(get("/savings/{id}", 1L).contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.name", is("Vacation Fund")))
        .andExpect(jsonPath("$.targetAmount", is(2000.0)));

    verify(savingsGoalService, times(1)).getSavingsGoalById(1L);
  }

  @Test
  public void testGetAllSavingsGoals() throws Exception {
    // Arrange
    SavingsGoal goal1 = new SavingsGoal();
    goal1.setId(1L);
    goal1.setName("Vacation");
    goal1.setTargetAmount(new BigDecimal("2000.0"));

    SavingsGoal goal2 = new SavingsGoal();
    goal2.setId(2L);
    goal2.setName("New Car");
    goal2.setTargetAmount(new BigDecimal("10000.0"));

    List<SavingsGoal> goals = Arrays.asList(goal1, goal2);

    when(savingsGoalService.getAllSavingsGoals()).thenReturn(goals);

    // Act & Assert
    mockMvc
        .perform(get("/savings").contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(2)))
        .andExpect(jsonPath("$[0].name", is("Vacation")))
        .andExpect(jsonPath("$[1].name", is("New Car")));

    verify(savingsGoalService, times(1)).getAllSavingsGoals();
  }

  @Test
  public void testCreateSavingsGoal() throws Exception {
    // Arrange
    SavingsGoal goalToCreate = new SavingsGoal();
    goalToCreate.setName("Emergency Fund");
    goalToCreate.setTargetAmount(new BigDecimal("5000.0"));
    goalToCreate.setCustomerId("123");

    SavingsGoal createdGoal = new SavingsGoal();
    createdGoal.setId(3L);
    createdGoal.setName("Emergency Fund");
    createdGoal.setTargetAmount(new BigDecimal("5000.0"));
    createdGoal.setCurrentAmount(new BigDecimal("0.0"));
    createdGoal.setCustomerId("123");

    when(savingsGoalService.createSavingsGoal(any(SavingsGoal.class))).thenReturn(createdGoal);

    // Act & Assert
    mockMvc
        .perform(
            post("/savings")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(goalToCreate)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(3)))
        .andExpect(jsonPath("$.name", is("Emergency Fund")));

    verify(savingsGoalService, times(1)).createSavingsGoal(any(SavingsGoal.class));
  }

  @Test
  public void testUpdateSavingsGoal() throws Exception {
    // Arrange
    SavingsGoal goalUpdates = new SavingsGoal();
    goalUpdates.setCurrentAmount(new BigDecimal("750.0"));

    SavingsGoal updatedGoal = new SavingsGoal();
    updatedGoal.setId(1L);
    updatedGoal.setName("Vacation Fund");
    updatedGoal.setTargetAmount(new BigDecimal("2000.0"));
    updatedGoal.setCurrentAmount(new BigDecimal("750.0"));

    when(savingsGoalService.updateSavingsGoal(eq(1L), any(SavingsGoal.class)))
        .thenReturn(updatedGoal);

    // Act & Assert
    mockMvc
        .perform(
            put("/savings/{id}", 1L)
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(goalUpdates)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id", is(1)))
        .andExpect(jsonPath("$.currentAmount", is(750.0)));

    verify(savingsGoalService, times(1)).updateSavingsGoal(eq(1L), any(SavingsGoal.class));
  }

  @Test
  public void testDeleteSavingsGoal() throws Exception {
    // Arrange
    doNothing().when(savingsGoalService).deleteSavingsGoal(1L);

    // Act & Assert
    mockMvc.perform(delete("/savings/{id}", 1L)).andExpect(status().isOk());

    verify(savingsGoalService, times(1)).deleteSavingsGoal(1L);
  }
}
