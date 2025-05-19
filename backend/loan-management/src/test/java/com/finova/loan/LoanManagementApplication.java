package com.finova.loan;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class LoanManagementApplication {
    public static void main(String[] args) {
        SpringApplication.run(LoanManagementApplication.class, args);
    }
}
