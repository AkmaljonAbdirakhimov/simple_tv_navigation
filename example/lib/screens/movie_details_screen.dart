import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

import '../navigation/navigator_service.dart';
import '../widgets/payment_confirmation_dialog.dart';
import '../widgets/payment_methods_dialog.dart';
import 'payment_screen.dart';

class MovieDetailsScreen extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? description;
  final double rating;
  final String? releaseYear;
  final List<String>? genres;
  final String? duration;

  const MovieDetailsScreen({
    super.key,
    required this.title,
    this.imageUrl,
    this.description,
    this.rating = 0.0,
    this.releaseYear,
    this.genres,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: TVFocusable(
          autofocus: true,
          id: "back-button",
          rightId: "play-button",
          downId: "add-to-watchlist-button",
          onSelect: () {
            if (NavigatorService.canPop()) {
              NavigatorService.pop();
            }
          },
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (NavigatorService.canPop()) {
                NavigatorService.pop();
              }
            },
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Banner/Poster
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Center(
                            child: Icon(
                              Icons.movie,
                              size: 80,
                              color: Colors.white54,
                            ),
                          )
                        : null,
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Info Row
                        Wrap(
                          spacing: 12,
                          children: [
                            if (releaseYear != null)
                              Chip(label: Text(releaseYear!)),
                            if (duration != null) Chip(label: Text(duration!)),
                            ...(genres ?? [])
                                .map((genre) => Chip(label: Text(genre))),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TVFocusable(
                              id: "play-button",
                              upId: "back-button",
                              leftId: "back-button",
                              rightId: "add-to-watchlist-button",
                              downId: "description-section",
                              onSelect: () {
                                _startPaymentFlow(context);
                              },
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("PLAY"),
                                onPressed: () {
                                  _startPaymentFlow(context);
                                },
                              ),
                            ),
                            TVFocusable(
                              id: "add-to-watchlist-button",
                              leftId: "play-button",
                              rightId: "share-button",
                              upId: "back-button",
                              downId: "description-section",
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text("WATCHLIST"),
                                onPressed: () {
                                  // Add to watchlist
                                },
                              ),
                            ),
                            TVFocusable(
                              id: "share-button",
                              leftId: "add-to-watchlist-button",
                              upId: "back-button",
                              downId: "description-section",
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                icon: const Icon(Icons.share),
                                label: const Text("SHARE"),
                                onPressed: () {
                                  // Share the movie
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        TVFocusable(
                          id: "description-section",
                          upId: "play-button",
                          downId: "similar-movies-section",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Description",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description ?? "No description available.",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Similar Movies
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TVFocusable(
                              id: "similar-movies-section",
                              upId: "description-section",
                              downId: "similar-movies-0",
                              child: const Text(
                                "Similar Movies",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return TVFocusable(
                                    id: "similar-movies-$index",
                                    upId: "similar-movies-section",
                                    leftId: index == 0
                                        ? null
                                        : "similar-movies-${index - 1}",
                                    rightId: index == 9
                                        ? null
                                        : "similar-movies-${index + 1}",
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.red.withOpacity(0.3),
                                      ),
                                      child: Stack(
                                        children: [
                                          const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 50,
                                              color: Colors.white54,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Movie ${index + 1}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star,
                                                      size: 12),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    (3 + index * 0.2)
                                                        .toStringAsFixed(1),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPaymentFlow(BuildContext context) async {
    // Step 1: Show payment methods dialog
    final selectedMethod = await PaymentMethodsDialog.show(context);

    if (selectedMethod == null || !context.mounted) {
      if (context.mounted) {
        context.setFocus("play-button");
      }

      return;
    }

    // Calculate a movie price based on rating (just for demonstration)
    final price = 4.99 + (rating > 4.0 ? 2.0 : 0.0);

    // Step 2: Show confirmation dialog
    final confirmed = await PaymentConfirmationDialog.show(
      context: context,
      paymentMethod: selectedMethod,
      amount: price,
      movieTitle: title,
      onConfirm: () {
        if (context.mounted) {
          // Step 3: Navigate to payment screen
          NavigatorService.push(
            PaymentScreen(
              paymentMethod: selectedMethod,
              movieTitle: title,
              amount: price,
            ),
          ).then((_) {
            if (context.mounted) {
              context.setFocus("play-button");
            }
          });
        }
      },
    );

    // If user didn't confirm, just return
    if (confirmed != true) {
      if (context.mounted) {
        context.setFocus("play-button");
      }
    }
  }
}
