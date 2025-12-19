package com.finova.apigateway.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import javax.annotation.PostConstruct;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;
import io.jsonwebtoken.Jwts;

@Component
public class JwtAuthenticationFilter implements WebFilter {

  @Value("${jwt.secret}")
  private String jwtSecret;

  private SecretKey key;

  @PostConstruct
  public void init() {
    // Ensure the secret is long enough for HS512 (minimum 512 bits = 64 bytes)
    String paddedSecret = jwtSecret;
    while (paddedSecret.getBytes(StandardCharsets.UTF_8).length < 64) {
      paddedSecret = paddedSecret + paddedSecret;
    }
    this.key = Keys.hmacShaKeyFor(paddedSecret.getBytes(StandardCharsets.UTF_8));
  }

  @Override
  public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
    ServerHttpRequest request = exchange.getRequest();

    // Skip JWT validation for public endpoints
    String path = request.getPath().value();
    if (path.startsWith("/actuator") || path.equals("/") || path.contains("/login") || path.contains("/register")) {
      return chain.filter(exchange);
    }

    if (request.getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
      String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
      if (authHeader != null && authHeader.startsWith("Bearer ")) {
        String token = authHeader.substring(7);

        try {
          Claims claims = Jwts.parserBuilder()
              .setSigningKey(key)
              .build()
              .parseClaimsJws(token)
              .getBody();
          // Additional claims validation logic can go here
          // Token is valid, continue with the request
        } catch (Exception e) {
          exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
          return exchange.getResponse().setComplete();
        }
      }
    }

    return chain.filter(exchange);
  }
}
