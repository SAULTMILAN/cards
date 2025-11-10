import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'models/tcg_card.dart';
import 'services/tcg_api.dart';

void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Pokemon Green Cards',
        debugShowCheckedModeBanner: false, 
			theme: ThemeData(primarySwatch: Colors.green),
			home: const CardListPage(),
		);
	}
}

class CardListPage extends StatefulWidget {
	const CardListPage({super.key});

	@override
	State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
	List<TcgCard> _cards = [];
	bool _loading = true;
	String? _error;

	@override
	void initState() {
		super.initState();
		_loadCards();
	}

	Future<void> _loadCards() async {
		try {
			final cards = await TcgApi.fetchGrassCards(pageSize: 50);
			setState(() {
				_cards = cards;
				_loading = false;
			});
		} catch (e) {
			setState(() {
				_error = e.toString();
				_loading = false;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Pokemon Green Cards')),
			body: _buildBody(),
		);
	}

	Widget _buildBody() {
		if (_loading) {
			return const Center(child: CircularProgressIndicator());
		}
		if (_error != null) {
			return Center(child: Text('Error: $_error'));
		}
		if (_cards.isEmpty) {
			return const Center(child: Text('No cards found'));
		}
		return ListView.builder(
			itemCount: _cards.length,
			itemBuilder: (context, index) {
				final card = _cards[index];
				final thumb = card.smallImageUrl;
				return ListTile(
					leading: Hero(
						tag: 'card-${card.id}',
						child: ClipRRect(
							borderRadius: BorderRadius.circular(8),
							child: thumb != null
									? CachedNetworkImage(
											imageUrl: thumb,
											width: 56,
											height: 56,
											fit: BoxFit.cover,
											placeholder: (context, url) => const SizedBox(
												width: 56,
												height: 56,
												child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
											),
											errorWidget: (context, url, error) => const Icon(Icons.broken_image),
										)
									: const SizedBox(width: 56, height: 56, child: Icon(Icons.image_not_supported)),
						),
					),
					title: Text(card.name),
					onTap: () => _openEnlarged(context, card),
				);
			},
		);
	}

	void _openEnlarged(BuildContext context, TcgCard card) {
		final largeUrl = card.largeImageUrl ?? card.smallImageUrl;
		showDialog(
			context: context,
			barrierColor: Colors.black87,
			builder: (context) {
				return GestureDetector(
					onTap: () => Navigator.of(context).pop(),
					child: Dismissible(
						key: Key('dialog-${card.id}'),
						direction: DismissDirection.down,
						onDismissed: (_) => Navigator.of(context).pop(),
						child: Container(
							color: Colors.black,
							alignment: Alignment.center,
							child: Hero(
								tag: 'card-${card.id}',
								child: InteractiveViewer(
									minScale: 0.8,
									maxScale: 4.0,
									child: largeUrl != null
											? CachedNetworkImage(
													imageUrl: largeUrl,
													fit: BoxFit.contain,
													placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
													errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
												)
											: const Icon(Icons.image_not_supported, color: Colors.white, size: 64),
								),
							),
						),
					),
				);
			},
		);
	}
}