import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppleBookScrollPage extends StatefulWidget {
  const AppleBookScrollPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const AppleBookScrollPage());

  @override
  State<AppleBookScrollPage> createState() => _AppleBookScrollPageState();
}

class _AppleBookScrollPageState extends State<AppleBookScrollPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        bottom: false,
        child: PageView(
          // physics: const NeverScrollableScrollPhysics(),
          padEnds: false,
          children: const [
            BookWidget(),
            BookWidget(),
            BookWidget(),
          ],
        ),
      ),
    );
  }
}

class BookWidget extends StatefulWidget {
  const BookWidget({
    super.key,
  });

  @override
  State<BookWidget> createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> {
  double scrollPadding = 15;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // print(notificiation.metrics.pixels);

        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels > 10 && scrollPadding > 1) {
            setState(() {
              scrollPadding -= 1;
            });
          } else if (notification.metrics.pixels < 10 && scrollPadding <= 15) {
            setState(() {
              scrollPadding += 1;
            });
          }
        }
        if (notification is OverscrollNotification) {
          print("overscroll");
        }
        return false;
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: scrollPadding, right: 5),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF387339),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF6D9D6D),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                      Spacer(),
                      CircleAvatar(
                        backgroundColor: Color(0xFF6D9D6D),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Color(0xFF6D9D6D),
                        child: Icon(Icons.more_horiz, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Assets.images.book1.image(
                    height: 300,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'The Lexington Letter',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Anonymous',
                            style: textTheme.bodyLarge,
                          ),
                          const Icon(
                            Iconsax.arrow_right_3,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.star1,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '4.8 (32) . Crime & Thrillers ',
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D9D6D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Book',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Iconsax.info_circle, size: 20),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '45 Pages',
                          style: textTheme.bodyLarge?.copyWith(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(40),
                                ),
                                icon: const Icon(Iconsax.book),
                                label: const Text("Sample"),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  fixedSize: const Size.fromHeight(40),
                                ),
                                child: Text(
                                  "Get",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From the Publishers',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Requirements',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Apple Books',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Requires iOS 12 or MacOS 10.14 or later',
                    style: textTheme.bodyLarge?.copyWith(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Versions',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Update Mar 16 2022',
                    style: textTheme.bodyLarge?.copyWith(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
