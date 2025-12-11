package com.finova.security.authorization;

import java.io.Serializable;
import org.springframework.security.access.PermissionEvaluator;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

@Component
public class CustomPermissionEvaluator implements PermissionEvaluator {

  @Override
  public boolean hasPermission(
      Authentication authentication, Object targetDomainObject, Object permission) {
    // This method is typically used for object-level security (ACLs).
    // For now, we will delegate to the simpler permission check.
    if (targetDomainObject == null) {
      return hasPermission(authentication, null, null, permission);
    }
    // In a real application, logic to check if the user has permission
    // on the specific targetDomainObject would be implemented here.
    // e.g., check if the user is the owner of the account.
    return hasPermission(authentication, targetDomainObject.getClass().getSimpleName(), permission);
  }

  @Override
  public boolean hasPermission(
      Authentication authentication, Serializable targetId, String targetType, Object permission) {
    // This method is typically used for instance-level security.
    // In a real application, logic to check if the user has permission
    // on the specific instance (targetId) of the targetType would be implemented here.
    return hasPermission(authentication, targetType, permission);
  }

  /**
   * Checks if the user has the required permission (String) for a given resource type (String).
   * This is a simplified check for general resource access.
   */
  private boolean hasPermission(Authentication authentication, String targetType, Object permission) {
    if (authentication == null || !authentication.isAuthenticated() || permission == null) {
      return false;
    }

    String requiredPermission = (targetType != null ? targetType.toUpperCase() + "_" : "") + permission.toString().toUpperCase();

    for (GrantedAuthority authority : authentication.getAuthorities()) {
      if (authority.getAuthority().equals(requiredPermission)) {
        return true;
      }
    }
    return false;
  }
}
