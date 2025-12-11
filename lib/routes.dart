import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'MainLayout.dart';
import 'CommunityScreen.dart';
import 'screens/MainContentArea.dart';
import 'screens/loginscreen.dart';
import 'screens/createaccount.dart';
import 'screens/forgotpassword.dart';
import 'screens/homePage.dart';
import 'screens/book_now/booknowscreen.dart';
import 'screens/account_screen/account.dart';
import 'screens/account_screen/app_settings/app_settings_screen.dart';
import 'screens/account_screen/accounts_privacy/accounts_privacy_page.dart';

import 'screens/growth_garden/growth_garden.dart';
import 'screens/growth_garden/widgets/mindhubscreen.dart';
import 'screens/growth_garden/widgets/QuizScreen.dart';
import 'screens/growth_garden/widgets/insight_quest.dart';
import 'screens/growth_garden/quick_meditation_techniques/body_scan_meditation.dart';
import 'screens/growth_garden/quick_meditation_techniques/breath_awareness.dart';
import 'screens/growth_garden/quick_meditation_techniques/gratitude_meditation.dart';
import 'screens/growth_garden/mindful_breathing_techniques/4-7-8_breathing.dart';
import 'screens/growth_garden/mindful_breathing_techniques/alternate_nostril_breathing.dart';
import 'screens/growth_garden/mindful_breathing_techniques/box_breathing.dart';

import 'screens/homescreen/safe_space/safetalk.dart';
import 'screens/homescreen/safe_space/chat_screen.dart';
import 'screens/homescreen/safe_space/queue_screen.dart';
import 'screens/homescreen/call_ended_screen.dart';
import 'screens/homescreen/calling_customer_support_screen.dart';
import 'screens/homescreen/booking_review_screen.dart';

import 'widgets/accounts_screen/ticket_detail_page.dart';
import 'widgets/accounts_screen/TIcket_Popup_widget.dart';

import 'providers/userProvider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',

  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isLoggedIn;

    final protected = [
      '/growth-garden',
      '/book-now',
      '/community',
      '/account',
      '/safe-talk',
      '/chat',
      '/queue',
      '/safe_talk/queue',
      '/booking-review',
      '/app-settings',
      '/account-privacy',
      '/support-tickets',
      '/calling-customer-support',
      '/ticket',
    ];

    final path = state.uri.path;
    final needsAuth = protected.any((p) => path.startsWith(p));

    if (!isLoggedIn && needsAuth) {
      return '/login';
    }

    return null;
  },

  errorBuilder: (context, state) {
    Future.microtask(() => context.go('/home'));
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  },

  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, __) => '/home',
        ),

        // AUTH
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // NAVIGATION
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainContentArea(),
        ),
        GoRoute(
          path: '/growth-garden',
          builder: (context, state) => GrowthGardenScreen(),
        ),
        GoRoute(
          path: '/book-now',
          builder: (context, state) => BookNowScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => CommunityScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => AccountScreen(),
        ),

        // SAFE TALK
        GoRoute(
          path: '/safe-talk',
          builder: (context, state) => const SafeTalk(),
        ),
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) =>
              ChatScreen(userId: state.pathParameters['userId']!),
        ),
        GoRoute(
          path: '/queue/:sessionType/:userId/:queueDocId',
          builder: (context, state) => QueueScreen(
            sessionType: state.pathParameters['sessionType']!,
            userId: state.pathParameters['userId']!,

          ),
        ),
        GoRoute(
          path: '/safe_talk/queue/:sessionType/:userId/:queueDocId',
          builder: (context, state) => QueueScreen(
            sessionType: state.pathParameters['sessionType']!,
            userId: state.pathParameters['userId']!,

          ),
        ),

        // CALL FLOW
        GoRoute(
          path: '/call-ended',
          builder: (context, state) => const CallEndedScreen(),
        ),
        GoRoute(
          path: '/calling-customer-support',
          builder: (context, state) => CallingCustomerSupportScreen(
            roomId: null,
            isCaller: true,
          ),
        ),
        GoRoute(
          path: '/session-ended',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text("Session Ended")),
            body: const Center(
              child: Text(
                "Your chat session has ended. Please rejoin if needed.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // BOOKING REVIEW
        GoRoute(
          path: '/booking-review',
          builder: (context, state) => BookingReviewScreen(
            consultationType:
            state.uri.queryParameters['consultationType'] ?? '',
            selectedDate: state.uri.queryParameters['selectedDate'] ?? '',
            selectedTime: state.uri.queryParameters['selectedTime'] ?? '',
            service: state.uri.queryParameters['service'] ?? '',
          ),
        ),

        // SETTINGS
        GoRoute(
          path: '/app-settings',
          builder: (context, state) => const AppSettingsPage(),
        ),
        GoRoute(
          path: '/account-privacy',
          builder: (context, state) => const AccountPrivacyPage(),
        ),

        // SUPPORT
        GoRoute(
          path: '/support-tickets',
          builder: (context, state) => SupportTicketsPage(),
        ),
        GoRoute(
          path: '/ticket/:id',
          builder: (context, state) =>
              TicketDetailPage(ticketId: state.pathParameters['id']!),
        ),

        // BREATHING ROUTES
        GoRoute(
          path: '/box-breathing',
          builder: (context, state) => const BoxBreathingScreen(),
        ),
        GoRoute(
          path: '/4-7-8-breathing',
          builder: (context, state) =>
          const FourSevenEightBreathingScreen(),
        ),
        GoRoute(
          path: '/alternate-nostril-breathing',
          builder: (context, state) =>
          const AlternateNostrilBreathingScreen(),
        ),

        // MEDITATION ROUTES
        GoRoute(
          path: '/meditation/body-scan',
          builder: (context, state) =>
          const BodyScanMeditationScreen(),
        ),
        GoRoute(
          path: '/meditation/gratitude',
          builder: (context, state) =>
          const GratitudeMeditationScreen(),
        ),
        GoRoute(
          path: '/meditation/breath-awareness',
          builder: (context, state) =>
          const BreathAwarenessMeditationScreen(),
        ),

        // MINDHUB ROUTES
        GoRoute(
          path: '/mindhub/:category',
          builder: (context, state) =>
              MindHubScreen(category: state.pathParameters['category']!),
        ),

        // QUIZ & INSIGHT
        GoRoute(
          path: '/insight-quest',
          builder: (context, state) => const InsightQuestScreen(),
        ),
        GoRoute(
          path: '/quiz/:category',
          builder: (context, state) =>
              QuizScreen(category: state.pathParameters['category']!),
        ),
      ],
    ),
  ],
);
