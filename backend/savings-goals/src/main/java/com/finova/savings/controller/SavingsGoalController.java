package com.finova.savings.controller;

import com.finova.savings.model.SavingsGoal;
import com.finova.savings.service.SavingsGoalService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/savings")
public class SavingsGoalController {

  @Autowired private SavingsGoalService savingsGoalService;

  @GetMapping("/{id}")
  public SavingsGoal getSavingsGoalById(@PathVariable Long id) {
    return savingsGoalService.getSavingsGoalById(id);
  }

  @GetMapping
  public List<SavingsGoal> getAllSavingsGoals() {
    return savingsGoalService.getAllSavingsGoals();
  }

  @PostMapping
  public SavingsGoal createSavingsGoal(@RequestBody SavingsGoal savingsGoal) {
    return savingsGoalService.createSavingsGoal(savingsGoal);
  }

  @PutMapping("/{id}")
  public SavingsGoal updateSavingsGoal(
      @PathVariable Long id, @RequestBody SavingsGoal savingsGoal) {
    return savingsGoalService.updateSavingsGoal(id, savingsGoal);
  }

  @DeleteMapping("/{id}")
  public void deleteSavingsGoal(@PathVariable Long id) {
    savingsGoalService.deleteSavingsGoal(id);
  }
}
