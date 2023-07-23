import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'lnurl_js.dart' as lnurl;

class PodcastCard extends StatefulWidget {
  final Map<String, dynamic> podcastData;

  const PodcastCard({Key? key, required this.podcastData}) : super(key: key);

  @override
  State<PodcastCard> createState() => _PodcastCardState();
}

class _PodcastCardState extends State<PodcastCard> {
  bool _showFullPodcast = false;
  TextEditingController amountController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final podcast = (widget.podcastData['podcast'] as List)
        .map((item) => item as String)
        .toList();
    final String lnAddress = widget.podcastData['ln_address'];

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Podcast:'),
            const SizedBox(height: 8.0),
            _buildPodcastText(podcast),
            const SizedBox(height: 8.0),
            _buildReadMoreButton(podcast),
            _buildZapButton(lnAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPodcastText(List<String> podcast) {
    return _showFullPodcast
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: podcast
                .map((message) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(message.trim()),
                    ))
                .toList(),
          )
        : Text(
            '${podcast[0]} ${podcast[1]} ...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
  }

  Widget _buildReadMoreButton(List<String> podcast) {
    return !_showFullPodcast && podcast.length > 2
        ? TextButton(
            onPressed: () {
              setState(() {
                _showFullPodcast = true;
              });
            },
            child: const Text('Read More'),
          )
        : TextButton(
            onPressed: () {
              setState(() {
                _showFullPodcast = false;
              });
            },
            child: const Text('Show Less'),
          );
  }

  Widget _buildZapButton(String lnAddress) {
    return IconButton(
      icon: const Icon(Icons.bolt_outlined),
      onPressed: () => _showZapDialog(lnAddress),
    );
  }

  void _showZapDialog(String lnAddress) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zap Podcast'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Podcast LN Address: $lnAddress'), // Display the LN Address here
              const SizedBox(height: 16.0),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  suffixText: 'sat',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Optional message',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (amountController.text.trim().isNotEmpty) {
                  final int amount = int.tryParse(amountController.text) ?? 10;
                  final String message = messageController.text;
                  await lnurl.lnurlPay(
                    lnAddress,
                    amount,
                    message,
                    allowInterop((invoice) => zapit(invoice)),
                  );
                }
              },
              child: const Text('Send Zap'),
            ),
          ],
        );
      },
    );
  }

  Future<void> zapit(String invoice) async {
    await lnurl.zapPodcast(invoice);
    Navigator.pop(context);
  }
}
