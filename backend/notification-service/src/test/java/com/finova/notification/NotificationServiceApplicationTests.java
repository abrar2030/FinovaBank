package com.finova.notification;

import com.finova.notification.model.Notification;
import com.finova.notification.service.NotificationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class NotificationServiceApplicationTests {

    @Autowired
    private NotificationService notificationService;

    @Test
    void contextLoads() {
    }

    @Test
    void testSendNotification() {
        Notification notification = new Notification();
        notification.setAccountId(1L);
        notification.setType("ALERT");
        notification.setMessage("Your account balance is low.");
        notification.setTimestamp(LocalDateTime.now());

        Notification savedNotification = notificationService.sendNotification(notification);
        assertNotNull(savedNotification);
        assertEquals("ALERT", savedNotification.getType());
    }
}
