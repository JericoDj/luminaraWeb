import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminarawebsite/screens/MainContentArea.dart';
import 'package:luminarawebsite/screens/account_screen/accounts_privacy/accounts_privacy_page.dart';
import 'package:luminarawebsite/screens/account_screen/app_settings/app_settings_screen.dart';
import 'package:luminarawebsite/screens/createaccount.dart';
import 'package:luminarawebsite/screens/forgotpassword.dart';
import 'package:luminarawebsite/screens/growth_garden/mindful_breathing_techniques/4-7-8_breathing.dart';
import 'package:luminarawebsite/screens/growth_garden/mindful_breathing_techniques/alternate_nostril_breathing.dart';
import 'package:luminarawebsite/screens/growth_garden/mindful_breathing_techniques/box_breathing.dart';
import 'package:luminarawebsite/screens/growth_garden/quick_meditation_techniques/body_scan_meditation.dart';
import 'package:luminarawebsite/screens/growth_garden/quick_meditation_techniques/breath_awareness.dart';
import 'package:luminarawebsite/screens/growth_garden/quick_meditation_techniques/gratitude_meditation.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/QuizScreen.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/insight_quest.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/mindhubscreen.dart';
import 'package:luminarawebsite/screens/homescreen/booking_review_screen.dart';
import 'package:luminarawebsite/screens/homescreen/call_ended_screen.dart';
import 'package:luminarawebsite/screens/homescreen/calling_customer_support_screen.dart';
import 'package:luminarawebsite/screens/homescreen/safe_space/chat_screen.dart';
import 'package:luminarawebsite/screens/homescreen/safe_space/queue_screen.dart';
import 'package:luminarawebsite/screens/homescreen/safe_space/safetalk.dart';
import 'package:luminarawebsite/screens/loginscreen.dart';
import 'package:luminarawebsite/widgets/accounts_screen/TIcket_Popup_widget.dart';


import 'MainLayout.dart';
import 'screens/homePage.dart';
import 'screens/growth_garden/growth_garden.dart';
import 'screens/book_now/booknowscreen.dart';
import 'CommunityScreen.dart';
import 'screens/account_screen/account.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child); // Persistent AppBar
      },
      routes: [

        //Authentication Routes

        GoRoute(
          path: '/login',
          builder: (context, state) =>  LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),


        //NavBar
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const MainContentArea(),
        ),
        GoRoute(
          path: '/growth-garden',
          name: 'growthGarden',
          builder: (context, state) => GrowthGardenScreen(),
        ),
        GoRoute(
          path: '/book-now',
          name: 'bookNow',
          builder: (context, state) => BookNowScreen(),
        ),
        GoRoute(
          path: '/community',
          name: 'community',
          builder: (context, state) => CommunityScreen(),
        ),
        GoRoute(
          path: '/account',
          name: 'account',
          builder: (context, state) => AccountScreen(),
        ),


        //MainContent
        GoRoute(
          path: '/safe-talk',
          builder: (context, state) => const SafeTalk(), // or SafeTalk() if it's not const
        ),

        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return ChatScreen(userId: userId);
          },
        ),

        GoRoute(
          path: '/call-ended',
          builder: (context, state) => const CallEndedScreen(),
        ),

        GoRoute(
          path: '/session-ended',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text("Session Ended")),
            body: const Center(
              child: Text(
                "Your chat session has ended. Please rejoin if needed.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),

        GoRoute(
          path: '/queue/:sessionType/:userId/:queueDocId',
          builder: (context, state) {
            return QueueScreen(
              sessionType: state.pathParameters['sessionType']!,
              userId: state.pathParameters['userId']!,
              queueDocId: state.pathParameters['queueDocId']!,
            );
          },
        ),

        GoRoute(
          path: '/safe_talk/queue/:sessionType/:userId/:queueDocId',
          builder: (context, state) {
            final sessionType = state.pathParameters['sessionType']!;
            final userId = state.pathParameters['userId']!;
            final queueDocId = state.pathParameters['queueDocId']!;
            return QueueScreen(
              sessionType: sessionType,
              userId: userId,
              queueDocId: queueDocId,
            );
          },
        ),




        // Meditation Routes

        GoRoute(
          path: '/meditation/body-scan',
          name: 'bodyScanMeditation',
          builder: (context, state) => const BodyScanMeditationScreen(),
        ),
        GoRoute(
          path: '/meditation/gratitude',
          name: 'gratitudeMeditation',
          builder: (context, state) => const GratitudeMeditationScreen(),
        ),
        GoRoute(
          path: '/meditation/breath-awareness',
          name: 'breathAwarenessMeditation',
          builder: (context, state) => const BreathAwarenessMeditationScreen(),
        ),


        //  Breathing Routes

        GoRoute(
          path: '/box-breathing',
          builder: (context, state) => const BoxBreathingScreen(),
        ),
        GoRoute(
          path: '/4-7-8-breathing',
          builder: (context, state) => const FourSevenEightBreathingScreen(),
        ),
        GoRoute(
          path: '/alternate-nostril-breathing',
          builder: (context, state) => const AlternateNostrilBreathingScreen(),
        ),


        //MindhubRoute

        GoRoute(
          path: '/mindhub/:category',
          builder: (context, state) {
            final category = state.pathParameters['category']!;
            return MindHubScreen(category: category);
          },
        ),


        //Insight Quest Route,

        GoRoute(
          path: '/insight-quest',
          builder: (context, state) => const InsightQuestScreen(),
        ),
        GoRoute(
          path: '/quiz/:category',
          builder: (context, state) {
            final category = state.pathParameters['category']!;
            return QuizScreen(category: category);
          },
        ),

        //Book Now Route
        GoRoute(
          path: '/booking-review',
          builder: (context, state) {
            final consultationType = state.uri.queryParameters['consultationType'] ?? '';
            final selectedDate = state.uri.queryParameters['selectedDate'] ?? '';
            final selectedTime = state.uri.queryParameters['selectedTime'] ?? '';
            final service = state.uri.queryParameters['service'] ?? '';

            return BookingReviewScreen(
              consultationType: consultationType,
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              service: service,
            );
          },
        ),


        GoRoute(
          path: '/app-settings',
          builder: (context, state) => const AppSettingsPage(),
        ),
        GoRoute(
          path: '/account-privacy',
          builder: (context, state) => const AccountPrivacyPage(),
        ),

        GoRoute(
          path: '/support-tickets',
          builder: (context, state) =>SupportTicketsPage(),
        ),


        // Customer Support
        GoRoute(
          path: '/calling-customer-support',
          builder: (context, state) =>  CallingCustomerSupportScreen(
            roomId: null,
            isCaller: true,
          ),
        ),

      ],
    ),
  ],
);
