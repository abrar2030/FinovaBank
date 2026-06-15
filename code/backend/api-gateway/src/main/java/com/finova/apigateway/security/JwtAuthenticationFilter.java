package com.finova.apigateway.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationFilter implements WebFilter {

  @Autowired
  private JwtUtil jwtUtil;

  @Override
  public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
    ServerHttpRequest request = exchange.getRequest();

    String path = request.getPath().value();
    // Match the public endpoints exactly rather than with contains(). The
    // previous contains("/login"|"/register"|"/validate") checks exempted any
    // downstream path that merely contained those substrings (for example
    // "/api/transactions/validate-batch"), allowing it to bypass JWT checks.
    if (path.startsWith("/actuator")
        || path.equals("/")
        || path.equals("/api/auth/login")
        || path.equals("/api/auth/register")
        || path.equals("/api/auth/validate")
        || path.startsWith("/v3/api-docs")
        || path.startsWith("/swagger-ui")
        || path.startsWith("/webjars")) {
      return chain.filter(exchange);
    }

    // BUG FIX: Previously, missing Authorization header silently allowed access to
    // protected routes. Now we explicitly reject requests without a valid Bearer token.
    String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
      exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
      return exchange.getResponse().setComplete();
    }

    String token = authHeader.substring(7);
    try {
      if (!jwtUtil.validateToken(token)) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        return exchange.getResponse().setComplete();
      }
      String username = jwtUtil.extractUsername(token);
      if (username == null || username.isBlank()) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        return exchange.getResponse().setComplete();
      }
    } catch (Exception e) {
      exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
      return exchange.getResponse().setComplete();
    }

    return chain.filter(exchange);
  }
}
