package com.finova.apigateway.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import javax.annotation.PostConstruct;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtUtil {

  @Value("${jwt.secret}")
  private String secret;

  private SecretKey key;

  @PostConstruct
  public void init() {
    // Ensure the secret is long enough for HS512 (minimum 512 bits = 64 bytes)
    // Pad the secret if necessary to meet the minimum length requirement
    String paddedSecret = secret;
    while (paddedSecret.getBytes(StandardCharsets.UTF_8).length < 64) {
      paddedSecret = paddedSecret + paddedSecret;
    }
    this.key = Keys.hmacShaKeyFor(paddedSecret.getBytes(StandardCharsets.UTF_8));
  }

  public String generateToken(String username) {
    return Jwts.builder()
        .setSubject(username)
        .setIssuedAt(new Date())
        .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 1 day expiration
        .signWith(key)
        .compact();
  }

  public Claims extractClaims(String token) {
    return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
  }

  public boolean isTokenExpired(String token) {
    try {
      return extractClaims(token).getExpiration().before(new Date());
    } catch (Exception e) {
      return true;
    }
  }

  public boolean validateToken(String token) {
    try {
      Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
      return !isTokenExpired(token);
    } catch (Exception e) {
      return false;
    }
  }
}
