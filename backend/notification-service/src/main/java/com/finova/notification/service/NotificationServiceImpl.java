package com.finova.notification.service.impl;

import com.finova.notification.model.Notification;
import com.finova.notification.repository.NotificationRepository;
import com.finova.notification.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Override
    public Notification getNotificationById(Long id) {
        return notificationRepository.findById(id).orElse(null);
    }

    @Override
    public List<Notification> getAllNotifications() {
        return notificationRepository.findAll();
    }

    @Override
    public Notification sendNotification(Notification notification) {
        return notificationRepository.save(notification);
    }
}
