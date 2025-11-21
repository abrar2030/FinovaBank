package com.finova.security.authentication;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.OAuth2RestTemplate;
import org.springframework.security.oauth2.client.token.grant.password.ResourceOwnerPasswordResourceDetails;

@Configuration
public class OAuth2Config {

  @Bean
  public OAuth2RestTemplate oauth2RestTemplate() {
    ResourceOwnerPasswordResourceDetails resourceDetails =
        new ResourceOwnerPasswordResourceDetails();
    resourceDetails.setClientId("finova-client");
    resourceDetails.setClientSecret("finova-secret");
    resourceDetails.setAccessTokenUri("http://auth-server/oauth/token");
    resourceDetails.setUsername("user");
    resourceDetails.setPassword("password");
    return new OAuth2RestTemplate(resourceDetails);
  }
}
