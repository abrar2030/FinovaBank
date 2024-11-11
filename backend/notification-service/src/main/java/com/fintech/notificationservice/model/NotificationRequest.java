package com.fintech.notificationservice.model;

import java.util.Map;
import lombok.Data;

@Data
public class NotificationRequest {
  private String recipientEmail;
  private String subject;
  private Map<String, Object> properties;
}
