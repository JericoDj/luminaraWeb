import 'package:flutter/material.dart';

/// 📌 Fixed Quiz Data for Insight Quest with 5 Questions Each
final Map<String, dynamic> quizData = {
  "Mindfulness": {
    "isPersonalityBased": true,
    "questions": [
      {
        "question": "How often do you take a moment to breathe and be present?",
        "answers": [
          {"text": "Very often", "score": 3},
          {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Almost never", "score": 0},
        ]
      },
      {
        "question": "Do you often catch yourself overthinking?",
        "answers": [
          {"text": "Rarely", "score": 3},
          {"text": "Occasionally", "score": 2},
          {"text": "Often", "score": 1},
          {"text": "Always", "score": 0},
        ]
      },
      {
        "question": "How often do you practice gratitude?",
        "answers": [
          {"text": "Daily", "score": 3},
          {"text": "A few times a week", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Never", "score": 0},
        ]
      },
      {
        "question": "Do you find joy in small moments?",
        "answers": [
          {"text": "Always", "score": 3},
          {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Never", "score": 0},
        ]
      },
      {
        "question": "Are you able to focus on the present without distraction?",
        "answers": [
          {"text": "Yes, most of the time", "score": 3},
            {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "I get distracted easily", "score": 0},
        ]
      }
    ]
  },



  "Cognitive Skills": {
    "isPersonalityBased": false,
    "questions": [
      {
        "question": "Which part of the brain is responsible for problem-solving?",
        "answers": [
          {"text": "Frontal lobe", "isCorrect": true},
          {"text": "Occipital lobe", "isCorrect": false},
          {"text": "Temporal lobe", "isCorrect": false},
          {"text": "Parietal lobe", "isCorrect": false},
        ]
      },
      {
        "question": "What is 15 + 27?",
        "answers": [
          {"text": "42", "isCorrect": true},
          {"text": "39", "isCorrect": false},
          {"text": "47", "isCorrect": false},
          {"text": "41", "isCorrect": false},
        ]
      },
      {
        "question": "What is the capital of France?",
        "answers": [
          {"text": "Paris", "isCorrect": true},
          {"text": "London", "isCorrect": false},
          {"text": "Rome", "isCorrect": false},
          {"text": "Berlin", "isCorrect": false},
        ]
      },
      {
        "question": "What does CPU stand for?",
        "answers": [
          {"text": "Central Processing Unit", "isCorrect": true},
          {"text": "Computer Power Unit", "isCorrect": false},
          {"text": "Central Program Unit", "isCorrect": false},
          {"text": "Central Processing Utility", "isCorrect": false},
        ]
      },
      {
        "question": "Which of the following is a prime number?",
        "answers": [
          {"text": "17", "isCorrect": true},
          {"text": "21", "isCorrect": false},
          {"text": "33", "isCorrect": false},
          {"text": "44", "isCorrect": false},
        ]
      }
    ]
  },
  "Emotional Intelligence": {
    "isPersonalityBased": true,
    "questions": [
      {
        "question": "How well do you recognize emotions in yourself and others?",
        "answers": [
          {"text": "Very well", "score": 3},
          {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Not at all", "score": 0},
        ]
      },
      {
        "question": "How easily do you empathize with others?",
        "answers": [
          {"text": "Very easily", "score": 3},
          {"text": "Somewhat easily", "score": 2},
          {"text": "Not very easily", "score": 1},
          {"text": "I struggle with empathy", "score": 0},
        ]
      },
      {
        "question": "How well do you manage your emotions under stress?",
        "answers": [
          {"text": "Very well", "score": 3},
          {"text": "Somewhat well", "score": 2},
          {"text": "Not very well", "score": 1},
          {"text": "I often struggle", "score": 0},
        ]
      },
      {
        "question": "How do you react to criticism?",
        "answers": [
          {"text": "I take it as a learning opportunity", "score": 3},
          {"text": "I try to be open-minded", "score": 2},
          {"text": "I get defensive", "score": 1},
          {"text": "I feel very hurt", "score": 0},
        ]
      },
      {
        "question": "Do you find it easy to express your emotions clearly?",
        "answers": [
          {"text": "Yes, very easily", "score": 3},
          {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "No, I struggle to express emotions", "score": 0},
        ]
      }
    ]
  },

  "Resilience": {
    "isPersonalityBased": true,
    "questions": [
      {
        "question": "How well do you handle stressful situations?",
        "answers": [
          {"text": "Very well", "score": 3},
          {"text": "Sometimes well", "score": 2},
          {"text": "Not very well", "score": 1},
          {"text": "I often struggle", "score": 0},
        ]
      },
      {
        "question": "Do you bounce back quickly from failures?",
        "answers": [
          {"text": "Yes, always", "score": 3},
          {"text": "Most of the time", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "No, I dwell on failures", "score": 0},
        ]
      },
      {
        "question": "How often do you challenge yourself to grow?",
        "answers": [
          {"text": "Very often", "score": 3},
          {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Never", "score": 0},
        ]
      },
      {
        "question": "Do you believe you can overcome obstacles?",
        "answers": [
          {"text": "Absolutely", "score": 3},
          {"text": "Most of the time", "score": 2},
          {"text": "Sometimes", "score": 1},
          {"text": "Not really", "score": 0},
        ]
      },
      {
        "question": "How do you react when things don't go as planned?",
        "answers": [
          {"text": "I adapt and find new solutions", "score": 3},
          {"text": "I take time but move forward", "score": 2},
          {"text": "I get frustrated", "score": 1},
          {"text": "I feel defeated", "score": 0},
        ]
      }
    ]
  },

  "Deep Focus": {
    "isPersonalityBased": true,
    "questions": [
      {
        "question": "Do you find it easy to concentrate for long periods?",
        "answers": [
          {"text": "Yes, very easy", "score": 3},
          {"text": "Sometimes", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "No, I get distracted often", "score": 0},
        ]
      },
      {
        "question": "How often do you engage in deep work?",
        "answers": [
          {"text": "Daily", "score": 3},
          {"text": "A few times a week", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Never", "score": 0},
        ]
      },
      {
        "question": "Do you struggle with multitasking?",
        "answers": [
          {"text": "Yes, always", "score": 0},
          {"text": "Sometimes", "score": 1},
          {"text": "Rarely", "score": 2},
          {"text": "No, I stay focused", "score": 3},
        ]
      },
      {
        "question": "How often do distractions interrupt your work?",
        "answers": [
          {"text": "Very often", "score": 0},
          {"text": "Sometimes", "score": 1},
          {"text": "Rarely", "score": 2},
          {"text": "Almost never", "score": 3},
        ]
      },
      {
        "question": "Do you use techniques like Pomodoro to stay focused?",
        "answers": [
          {"text": "Yes, frequently", "score": 3},
          {"text": "Occasionally", "score": 2},
          {"text": "Rarely", "score": 1},
          {"text": "Never", "score": 0},
        ]
      }
    ]
  }
};

