import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';

// -- Design Constants --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

class OnboardingPage extends StatefulWidget {
  final AppRouter router;
  const OnboardingPage({super.key, required this.router});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _agreementChecked = false;

  void _finishOnboardingAndNavigate(String route) async {
    await widget.router.setOnboardingSeen();
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [_buildIntroPage(), _buildDisclaimerPage()],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel_rounded, // Example icon
            size: 100,
            color: kButtonColor,
          ),
          SizedBox(height: 40),
          Text(
            "Welcome to LawGen",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "Learn about your legal rights and obligations. Ask and gain valuable information.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: kSecondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Important Disclaimer",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            "The information provided by this app is for educational and informational purposes only. It is not a substitute for professional legal advice.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: kSecondaryTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              setState(() {
                _agreementChecked = !_agreementChecked;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreementChecked,
                  onChanged: (value) {
                    setState(() {
                      _agreementChecked = value ?? false;
                    });
                  },
                  activeColor: kButtonColor,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      "I understand that this app is for educational purposes only and not legal advice.",
                      style: TextStyle(color: kPrimaryTextColor, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Page indicators in the center
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2,
              (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),
          // Buttons aligned to the left and right
          if (_currentPage == 0)
            Align(
              alignment: Alignment.centerRight,
              child: _buildTextButton("Next", () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }),
            ),
          if (_currentPage == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTextButton("Back", () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }),
                ElevatedButton(
                  onPressed: _agreementChecked
                      ? () => _finishOnboardingAndNavigate('/signin')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    disabledBackgroundColor: kButtonColor.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? kButtonColor : kShadowColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: kButtonColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
