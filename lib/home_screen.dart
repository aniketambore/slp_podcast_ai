import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nostr_tools/nostr_tools.dart';
import 'package:slp_podcast_ai/conversation_screen.dart';
import 'package:slp_podcast_ai/podcast_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  final _relay = RelayApi(relayUrl: 'wss://relay.damus.io');
  final List<Event> _events = [];

  Stream get relayStream async* {
    final stream = await _relay.connect();
    _relay.on((event) {
      if (event == RelayEvent.connect) {
        setState(() => _isConnected = true);
      } else if (event == RelayEvent.error) {
        setState(() => _isConnected = false);
      }
    });
    _relay.sub([
      Filter(
        kinds: [1],
        authors: [
          '44ec93377a50cfdc966ea2b65bf628b5fc4adf8b5cbad2d76bc171f939854928'
        ],
      )
    ]);

    await for (var message in stream) {
      if (message.type == 'EVENT') {
        Event event = message.message;
        if (event.kind == 1) {
          _events.add(event);
        }
      }

      yield message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast Feed'),
        centerTitle: true,
        backgroundColor: _isConnected ? Colors.indigoAccent : Colors.redAccent,
      ),
      body: _buildPodcastList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToConversationScreen();
        },
        child: const Icon(
          Icons.podcasts_outlined,
        ),
      ),
    );
  }

  Widget _buildPodcastList() {
    return StreamBuilder(
      stream: relayStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return PodcastCard(podcastData: jsonDecode(event.content));
              // return Text(event.content);
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading....'));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _navigateToConversationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          relay: _relay,
        ),
      ),
    );
  }
}
