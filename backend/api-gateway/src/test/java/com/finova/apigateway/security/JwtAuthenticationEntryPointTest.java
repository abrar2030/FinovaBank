package com.finova.apigateway.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;

import java.io.IOException;
import javax.servlet.ServletException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.AuthenticationException;

public class JwtAuthenticationEntryPointTest {

  @InjectMocks private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

  private MockHttpServletRequest request;
  private MockHttpServletResponse response;
  private AuthenticationException authException;

  @BeforeEach
  public void setup() {
    MockitoAnnotations.openMocks(this);
    request = new MockHttpServletRequest();
    response = new MockHttpServletResponse();
    authException = mock(AuthenticationException.class);
  }

  @Test
  public void testCommence() throws IOException, ServletException {
    // When
    jwtAuthenticationEntryPoint.commence(request, response, authException);

    // Then
    assertEquals(HttpStatus.UNAUTHORIZED.value(), response.getStatus());
    assertEquals("application/json", response.getContentType());
  }
}
