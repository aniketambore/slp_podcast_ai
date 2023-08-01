import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nostr_tools/nostr_tools.dart';
import 'package:slp_podcast_ai/conversation_screen.dart';
import 'package:slp_podcast_ai/podcast_card.dart';
import 'package:slp_podcast_ai/responsive_layout.dart';

import 'env.dart';

List<Map<String, IconData>> menuOptions = [
  {"Relays: wss://relay.damus.io": Icons.circle_outlined},
];

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
  final _streamController = StreamController<Event>();

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

  Future<void> _initStream() async {
    _stream = await _connectToRelay();
    _stream.listen((event) {
      if (event.kind == 1) {
        setState(() => _events.add(event));
      }
      _streamController.add(event);
    });
  }

  Future<void> _resubscribeStream() async {
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _events.clear();
      });
      _initStream();
    });
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
        authors: [(Env.nostrPubKey)],
      )
    ]);

    return stream
        .where((message) => message.type == 'EVENT')
        .map((message) => message.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast Feed'),
        centerTitle: true,
        leading: _isConnected
            ? PopupMenuButton<String>(
                itemBuilder: (context) {
                  return menuOptions.map((Map menuOption) {
                    return PopupMenuItem<String>(
                      value: menuOption.keys.first,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(menuOption.keys.first),
                            Icon(menuOption.values.first,
                                color: Colors.greenAccent),
                          ]),
                    );
                  }).toList();
                },
              )
            : Container(),
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
      floatingActionButton: _isConnected
          ? FloatingActionButton(
              tooltip: 'Create a new Podcast',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResponsiveLayout(
                      child: ConversationScreen(
                        relay: _relay,
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.podcasts_outlined,
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildPodcastList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _resubscribeStream();
      },
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          scrollbars: false,
          dragDevices: <PointerDeviceKind>{
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        child: StreamBuilder(
          stream: _streamController.stream,
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    botAvatar(),
                    const SizedBox(height: 32.0),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 32.0),
                    const Text(
                      'Connecting to the relays...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget botAvatar() {
    return const CircleAvatar(
      backgroundColor: Color(0XFFff6563),
      radius: 90,
      child: CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage('assets/images/slp_logo.png'),
      ),
    );
  }
}
