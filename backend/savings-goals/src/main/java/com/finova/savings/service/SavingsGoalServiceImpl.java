package com.finova.savings.service.impl;

import com.finova.savings.model.SavingsGoal;
import com.finova.savings.repository.SavingsGoalRepository;
import com.finova.savings.service.SavingsGoalService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SavingsGoalServiceImpl implements SavingsGoalService {

  @Autowired private SavingsGoalRepository savingsGoalRepository;

  @Override
  public SavingsGoal getSavingsGoalById(Long id) {
    return savingsGoalRepository.findById(id).orElse(null);
  }

  @Override
  public List<SavingsGoal> getAllSavingsGoals() {
    return savingsGoalRepository.findAll();
  }

  @Override
  public SavingsGoal createSavingsGoal(SavingsGoal savingsGoal) {
    return savingsGoalRepository.save(savingsGoal);
  }

  @Override
  public SavingsGoal updateSavingsGoal(Long id, SavingsGoal savingsGoal) {
    SavingsGoal existingGoal = savingsGoalRepository.findById(id).orElse(null);
    if (existingGoal != null) {
      existingGoal.setGoalName(savingsGoal.getGoalName());
      existingGoal.setTargetAmount(savingsGoal.getTargetAmount());
      existingGoal.setCurrentAmount(savingsGoal.getCurrentAmount());
      return savingsGoalRepository.save(existingGoal);
    }
    return null;
  }

  @Override
  public void deleteSavingsGoal(Long id) {
    savingsGoalRepository.deleteById(id);
  }
}
