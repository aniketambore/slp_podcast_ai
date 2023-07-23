import 'dart:async';
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
  late Stream<Event> _stream;
  final _controller = StreamController<Event>();

  @override
  void initState() {
    _initStream();
    super.initState();
  }

  @override
  void dispose() {
    _relay.close();
    super.dispose();
  }

  Future<Stream<Event>> _connectToRelay() async {
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

    return stream
        .where((message) => message.type == 'EVENT')
        .map((message) => message.message);
  }

  void _initStream() async {
    _stream = await _connectToRelay();
    _stream.listen((event) {
      if (event.kind == 1) {
        setState(() => _events.add(event));
      }
      _controller.add(event);
    });
  }

  Future<void> _resubscribeStream() async {
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _events.clear();
      });
      _initStream(); // Reconnect and resubscribe to the filter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast Feed'),
        centerTitle: true,
        backgroundColor: _isConnected ? Colors.indigoAccent : Colors.redAccent,
        actions: [
          IconButton(
            onPressed: () async {
              await _resubscribeStream();
            },
            icon: const Icon(Icons.refresh_outlined),
          )
        ],
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
    return RefreshIndicator(
      onRefresh: () async {
        await _resubscribeStream();
      },
      child: StreamBuilder(
        stream: _controller.stream,
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
      ),
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
