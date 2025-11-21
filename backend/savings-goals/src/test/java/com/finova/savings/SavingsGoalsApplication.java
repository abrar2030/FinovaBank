package com.finova.savings;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class SavingsGoalsApplication {
  public static void main(String[] args) {
    SpringApplication.run(SavingsGoalsApplication.class, args);
  }
}
