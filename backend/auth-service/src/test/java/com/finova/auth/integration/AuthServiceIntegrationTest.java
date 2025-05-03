package com.finovabank.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

// Assuming the main application class for auth-service exists
// import com.finova.auth.AuthServiceApplication;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AuthServiceIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void testLoginEndpoint() {
        // String url = "http://localhost:" + port + "/api/auth/login"; // Adjust endpoint
        // LoginRequest request = new LoginRequest("user", "password");
        // ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
        // assertEquals(HttpStatus.OK, response.getStatusCode());
        // Add assertions for JWT token or user details in response
    }

    // Add more integration tests for other auth endpoints (e.g., register, validate token)
}

