import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:nostr_tools/nostr_tools.dart';

import 'webln_js.dart' as webln;

const String matadorUrl = 'https://matador-ai.replit.app/v1/chat/completions';
const _model = 'gpt-3.5-turbo';
final _headers = {'Content-Type': 'application/json'};

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.relay,
  });

  final RelayApi relay;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Map<String, String>> conversation = [];
  String _botResponse = 'Loading...';
  String prompt = '''
You are GPT Livera, the host of the "Stephan Livera Show," a captivating podcast that delves into the world of Bitcoin, economics, and financial sovereignty. Inspired by the legendary Stephan Livera himself, you embody his conversational style and mannerisms, creating a comfortable and engaging atmosphere for thought-provoking discussions with your guests.

As GPT Livera, you adopt the following 15 behaviors that define the essence of Stephan Livera's podcasting prowess:

1. Casual and laid-back approach: You exude a relaxed and informal demeanor, making guests feel at ease and ready to share their thoughts openly.

2. Curiosity and open-mindedness: Your genuine curiosity paves the way for embracing diverse perspectives, welcoming fresh ideas with an open mind.

3. Probing and thought-provoking questions: With insightful inquiries, you aim to dive deep into subjects, challenging and inspiring guests to explore profound concepts.

4. Encourages diverse guests: Embracing a wide range of experts from various fields, you provide a platform for diverse viewpoints and expertise to thrive.

5. Freedom of expression: You actively encourage guests to express their ideas and opinions freely, fostering open dialogue and enriching discussions.

6. Humor and wit: Infusing humor into conversations, you lighten the mood, turning even complex topics into engaging and entertaining exchanges.

7. Active listening: Your attentive listening skills allow guests to articulate their thoughts and experiences fully, creating meaningful dialogues.

8. Authenticity: Just like Stephan Livera, your genuine interest in the topics and guests shines through, resulting in authentic and relatable conversations.

9. Balance between serious and lighthearted topics: Seamlessly transitioning between profound subjects and everyday chit-chat, you strike a perfect balance.

10. Exploration of personal experiences: Emulating Stephan Livera, you encourage guests to share personal stories, enriching the understanding of their journeys.

11. Tolerance for diverse opinions: Your podcast fosters an environment where guests can express their views without fear of judgment or hostility.

12. Intellectual curiosity: Like Stephan Livera, your thirst for knowledge and intellectual growth fuels exciting conversations, exploring new ideas and information.

13. Authenticity and genuineness: You, as GPT Livera, master the art of authenticity and genuineness, allowing honesty to shine through whether you agree or disagree with your guests. Your sincere and unfiltered approach creates an immediate sense of trust and realness that is uniquely Stephan Livera.

14. Adapting to the guest's style: Just as Stephan Livera adjusts his conversational approach to suit the guest's personality and expertise, you do the same, recognizing the uniqueness of each guest.

15. Challenging ideas respectfully: While you may challenge your guests' ideas or beliefs, you do so with respect, aiming to foster constructive dialogue rather than confrontations or personal attacks.

---
Remember to structure your responses as follows:

User: [User's message]
AI: [AI's response starting with "🎙️ GPT Livera: "]
---

Also remember that when the conversation ends give me this hash as GPT Livera response so that I know that the podcast is over now: 32b9e6d5425421c95f7137058bffba76aa217f35224deb9ce51c99abf573b1c2 

Now, let's get this captivating podcast started! Please introduce yourself, my esteemed guest, and tell us your name and field of expertise. We're all ears and eager to embark on this enlightening journey together! 🎧😊
''';

  String token = '';
  String invoice = '';
  bool _aiTyping = true;

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _lnAddressController = TextEditingController();
  final dio = Dio();

  final _completePodcast = <String>[];

  @override
  void initState() {
    webln.isWeblnEnabled(
      allowInterop(() => welcomeBot()),
      allowInterop(() => Navigator.pop(context)),
    );
    super.initState();
  }

  Future<void> welcomeBot() async {
    await _sendMessageToBot(prompt);
  }

  Future<void> _sendMessageToBot(String message) async {
    setState(() {
      _botResponse = 'Loading...';
      _aiTyping = true;
    });

    try {
      conversation.add({'role': 'user', 'content': message});
      final response = await _postMessageToBot(message);
      if (response.statusCode == 402) {
        await _handlePaymentResponse(response);
      } else {
        handleError('Failed to make request: ${response.statusCode}');
      }
    } catch (e) {
      handleError('Error: $e');
    } finally {
      setState(() => _aiTyping = false);
    }
  }

  Future<Response> _postMessageToBot(String message) {
    return dio.post(
      matadorUrl,
      data: getPayload(),
      options: Options(
        headers: _headers,
        validateStatus: (status) =>
            status == 402 || (status! >= 200 && status < 300),
      ),
    );
  }

  Future<void> _handlePaymentResponse(Response response) async {
    final lnurl = response.headers['www-authenticate'];

    if (lnurl != null) {
      for (String item in lnurl) {
        if (item.contains("token=")) {
          token = item.split("token=")[1];
        }

        if (item.contains("invoice=")) {
          invoice = item.split("invoice=")[1];
        }
      }

      webln.sendPayment(
        invoice,
        allowInterop((preimage) => authCallback(preimage)),
      );
    }
  }

  Future<void> authCallback(String preimage) async {
    final result = await dio.post(
      matadorUrl,
      data: getPayload(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'L402 $token:$preimage',
        },
        validateStatus: (status) =>
            status == 402 || (status! >= 200 && status < 300),
        receiveDataWhenStatusError: true,
      ),
    );

    if (result.statusCode == 200) {
      final responseData =
          jsonDecode(result.data)['choices'][0]['message']['content'];
      setState(() {
        _botResponse = responseData;

        // Check if the responseData contains the hash at the end
        final hasHash = responseData.endsWith(
            '32b9e6d5425421c95f7137058bffba76aa217f35224deb9ce51c99abf573b1c2');

        // Remove the hash if it exists at the end of responseData
        final responseTextWithoutHash = hasHash
            ? responseData
                .replaceFirst(
                    '32b9e6d5425421c95f7137058bffba76aa217f35224deb9ce51c99abf573b1c2',
                    '')
                .trim()
            : responseData.trim();

        _completePodcast.add(responseTextWithoutHash);

        // Add AI's response to the conversation context
        conversation
            .add({'role': 'assistant', 'content': responseTextWithoutHash});

        // Check if the conversation is ending
        if (hasHash) {
          _showConversationDialog();
        }
      });
    } else {
      handleError('Failed to retrieve completion: ${result.statusCode}');
    }
  }

  Map<String, Object> getPayload() {
    return {
      'model': _model,
      'messages': conversation,
    };
  }

  void _sendMessage() async {
    String message = _textEditingController.text;
    if (message.trim().isNotEmpty) {
      setState(() {
        prompt = message;
        _completePodcast.add('User: $message');
      });

      await _sendMessageToBot(message);

      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Screen'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showConversationDialog();
            },
            icon: const Icon(
              Icons.chat_outlined,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(_botResponse),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              enabled: !_aiTyping,
              controller: _textEditingController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleError(String message) {
    print('[!] Error: $message');
  }

  void _showConversationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conversation History'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _completePodcast.map((item) {
                return Text(item);
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the publish action
                // You can add the logic to publish the conversation here
                Navigator.pop(context);

                _showPublishDialog();
              },
              child: const Text('Publish'),
            ),
            TextButton(
              onPressed: () {
                // Handle the cancel action
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Publish Podcast'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Enter your LN address to get rewarded in sats for your podcasts'), // Display the LN Address here
              const SizedBox(height: 16.0),
              TextField(
                controller: _lnAddressController,
                decoration: const InputDecoration(
                  hintText: 'aniketamborebitcoindev@getalby.com',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final lnAddress = _lnAddressController.text.trim().isNotEmpty
                    ? _lnAddressController.text.trim()
                    : 'aniketamborebitcoindev@getalby.com';
                final content = encodeJson(_completePodcast, lnAddress);
                final eventApi = EventApi();
                final event = eventApi.finishEvent(
                  // 4
                  Event(
                    kind: 1,
                    tags: [
                      ['t', 'slp']
                    ],
                    content: content,
                    created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  ),
                  'c53e55fc69a155fd0a8fb8466a532ba54eafdf4470027478b244264b3d4748ab',
                );

                widget.relay.publish(event);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Publish'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to encode the JSON data
  String encodeJson(List<String> podcast, String lnAddress) {
    final Map<String, dynamic> jsonData = {
      'podcast': podcast,
      'ln_address': lnAddress,
    };

    return jsonEncode(jsonData);
  }
}
