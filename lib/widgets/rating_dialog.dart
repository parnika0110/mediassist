import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final Function(int rating, String review) onSubmit;

  const RatingDialog({super.key, required this.onSubmit});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int rating = 5;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 35,
      ),
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rate Doctor"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => buildStar(index + 1)),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Write a review (Optional)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            widget.onSubmit(rating, reviewController.text.trim());

            Navigator.pop(context);
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
