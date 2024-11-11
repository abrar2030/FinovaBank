package com.fintech.notificationservice.service;

import com.fintech.notificationservice.model.NotificationRequest;
import javax.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.*;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Service
public class EmailNotificationService implements NotificationService {

  private JavaMailSender mailSender;
  private TemplateEngine templateEngine;

  @Autowired
  public EmailNotificationService(JavaMailSender mailSender, TemplateEngine templateEngine) {
    this.mailSender = mailSender;
    this.templateEngine = templateEngine;
  }

  @Override
  public void sendNotification(NotificationRequest notificationRequest) {
    try {
      MimeMessage message = mailSender.createMimeMessage();
      MimeMessageHelper helper = new MimeMessageHelper(message, true);

      helper.setTo(notificationRequest.getRecipientEmail());
      helper.setSubject(notificationRequest.getSubject());

      // Use Thymeleaf template
      Context context = new Context();
      context.setVariables(notificationRequest.getProperties());
      String htmlContent = templateEngine.process("email-template", context);

      helper.setText(htmlContent, true);

      // Add attachment if needed
      // helper.addAttachment("attachment.pdf", new ClassPathResource("attachment.pdf"));

      mailSender.send(message);

    } catch (MailException | javax.mail.MessagingException e) {
      e.printStackTrace();
      // Handle exception
    }
  }
}
