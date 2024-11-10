package com.finova.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("account-service", r -> r.path("/account/**").uri("lb://ACCOUNT-SERVICE"))
                .route("transaction-service", r -> r.path("/transaction/**").uri("lb://TRANSACTION-SERVICE"))
                .route("loan-service", r -> r.path("/loan/**").uri("lb://LOAN-SERVICE"))
                .route("savings-goal-service", r -> r.path("/savings/**").uri("lb://SAVINGS-GOAL-SERVICE"))
                .build();
    }
}
