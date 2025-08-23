package com.finova.auth.service;

import com.finova.auth.dto.LoginRequest;
import com.finova.auth.dto.LoginResponse;
import com.finova.auth.dto.RegisterRequest;
import com.finova.auth.dto.UserResponse;
import com.finova.auth.model.Role;
import com.finova.auth.model.User;
import com.finova.auth.repository.RoleRepository;
import com.finova.auth.repository.UserRepository;
import com.finova.auth.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final String BLACKLIST_PREFIX = "blacklist:";

    @Override
    public LoginResponse login(LoginRequest request) {
        try {
            // Check if account is locked
            User user = userRepository.findByUsername(request.getUsername())
                    .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

            if (!user.getAccountNonLocked()) {
                throw new BadCredentialsException("Account is locked");
            }

            // Authenticate user
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );

            // Reset failed login attempts on successful login
            userRepository.updateFailedLoginAttempts(request.getUsername(), 0);
            userRepository.updateLastLoginTime(request.getUsername(), LocalDateTime.now());

            // Generate tokens
            String accessToken = jwtTokenProvider.generateAccessToken(authentication);
            String refreshToken = jwtTokenProvider.generateRefreshToken(authentication);

            Set<String> roles = user.getRoles().stream()
                    .map(role -> role.getName().name())
                    .collect(Collectors.toSet());

            return LoginResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .expiresIn(jwtTokenProvider.getAccessTokenValidityInSeconds())
                    .expiresAt(LocalDateTime.now().plusSeconds(jwtTokenProvider.getAccessTokenValidityInSeconds()))
                    .username(user.getUsername())
                    .roles(roles)
                    .mfaRequired(user.getMfaEnabled())
                    .build();

        } catch (AuthenticationException e) {
            handleFailedLogin(request.getUsername());
            throw new BadCredentialsException("Invalid credentials");
        }
    }

    @Override
    public UserResponse register(RegisterRequest request) {
        // Check if username or email already exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        // Get default customer role
        Role customerRole = roleRepository.findByName(Role.RoleName.ROLE_CUSTOMER)
                .orElseThrow(() -> new RuntimeException("Default role not found"));

        // Create new user
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phoneNumber(request.getPhoneNumber())
                .passwordChangedAt(LocalDateTime.now())
                .build();

        user.getRoles().add(customerRole);
        user = userRepository.save(user);

        return mapToUserResponse(user);
    }

    @Override
    public void logout(String token) {
        // Add token to blacklist
        long expiration = jwtTokenProvider.getExpirationFromToken(token).getTime();
        long currentTime = System.currentTimeMillis();
        long ttl = expiration - currentTime;

        if (ttl > 0) {
            redisTemplate.opsForValue().set(BLACKLIST_PREFIX + token, "blacklisted", ttl, TimeUnit.MILLISECONDS);
        }
    }

    @Override
    public LoginResponse refreshToken(String token) {
        if (!jwtTokenProvider.validateToken(token) || isTokenBlacklisted(token)) {
            throw new BadCredentialsException("Invalid refresh token");
        }

        String username = jwtTokenProvider.getUsernameFromToken(token);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BadCredentialsException("User not found"));

        // Generate new tokens
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                user.getUsername(), null, user.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority(role.getName().name()))
                .collect(Collectors.toList())
        );

        String newAccessToken = jwtTokenProvider.generateAccessToken(authentication);
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(authentication);

        // Blacklist old refresh token
        logout(token);

        Set<String> roles = user.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet());

        return LoginResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .expiresIn(jwtTokenProvider.getAccessTokenValidityInSeconds())
                .expiresAt(LocalDateTime.now().plusSeconds(jwtTokenProvider.getAccessTokenValidityInSeconds()))
                .username(user.getUsername())
                .roles(roles)
                .mfaRequired(user.getMfaEnabled())
                .build();
    }

    @Override
    public boolean validateToken(String token) {
        return jwtTokenProvider.validateToken(token) && !isTokenBlacklisted(token);
    }

    @Override
    public void lockAccount(String username) {
        userRepository.updateAccountLockStatus(username, false);
        log.warn("Account locked for user: {}", username);
    }

    @Override
    public void unlockAccount(String username) {
        userRepository.updateAccountLockStatus(username, true);
        userRepository.updateFailedLoginAttempts(username, 0);
        log.info("Account unlocked for user: {}", username);
    }

    private void handleFailedLogin(String username) {
        User user = userRepository.findByUsername(username).orElse(null);
        if (user != null) {
            int failedAttempts = user.getFailedLoginAttempts() + 1;
            userRepository.updateFailedLoginAttempts(username, failedAttempts);

            if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
                lockAccount(username);
            }
        }
    }

    private boolean isTokenBlacklisted(String token) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(BLACKLIST_PREFIX + token));
    }

    private UserResponse mapToUserResponse(User user) {
        Set<String> roles = user.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet());

        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phoneNumber(user.getPhoneNumber())
                .roles(roles)
                .enabled(user.getEnabled())
                .accountNonExpired(user.getAccountNonExpired())
                .accountNonLocked(user.getAccountNonLocked())
                .credentialsNonExpired(user.getCredentialsNonExpired())
                .createdAt(user.getCreatedAt())
                .lastLoginAt(user.getLastLoginAt())
                .build();
    }
}

