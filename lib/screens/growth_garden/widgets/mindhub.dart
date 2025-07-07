import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/constants/colors.dart';
import 'feature_cards.dart';

class MindHubButton extends StatelessWidget {
  const MindHubButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width < 510
        ? MediaQuery.of(context).size.width / 2 - 20
        : 500 / 2 - 20;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FeatureCard(
            title: 'Safe Space Hub',
            icon: Icons.lightbulb,
            description:
            'Explore mental health resources: articles, videos, and eBooks for self-help support.',
            onTap: () {
              context.go('/mindhub/Articles');
            },
            width: width,
          ),
        ],
      ),
    );
  }
}
