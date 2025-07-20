import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramLogger {
  final String botToken;

  TelegramLogger({required this.botToken});

  Future<void> sendLog(String message) async {
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': "5035511154",
          'text': message,
        }),
      );
    } catch (e) {
      print('Telegram log error: $e');
    }
  }
}
