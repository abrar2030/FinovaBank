package com.finova.notification.service;

import com.finova.notification.model.Notification;
import java.util.List;

public interface NotificationService {
    Notification getNotificationById(Long id);
    List<Notification> getAllNotifications();
    Notification sendNotification(Notification notification);
}
