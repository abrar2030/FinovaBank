package com.fintech.apigateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RouteConfig {
  @Bean
  public RouteLocator routes(RouteLocatorBuilder builder) {
    return builder
        .routes()
        .route("user-service", r -> r.path("/users/**").uri("lb://user-service"))
        .route("payment-service", r -> r.path("/payments/**").uri("lb://payment-service"))
        .route(
            "notification-service",
            r -> r.path("/notifications/**").uri("lb://notification-service"))
        .build();
  }
}
