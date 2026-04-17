import 'package:flutter/material.dart';
import '../components/onboarding_page.dart';
import '../components/onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < 3) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Navigate to Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [

          /// PAGE 1
          OnboardingPage(
            image: "assets/images/onboarding1.png",
            content: OnboardingContent(
              title: "Track your health in real time",
              subtitle:
                  "Heart rate, blood pressure, temperature, and oxygen — all monitored in one place.",
              buttonText: "Continue",
              onPressed: nextPage,
              currentIndex: currentIndex,
            ),
          ),

          /// PAGE 2
          OnboardingPage(
            image: "assets/images/onboarding2.png",
            content: OnboardingContent(
              title: "Never miss a dose again",
              subtitle:
                  "Set smart reminders and track your treatment progress easily.",
              buttonText: "Continue",
              onPressed: nextPage,
              currentIndex: currentIndex,
            ),
          ),

          /// PAGE 3
          OnboardingPage(
            image: "assets/images/onboarding3.png",
            content: OnboardingContent(
              title: "See your health progress",
              subtitle:
                  "Visualize your daily and weekly improvements with smart insights.",
              buttonText: "Continue",
              onPressed: nextPage,
              currentIndex: currentIndex,
            ),
          ),

          /// PAGE 4
          OnboardingPage(
            image: "assets/images/onboarding4.png",
            content: OnboardingContent(
              title: "Your wellbeing in one touch",
              subtitle:
                  "Nabad helps you stay connected to your health, every heartbeat of the way.",
              buttonText: "Get Started",
              onPressed: nextPage,
              currentIndex: currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}