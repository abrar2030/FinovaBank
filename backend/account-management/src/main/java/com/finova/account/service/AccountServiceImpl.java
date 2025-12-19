package com.finova.account.service;

import com.finova.account.dto.AccountCreateRequest;
import com.finova.account.dto.AccountResponse;
import com.finova.account.dto.AccountUpdateRequest;
import com.finova.account.dto.BalanceUpdateRequest;
import com.finova.account.model.Account;
import com.finova.account.repository.AccountRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AccountServiceImpl implements AccountService {

  private final AccountRepository accountRepository;
  private final Random random = new Random();

  @Override
  @Transactional(readOnly = true)
  public AccountResponse getAccountById(Long id) {
    log.debug("Fetching account by ID: {}", id);
    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));
    return mapToResponse(account);
  }

  @Override
  @Transactional(readOnly = true)
  public AccountResponse getAccountByNumber(String accountNumber) {
    log.debug("Fetching account by account number: {}", accountNumber);
    Account account =
        accountRepository
            .findByAccountNumber(accountNumber)
            .orElseThrow(
                () -> new RuntimeException("Account not found with number: " + accountNumber));
    return mapToResponse(account);
  }

  @Override
  @Transactional(readOnly = true)
  public List<AccountResponse> getAccountsByCustomerId(String customerId) {
    log.debug("Fetching accounts for customer: {}", customerId);
    List<Account> accounts = accountRepository.findByCustomerId(customerId);
    return accounts.stream().map(this::mapToResponse).collect(Collectors.toList());
  }

  @Override
  @Transactional(readOnly = true)
  public Page<AccountResponse> getAllAccounts(
      Pageable pageable, Account.AccountType accountType, Account.AccountStatus status) {
    log.debug(
        "Fetching all accounts with pagination - Type: {}, Status: {}", accountType, status);

    Page<Account> accounts;
    if (accountType != null && status != null) {
      accounts = accountRepository.findByAccountTypeAndStatus(accountType, status, pageable);
    } else if (accountType != null) {
      accounts = accountRepository.findByAccountType(accountType, pageable);
    } else if (status != null) {
      accounts = accountRepository.findByStatus(status, pageable);
    } else {
      accounts = accountRepository.findAll(pageable);
    }

    return accounts.map(this::mapToResponse);
  }

  @Override
  public AccountResponse createAccount(AccountCreateRequest request) {
    log.info("Creating new account for customer: {}", request.getCustomerId());

    // Generate unique account number
    String accountNumber = generateAccountNumber();

    // Build the account entity
    Account account =
        Account.builder()
            .accountNumber(accountNumber)
            .customerId(request.getCustomerId())
            .accountName(request.getAccountName())
            .accountType(request.getAccountType())
            .status(Account.AccountStatus.ACTIVE)
            .balance(request.getInitialDeposit())
            .availableBalance(request.getInitialDeposit())
            .overdraftLimit(request.getOverdraftLimit())
            .minimumBalance(request.getMinimumBalance())
            .interestRate(request.getInterestRate())
            .currency(request.getCurrency())
            .branchCode(request.getBranchCode())
            .routingNumber(request.getRoutingNumber())
            .iban(request.getIban())
            .swiftCode(request.getSwiftCode())
            .isFrozen(false)
            .createdBy("system") // In production, get from security context
            .build();

    Account savedAccount = accountRepository.save(account);
    log.info("Account created successfully with ID: {}", savedAccount.getId());

    return mapToResponse(savedAccount);
  }

  @Override
  public AccountResponse updateAccount(Long id, AccountUpdateRequest request) {
    log.info("Updating account ID: {}", id);

    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    // Update only provided fields
    if (request.getAccountName() != null) {
      account.setAccountName(request.getAccountName());
    }
    if (request.getOverdraftLimit() != null) {
      account.setOverdraftLimit(request.getOverdraftLimit());
    }
    if (request.getMinimumBalance() != null) {
      account.setMinimumBalance(request.getMinimumBalance());
    }
    if (request.getInterestRate() != null) {
      account.setInterestRate(request.getInterestRate());
    }
    if (request.getBranchCode() != null) {
      account.setBranchCode(request.getBranchCode());
    }
    if (request.getRoutingNumber() != null) {
      account.setRoutingNumber(request.getRoutingNumber());
    }
    if (request.getIban() != null) {
      account.setIban(request.getIban());
    }
    if (request.getSwiftCode() != null) {
      account.setSwiftCode(request.getSwiftCode());
    }

    account.setUpdatedBy("system"); // In production, get from security context

    Account updatedAccount = accountRepository.save(account);
    log.info("Account updated successfully: {}", id);

    return mapToResponse(updatedAccount);
  }

  @Override
  public void closeAccount(Long id, String reason) {
    log.warn("Closing account ID: {} with reason: {}", id, reason);

    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    // Check if account can be closed
    if (account.getBalance().compareTo(BigDecimal.ZERO) != 0) {
      throw new RuntimeException("Cannot close account with non-zero balance");
    }

    account.setStatus(Account.AccountStatus.CLOSED);
    account.setClosedAt(LocalDateTime.now());
    account.setClosedBy("system"); // In production, get from security context
    account.setClosureReason(reason);

    accountRepository.save(account);
    log.info("Account closed successfully: {}", id);
  }

  @Override
  @Transactional(readOnly = true)
  public BigDecimal getAccountBalance(Long id) {
    log.debug("Fetching balance for account ID: {}", id);
    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));
    return account.getBalance();
  }

  @Override
  @Transactional(readOnly = true)
  public BigDecimal getAvailableBalance(Long id) {
    log.debug("Fetching available balance for account ID: {}", id);
    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));
    return account.getAvailableBalance();
  }

  @Override
  public AccountResponse updateBalance(Long id, BalanceUpdateRequest request) {
    log.info(
        "Updating balance for account ID: {}, type: {}, amount: {}",
        id,
        request.getTransactionType(),
        request.getAmount());

    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    BigDecimal amount = request.getAmount();
    String transactionType = request.getTransactionType().toUpperCase();

    if ("CREDIT".equals(transactionType)) {
      if (!account.canCredit()) {
        throw new RuntimeException("Account cannot accept credits in current state");
      }
      account.setBalance(account.getBalance().add(amount));
      account.setAvailableBalance(account.getAvailableBalance().add(amount));
    } else if ("DEBIT".equals(transactionType)) {
      if (!account.canDebit(amount)) {
        throw new RuntimeException("Insufficient funds or account cannot be debited");
      }
      account.setBalance(account.getBalance().subtract(amount));
      account.setAvailableBalance(account.getAvailableBalance().subtract(amount));
    } else {
      throw new RuntimeException("Invalid transaction type: " + transactionType);
    }

    account.setLastTransactionDate(LocalDateTime.now());
    account.setUpdatedBy(
        request.getProcessedBy() != null ? request.getProcessedBy() : "system");

    Account updatedAccount = accountRepository.save(account);
    log.info("Balance updated successfully for account: {}", id);

    return mapToResponse(updatedAccount);
  }

  @Override
  public AccountResponse freezeAccount(Long id, String reason) {
    log.warn("Freezing account ID: {} for reason: {}", id, reason);

    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    account.freeze(reason, "system"); // In production, get from security context
    account.setStatus(Account.AccountStatus.FROZEN);

    Account frozenAccount = accountRepository.save(account);
    log.info("Account frozen successfully: {}", id);

    return mapToResponse(frozenAccount);
  }

  @Override
  public AccountResponse unfreezeAccount(Long id) {
    log.info("Unfreezing account ID: {}", id);

    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    account.unfreeze();
    account.setStatus(Account.AccountStatus.ACTIVE);

    Account unfrozenAccount = accountRepository.save(account);
    log.info("Account unfrozen successfully: {}", id);

    return mapToResponse(unfrozenAccount);
  }

  @Override
  public AccountResponse updateAccountStatus(Long id, Account.AccountStatus status, String reason) {
    log.info("Updating status for account ID: {} to: {}", id, status);

    Account account =
        accountRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    Account.AccountStatus oldStatus = account.getStatus();
    account.setStatus(status);

    // Handle special status transitions
    if (status == Account.AccountStatus.FROZEN) {
      account.freeze(reason, "system");
    } else if (oldStatus == Account.AccountStatus.FROZEN
        && status == Account.AccountStatus.ACTIVE) {
      account.unfreeze();
    } else if (status == Account.AccountStatus.CLOSED) {
      account.setClosedAt(LocalDateTime.now());
      account.setClosedBy("system");
      account.setClosureReason(reason);
    }

    account.setUpdatedBy("system"); // In production, get from security context

    Account updatedAccount = accountRepository.save(account);
    log.info("Account status updated successfully: {}", id);

    return mapToResponse(updatedAccount);
  }

  @Override
  @Transactional(readOnly = true)
  public boolean validateTransaction(Long id, BigDecimal amount, String transactionType) {
    log.debug("Validating {} transaction of {} for account ID: {}", transactionType, amount, id);

    try {
      Account account =
          accountRepository
              .findById(id)
              .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

      String type = transactionType.toUpperCase();
      if ("CREDIT".equals(type)) {
        return account.canCredit();
      } else if ("DEBIT".equals(type)) {
        return account.canDebit(amount);
      } else {
        log.warn("Invalid transaction type: {}", transactionType);
        return false;
      }
    } catch (Exception e) {
      log.error("Error validating transaction: {}", e.getMessage());
      return false;
    }
  }

  // Helper methods

  private String generateAccountNumber() {
    // Generate a 16-digit account number
    // Format: BANK_CODE (4 digits) + BRANCH (4 digits) + ACCOUNT (8 digits)
    StringBuilder accountNumber = new StringBuilder();
    accountNumber.append("1000"); // Bank code
    accountNumber.append(String.format("%04d", random.nextInt(10000))); // Branch code
    accountNumber.append(String.format("%08d", random.nextInt(100000000))); // Account number
    return accountNumber.toString();
  }

  private AccountResponse mapToResponse(Account account) {
    return AccountResponse.builder()
        .id(account.getId())
        .accountNumber(account.getAccountNumber())
        .customerId(account.getCustomerId())
        .accountName(account.getAccountName())
        .accountType(account.getAccountType())
        .status(account.getStatus())
        .balance(account.getBalance())
        .availableBalance(account.getAvailableBalance())
        .overdraftLimit(account.getOverdraftLimit())
        .minimumBalance(account.getMinimumBalance())
        .interestRate(account.getInterestRate())
        .currency(account.getCurrency())
        .branchCode(account.getBranchCode())
        .routingNumber(account.getRoutingNumber())
        .iban(account.getIban())
        .swiftCode(account.getSwiftCode())
        .isFrozen(account.getIsFrozen())
        .freezeReason(account.getFreezeReason())
        .frozenAt(account.getFrozenAt())
        .frozenBy(account.getFrozenBy())
        .lastTransactionDate(account.getLastTransactionDate())
        .lastStatementDate(account.getLastStatementDate())
        .nextStatementDate(account.getNextStatementDate())
        .maturityDate(account.getMaturityDate())
        .openedBy(account.getOpenedBy())
        .closedAt(account.getClosedAt())
        .closedBy(account.getClosedBy())
        .closureReason(account.getClosureReason())
        .createdAt(account.getCreatedAt())
        .updatedAt(account.getUpdatedAt())
        .createdBy(account.getCreatedBy())
        .updatedBy(account.getUpdatedBy())
        .version(account.getVersion())
        .build();
  }
}
