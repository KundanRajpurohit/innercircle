import 'package:flutter/material.dart';

class Home2Page extends StatefulWidget {
  const Home2Page({super.key});

  @override
  State<Home2Page> createState() => _HomePageState();
}

class _HomePageState extends State<Home2Page> {
  // UI state
  int selectedCategoryIndex = 0;
  int bottomNavIndex = 0;

  // Colors chosen to match the screenshot feel
  final Color bgDark = const Color(0xFF1F1F1F);
  final Color headerAccent = const Color(0xFFDE6E64); // pink-ish button
  final Color yellowCurve = const Color(0xFFF6E5A3);
  final Color cardBg = const Color(0xFF121212);
  final Color mutedWhite = Colors.white70;

  final List<String> categories = ['All', 'Movie', 'Sports', 'Dinner'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      // Floating action in center-right (mimics top-right create in screenshot)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreatePressed(),
        backgroundColor: headerAccent,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SingleChildScrollView(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Top dark header area
                  Container(
                    width: width,
                    color: bgDark,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        _buildHeaderRow(),
                        const SizedBox(height: 12),
                        _buildCategoryRow(),
                        const SizedBox(height: 18),
                        _buildHighlightedEventCard(width),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Curved yellow section with characters and title (positioned overlapping)
                  Positioned(
                    top: 260,
                    left: 0,
                    right: 0,
                    child: _CurvedYellowSection(
                      height: 420,
                      color: yellowCurve,
                      child: _buildCharactersAndText(width),
                    ),
                  ),

                  // Bottom nav placed visually at the bottom of the visible content
                  // We'll create extra space so SingleChildScrollView can scroll above it
                  Positioned(
                    top: 260 + 420 - 40, // overlap bottom slightly
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Spacer box so content ends above nav
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // Custom bottom navigation bar (floating like in screenshot)
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Hey, Vaani!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Discover amazing events near you",
                style: TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
            ],
          ),
        ),

        // Circular accent action button (matches screenshot)
        Container(
          decoration: BoxDecoration(
            color: headerAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: headerAccent.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _onProfilePressed(),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(categories.length, (i) {
        final isSelected = selectedCategoryIndex == i;
        return GestureDetector(
          onTap: () {
            setState(() => selectedCategoryIndex = i);
            // placeholder action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: ${categories[i]}')),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white
                      : const Color(0xFF2A2A2A), // slightly lighter dark
              borderRadius: BorderRadius.circular(14),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : [],
            ),
            child: Row(
              children: [
                Icon(
                  _categoryIconFor(categories[i]),
                  color: isSelected ? bgDark : Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  categories[i],
                  style: TextStyle(
                    color: isSelected ? bgDark : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHighlightedEventCard(double width) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          // left image card
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.only(left: 6, right: 10),
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Placeholder image
                  Positioned.fill(
                    child: Image.network(
                      'https://picsum.photos/800/400?blur=2',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // dark gradient bottom overlay with text
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 48,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Event 2 @ New Delhi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // right small info column
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.location_on, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'New Delhi',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 64,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Fri, 09 Oct',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text('7:00 PM', style: TextStyle(color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersAndText(double width) {
    return Column(
      children: [
        const SizedBox(height: 36),
        // Characters row (two placeholder images overlapped with slight offset)
        SizedBox(
          height: 220,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: width * 0.1,
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://placehold.co/260x400?text=Person+1',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: width * 0.18,
                  child: Transform.rotate(
                    angle: 0.02,
                    child: Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://placehold.co/260x400?text=Person+2',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // small center badge
                Positioned(
                  left: (width / 2) - 44,
                  bottom: -18,
                  child: Container(
                    width: 88,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Together',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          "Together",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          "Connect. Explore. Together",
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home, 0),
          _navItem(Icons.search, 1),
          // Center elevated create button placeholder (we already have FAB, but mimic screenshot)
          GestureDetector(
            onTap: _onCreatePressed,
            child: Container(
              width: 76,
              height: 56,
              decoration: BoxDecoration(
                color: headerAccent,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: headerAccent.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
          _navItem(Icons.notifications_none, 2),
          _navItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int idx) {
    final bool active = bottomNavIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => bottomNavIndex = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? headerAccent : Colors.black54, size: 26),
          const SizedBox(height: 6),
          Container(
            width: 26,
            height: 4,
            decoration: BoxDecoration(
              color: active ? headerAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIconFor(String name) {
    switch (name.toLowerCase()) {
      case 'movie':
        return Icons.movie;
      case 'sports':
        return Icons.sports_soccer;
      case 'dinner':
        return Icons.restaurant;
      default:
        return Icons.apps;
    }
  }

  void _onProfilePressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile tapped')));
  }

  void _onCreatePressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Create Event tapped')));
  }
}

/// A custom curved yellow section painter that matches the rounded top shape in screenshot.
/// We use a Stack with a CustomPaint background and a child placed inside.
class _CurvedYellowSection extends StatelessWidget {
  final double height;
  final Color color;
  final Widget child;

  const _CurvedYellowSection({
    required this.height,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Custom painted curved shape
          Positioned.fill(
            child: CustomPaint(painter: _YellowCurvePainter(color: color)),
          ),
          // Child content centered
          Positioned.fill(
            top: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _YellowCurvePainter extends CustomPainter {
  final Color color;
  _YellowCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint p = Paint()..color = color;

    final Path path = Path();
    // Start left slightly up, draw a smooth curve like screenshot
    path.moveTo(0, h * 0.25);
    path.quadraticBezierTo(w * 0.18, h * 0.05, w * 0.28, h * 0.08);
    path.quadraticBezierTo(w * 0.5, h * 0.14, w * 0.72, h * 0.08);
    path.quadraticBezierTo(w * 0.88, h * 0.05, w, h * 0.25);

    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawShadow(path, Colors.black87, 22, true);
    canvas.drawPath(path, p);

    // subtle highlight arc
    final Paint highlight =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withOpacity(0.06), Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, w, h));
    final Path hl = Path();
    hl.moveTo(0, h * 0.25);
    hl.quadraticBezierTo(w * 0.5, h * 0.06, w, h * 0.25);
    hl.lineTo(w, h * 0.35);
    hl.lineTo(0, h * 0.5);
    hl.close();
    canvas.drawPath(hl, highlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
