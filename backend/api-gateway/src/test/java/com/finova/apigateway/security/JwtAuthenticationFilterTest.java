package com.finova.apigateway.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpHeaders;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

public class JwtAuthenticationFilterTest {

    @InjectMocks
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Mock
    private JwtUtil jwtUtil;

    private MockHttpServletRequest request;
    private MockHttpServletResponse response;
    private FilterChain filterChain;

    @BeforeEach
    public void setup() {
        MockitoAnnotations.openMocks(this);
        request = new MockHttpServletRequest();
        response = new MockHttpServletResponse();
        filterChain = new MockFilterChain();
        SecurityContextHolder.clearContext();
    }

    @Test
    public void testDoFilterInternal_NoAuthHeader() throws ServletException, IOException {
        // Given
        when(request.getHeader(HttpHeaders.AUTHORIZATION)).thenReturn(null);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(jwtUtil, never()).validateToken(anyString());
        assertNotNull(SecurityContextHolder.getContext());
    }

    @Test
    public void testDoFilterInternal_InvalidAuthHeader() throws ServletException, IOException {
        // Given
        when(request.getHeader(HttpHeaders.AUTHORIZATION)).thenReturn("Invalid");

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(jwtUtil, never()).validateToken(anyString());
        assertNotNull(SecurityContextHolder.getContext());
    }

    @Test
    public void testDoFilterInternal_ValidAuthHeader() throws ServletException, IOException {
        // Given
        String token = "Bearer valid_token";
        when(request.getHeader(HttpHeaders.AUTHORIZATION)).thenReturn(token);
        when(jwtUtil.validateToken("valid_token")).thenReturn(true);
        when(jwtUtil.extractUsername("valid_token")).thenReturn("user@example.com");

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(jwtUtil, times(1)).validateToken("valid_token");
        verify(jwtUtil, times(1)).extractUsername("valid_token");
        assertNotNull(SecurityContextHolder.getContext());
    }
}
