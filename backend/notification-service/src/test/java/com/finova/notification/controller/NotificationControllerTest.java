package com.finova.notification.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.finova.notificationservice.controller.NotificationController;
import com.finova.notificationservice.model.NotificationRequest;
import com.finova.notificationservice.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

public class NotificationControllerTest {

  private MockMvc mockMvc;

  @Mock private NotificationService notificationService;

  @InjectMocks private NotificationController notificationController;

  @BeforeEach
  public void setup() {
    MockitoAnnotations.openMocks(this);
    mockMvc = MockMvcBuilders.standaloneSetup(notificationController).build();
  }

  @Test
  public void testSendNotification() throws Exception {
    // Given
    doNothing().when(notificationService).sendNotification(any(NotificationRequest.class));

    // When & Then
    mockMvc
        .perform(
            post("/notifications/send")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    "{\"userId\":\"123\",\"message\":\"Test notification\",\"type\":\"EMAIL\"}"))
        .andExpect(status().isOk());

    // Verify
    verify(notificationService).sendNotification(any(NotificationRequest.class));
  }
}
