import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = "service_ivsyk58";
  static const String _templateId = "template_80mxpzw";
  static const String _publicKey = "xh9f0MOiZY1b7wsS5";

  Future<void> sendAppointmentEmail({
    required String toName,
    required String toEmail,
    required String message,
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    final response = await http.post(
      Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
      headers: {
        "origin": "http://localhost",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": _serviceId,
        "template_id": _templateId,
        "user_id": _publicKey,
        "template_params": {
          "to_name": toName,
          "to_email": toEmail,
          "message": message,
          "doctor_name": doctorName,
          "appointment_date": appointmentDate,
          "appointment_time": appointmentTime,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Email sending failed: ${response.statusCode}\n${response.body}",
      );
    }
  }
}
