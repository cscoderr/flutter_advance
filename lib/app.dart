import 'package:animation_playground/animated_card/animated_card.dart';
import 'package:animation_playground/animated_lock/animated_lock.dart';
import 'package:animation_playground/animated_progress_bar/animated_progress_bar.dart';
import 'package:animation_playground/animated_slider/view/animated_slider_page.dart';
import 'package:animation_playground/apple_book_scroll/apple_book_scroll.dart';
import 'package:animation_playground/blur_animation/blur_animation.dart';
import 'package:animation_playground/core/core.dart';
import 'package:animation_playground/coverflow_carousel/coverflow_carousel.dart';
import 'package:animation_playground/petal_menu/petal_menu.dart';
import 'package:animation_playground/photo_extractor/photo_extractor.dart';
import 'package:animation_playground/rainbow_sticks/rainbow_sticks.dart';
import 'package:animation_playground/text_particle/text_particle.dart';
import 'package:animation_playground/text_shimmer_wave/text_shimmer_wave.dart';
import 'package:animation_playground/thanos_snap_effect/view/thanos_snap_effect_page.dart';
import 'package:animation_playground/water_wave_animation/water_wave_animation_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'about/about.dart';
import 'phone_pattern/phone_pattern.dart';
import 'swipe_to_pay/swipe_to_pay.dart';
import 'tarot_scroll/view/tarot_scroll_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        title: const Text("Flutter Animations"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(AboutPage.route()),
            icon: Icon(
              Iconsax.info_circle,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        children: [
          const AppTextDivider(text: 'New'),
          AppElevatedButton(
            text: "Text Particle Animation",
            icon: const Icon(Iconsax.text),
            onPressed: () =>
                Navigator.of(context).push(TextParticlePage.route()),
          ),
          const AppTextDivider(text: 'Latest'),
          AppElevatedButton(
            text: "Apple Book Scroll Animation",
            icon: const Icon(Iconsax.book),
            onPressed: () =>
                Navigator.of(context).push(AppleBookScrollPage.route()),
          ),
          const SizedBox(height: 20),
          AppElevatedButton(
            text: "Tarrot Scroll",
            icon: const Icon(Iconsax.coin),
            onPressed: () =>
                Navigator.of(context).push(TarotScrollPage.route()),
          ),
          const SizedBox(height: 20),
          AppElevatedButton(
            text: "Coverflow Carousel",
            icon: const Icon(Iconsax.scroll),
            onPressed: () =>
                Navigator.of(context).push(CoverFlowCarouselPage.route()),
          ),
          // const SizedBox(height: 20),
          // AppElevatedButton(
          //   text: "Tapcoin Animation",
          //   icon: const Icon(Iconsax.coin),
          //   onPressed: () =>
          //       Navigator.of(context).push(TapCoinAnimationPage.route()),
          // ),
          const SizedBox(height: 20),
          // //
          const AppTextDivider(text: '🥸'),
          AppElevatedButton(
            text: "Thanos Snap Effect",
            icon: const Icon(Iconsax.path),
            onPressed: () =>
                Navigator.of(context).push(ThanosSnapEffectPage.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Photo Extractor",
            icon: const Icon(Iconsax.picture_frame),
            onPressed: () => Navigator.of(context).push(PhotoExtractor.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Swipe to pay",
            icon: const Icon(Iconsax.money_2),
            onPressed: () => Navigator.of(context).push(SwipeToPayPage.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Rainbow Stick Animation",
            icon: const Icon(Iconsax.colorfilter),
            onPressed: () =>
                Navigator.of(context).push(RainbowSticksPage.route()),
          ),
          const SizedBox(height: 20),

          // //
          const AppTextDivider(text: '😍'),
          AppElevatedButton(
            text: "Text Shimmer",
            icon: const Icon(Iconsax.text),
            onPressed: () =>
                Navigator.of(context).push(TextShimmerWavePage.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Animated Slider",
            icon: const Icon(Iconsax.slider),
            onPressed: () =>
                Navigator.of(context).push(AnimatedSliderPage.route()),
          ),

          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Blur Animation",
            icon: const Icon(Iconsax.blur),
            onPressed: () => Navigator.of(context).push(BlurAnimation.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Petal Menu Animation",
            icon: const Icon(Iconsax.color_swatch),
            onPressed: () => Navigator.of(context).push(PetalMenuPage.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Phone Pattern",
            icon: const Icon(Iconsax.headphone),
            onPressed: () =>
                Navigator.of(context).push(PhonePatternPage.route()),
          ),
          const SizedBox(height: 20),

          // //
          const AppTextDivider(text: '🥳'),
          AppElevatedButton(
            text: "Animated Card",
            icon: const Icon(Iconsax.card_send),
            onPressed: () =>
                Navigator.of(context).push(AnimatedCardPage.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Animated Lock",
            icon: const Icon(Iconsax.lock_1),
            onPressed: () =>
                Navigator.of(context).push(AnimatedLockPage.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Animated Progress Bar",
            icon: const Icon(Iconsax.slider_vertical),
            onPressed: () =>
                Navigator.of(context).push(AnimatedProgressBar.route()),
          ),
          const SizedBox(height: 10),
          AppElevatedButton(
            text: "Water Wave Animation",
            icon: const Icon(Iconsax.aquarius),
            onPressed: () =>
                Navigator.of(context).push(WaterWaveAnimationPage.route()),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
