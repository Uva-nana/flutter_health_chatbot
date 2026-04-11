enum Sender { user, bot }

class Message {
  final String text;
  final Sender sender;
  final DateTime time;

  Message({
    required this.text,
    required this.sender,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}
