package com.finova.notificationservice.controller;

import com.finova.notificationservice.model.NotificationRequest;
import com.finova.notificationservice.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

  private NotificationService notificationService;

  @Autowired
  public NotificationController(NotificationService notificationService) {
    this.notificationService = notificationService;
  }

  @PostMapping("/send")
  public void sendNotification(@RequestBody NotificationRequest notificationRequest) {
    notificationService.sendNotification(notificationRequest);
  }
}
