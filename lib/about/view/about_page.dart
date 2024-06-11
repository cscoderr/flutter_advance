import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const AboutPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Assets.images.img2.image(height: 100, width: 100),
          const SizedBox(height: 10),
          Text(
            'TOMIWA IDOWU',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          Text(
            'Software Engineer',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          const _AboutListTile(
            title: 'Github',
            uri: 'https://github.com/cscoderr',
            icon: FontAwesomeIcons.github,
          ),
          const Divider(),
          const _AboutListTile(
            title: 'X (Twitter)',
            uri: 'https://github.com/cscoderr',
            icon: FontAwesomeIcons.twitter,
          ),
          const Divider(),
          const _AboutListTile(
            title: 'Linkedin',
            uri: 'https://linkedin.com/in/tomiwaidowu',
            icon: FontAwesomeIcons.linkedinIn,
          ),
        ],
      ),
    );
  }
}

class _AboutListTile extends StatelessWidget {
  const _AboutListTile({
    required this.title,
    required this.uri,
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String uri;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FaIcon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        subtitle ?? uri,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
      trailing: const Icon(Iconsax.arrow_right_3),
      onTap: () async {
        final parsedUri = Uri.parse(uri);
        if (!await launchUrl(parsedUri)) {
          throw Exception('Could not launch $uri');
        }
      },
    );
  }
}
