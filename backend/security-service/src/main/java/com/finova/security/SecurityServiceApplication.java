package com.finova.security;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

/**
 * Security Service Application
 *
 * <p>This service is responsible for security-related operations including encryption, secret
 * management, and security compliance checks.
 */
@SpringBootApplication
@EnableEurekaClient
public class SecurityServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(SecurityServiceApplication.class, args);
  }
}
