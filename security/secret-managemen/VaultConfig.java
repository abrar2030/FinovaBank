package com.finova.security.secretmanagement;

import org.springframework.context.annotation.Configuration;
import org.springframework.vault.annotation.VaultPropertySource;

@Configuration
@VaultPropertySource("secret/finova")
public class VaultConfig {
}
