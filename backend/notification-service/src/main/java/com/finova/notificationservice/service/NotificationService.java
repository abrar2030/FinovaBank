package com.fintech.notificationservice.service;

import com.fintech.notificationservice.model.NotificationRequest;

public interface NotificationService {
  void sendNotification(NotificationRequest notificationRequest);
}
