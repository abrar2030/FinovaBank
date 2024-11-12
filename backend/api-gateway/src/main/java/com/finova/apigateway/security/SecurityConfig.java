package com.fintech.apigateway.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableReactiveMethodSecurity;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

@Configuration
@EnableWebFluxSecurity
@EnableReactiveMethodSecurity
public class SecurityConfig {

  @Bean
  public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
    http.csrf()
        .disable()
        .authorizeExchange(
            exchanges ->
                exchanges
                    .pathMatchers("/", "/login", "/register", "/actuator/**")
                    .permitAll()
                    .anyExchange()
                    .authenticated() // Require authentication for other endpoints
            )
        .httpBasic()
        .and()
        .formLogin()
        .disable();
    return http.build();
  }
}
