import 'package:flutter/material.dart';
import '../models/diet_profile.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../services/profile_service.dart';
import '../widgets/message_bubble.dart';
import 'diet_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final DietProfile? initialProfile;

  const ChatScreen({super.key, this.initialProfile});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GeminiService _geminiService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ProfileService _profileService = ProfileService();
  final List<Message> _messages = [];
  bool _isLoading = false;
  DietProfile? _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _geminiService = GeminiService(profile: _profile);
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final greeting = _profile != null
        ? 'Hello! I\'m your personal health assistant, ready to give advice tailored to your profile.\n\n'
            '• Goal: ${_profile!.goal}\n'
            '• Restrictions: ${_profile!.restrictions.join(', ')}\n\n'
            'Ask me about meals, nutrition, diet tips, and more!'
        : 'Hello! I am your personal health and nutrition assistant. 🥗\n\nYou can ask me about:\n• Healthy meal choices\n• Food for your health goals\n• Diet tips for conditions like diabetes\n• Nutrition advice\n\nHow can I help you today?';

    _messages.add(Message(text: greeting, sender: Sender.bot));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(Message(text: text, sender: Sender.user));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    final botMessage = Message(text: '', sender: Sender.bot);
    bool firstChunk = true;

    await for (final chunk in _geminiService.sendMessageStream(text)) {
      if (firstChunk) {
        setState(() {
          _messages.add(botMessage);
          _isLoading = false;
          botMessage.text += chunk;
          firstChunk = false;
        });
      } else {
        setState(() {
          botMessage.text += chunk;
        });
      }
      _scrollToBottom();
    }

    if (firstChunk) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openProfileScreen() async {
    final updatedProfile = await Navigator.push<DietProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => DietProfileScreen(existingProfile: _profile),
      ),
    );

    if (updatedProfile != null) {
      setState(() {
        _profile = updatedProfile;
        _geminiService = GeminiService(profile: _profile);
        _messages.clear();
        _addWelcomeMessage();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: Colors.white),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Assistant',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Powered by Groq AI',
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Diet Profile',
            onPressed: _openProfileScreen,
          ),
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Share your menu',
            onPressed: _showMenuDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_profile == null)
            GestureDetector(
              onTap: _openProfileScreen,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Set up your diet profile for personalized advice',
                        style: TextStyle(
                            color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.orange.shade700, size: 14),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MessageBubble(message: _messages[index]),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            _dot(1),
            _dot(2),
          ],
        ),
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.4 + value * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask about food, diet, nutrition...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green.shade600,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog() {
    final menuController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.green),
            SizedBox(width: 8),
            Text('Share Your Menu'),
          ],
        ),
        content: TextField(
          controller: menuController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText:
                'Paste your menu here...\nExample:\n- Grilled chicken\n- Caesar salad\n- Pasta carbonara',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white),
            onPressed: () {
              if (menuController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _controller.text =
                    'Here is my menu:\n${menuController.text}\n\nWhich options are healthiest for me?';
                _sendMessage();
              }
            },
            child: const Text('Analyze Menu'),
          ),
        ],
      ),
    );
  }
}
