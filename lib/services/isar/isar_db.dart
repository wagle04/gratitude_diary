import 'dart:math';

import 'package:gratitude_diary/features/jourmal/data/models/auth_data.dart';
import 'package:gratitude_diary/services/isar/isar_collections.dart';
import 'package:gratitude_diary/services/logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDbService {
  Isar? isar;
  GoogleAuthData? user;
  List<GratitudeEntry> gratitudeEntries = [];

  IsarDbService() {
    init();
  }

  init() async {
    try {
      printLog("IsarDbService init");
      if (isar == null) {
        final dir = await getApplicationDocumentsDirectory();
        isar = await Isar.open(
          [
            UserSchema,
            GratitudeEntrySchema,
          ],
          directory: dir.path,
        );

        // //TODO remove this after testing

        // List<String> testGratitudeEntries = [
        //   "the sunshine. Sunshine brings warmth and light, lifting my spirits and energizing my day. It reminds me of the beauty and vitality of nature, brightening my mood.",
        //   "my health. Good health is the foundation of a fulfilling life, allowing me to engage in activities I love. It enables me to be active, productive, and enjoy each moment to the fullest.",
        //   "my friends. Friends provide companionship, support, and joy. They enrich my life with shared experiences, laughter, and a sense of belonging.",
        //   "a good night's sleep. Restful sleep rejuvenates my body and mind, preparing me for the day ahead. It enhances my mood, concentration, and overall well-being.",
        //   "the opportunities I have. Opportunities open doors to growth, learning, and new experiences. They allow me to pursue my passions and achieve my goals.",
        //   "the kindness of strangers. Acts of kindness from strangers restore my faith in humanity. They remind me that compassion and generosity exist everywhere.",
        //   "the roof over my head. Having a safe and comfortable home provides security and peace of mind. It is a refuge where I can relax and feel protected.",
        //   "the love in my life. Love from family, friends, and partners brings immense joy and fulfillment. It provides emotional support and a deep sense of connection.",
        //   "the lessons learned. Life's lessons, whether from successes or failures, contribute to my personal growth. They shape my character and make me wiser and more resilient.",
        //   "the beauty of the world. The world is filled with natural wonders and awe-inspiring sights. Appreciating this beauty brings me a sense of wonder and peace.",
        //   "the supportive community around me. A supportive community offers encouragement, resources, and a sense of belonging. It helps me feel connected and motivated.",
        //   "the time spent with loved ones. Time with loved ones creates cherished memories and strengthens bonds. It brings joy, laughter, and a sense of togetherness.",
        //   "the ability to learn new things. Learning keeps my mind sharp and opens up new possibilities. It allows me to grow, adapt, and stay curious about the world.",
        //   "the peaceful moments. Peaceful moments provide a break from the chaos of daily life. They allow me to reflect, recharge, and find inner calm.",
        //   "the laughter shared with friends. Laughter with friends creates joy and strengthens relationships. It brings light-heartedness and a sense of connection.",
        //   "the music that inspires me. Music has the power to uplift, motivate, and soothe. It adds richness to my life and can express emotions words cannot.",
        //   "the challenges that make me stronger. Challenges test my limits and build resilience. They teach me perseverance and help me grow stronger and more capable.",
        //   "the fresh air I breathe. Fresh air invigorates my body and mind, contributing to my health and well-being. It connects me to the natural world.",
        //   "the simple joys in life. Simple joys, like a beautiful sunset or a warm cup of coffee, bring happiness and contentment. They remind me to appreciate the small things.",
        //   "the memories I've made. Memories capture the meaningful moments and experiences of my life. They provide a sense of continuity and remind me of the joys and lessons of the past."
        // ];
        // await isar!.writeTxn(() async {
        //   await isar!.gratitudeEntrys.clear();

        //   for (int i = 5; i < 25; i++) {
        //     final gratitudeEntry = GratitudeEntry()
        //       ..text = testGratitudeEntries[i - 5]
        //       ..date = DateFormat('yyyy-MM-dd')
        //           .format(DateTime.now().subtract(Duration(days: i)));
        //     await isar!.gratitudeEntrys.put(gratitudeEntry);
        //   }
        // });
        //remove till here

        gratitudeEntries = await _getAllEntries();
      }
      printLog("IsarDbService initialized");
    } catch (e) {
      printLog("Error in DB: $e");
    }
  }

  GratitudeEntry getRandomEntry() {
    try {
      return gratitudeEntries[Random().nextInt(gratitudeEntries.length)];
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<void> setUserLoggedIn(GoogleAuthData userData) async {
    try {
      printLog("Saving user data in DB");
      await checkIsarNull();

      await isar!.writeTxn(() async {
        await isar!.users.clear();
      });
      final u = User()
        ..email = userData.email
        ..name = userData.name
        ..image = userData.image
        ..userId = userData.id
        ..token = userData.token
        ..brearerToken = userData.brearerToken;

      await isar!.writeTxn(() async {
        await isar!.users.put(u);
      });
      user = userData;
      printLog("User data saved in DB");
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      await checkIsarNull();
      final users = await isar!.users.where().findAll();
      if (users.length == 1) {
        user = GoogleAuthData(
          email: users[0].email,
          name: users[0].name,
          image: users[0].image,
          id: users[0].userId,
          token: users[0].token,
          brearerToken: users[0].brearerToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<void> logout() async {
    try {
      await checkIsarNull();
      await isar!.writeTxn(() async {
        await isar!.users.clear();
        await isar!.gratitudeEntrys.clear();
      });
      user = null;
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<void> checkIsarNull() async {
    if (isar == null) {
      await init();
    }
  }

  Future<void> saveGratitudeEntry(String text) async {
    try {
      await checkIsarNull();
      final gratitudeEntry = GratitudeEntry()
        ..text = text
        ..date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await isar!.writeTxn(() async {
        await isar!.gratitudeEntrys.put(gratitudeEntry);
      });
      gratitudeEntries = await _getAllEntries();
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<void> saveAllGratitudeEntries(List<GratitudeEntry> entries) async {
    try {
      await checkIsarNull();
      await isar!.writeTxn(() async {
        await isar!.gratitudeEntrys.clear();
        for (final entry in entries) {
          await isar!.gratitudeEntrys.put(entry);
        }
      });
      gratitudeEntries = await _getAllEntries();
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<bool> hasEnteredToday() async {
    try {
      if (gratitudeEntries.isEmpty) {
        gratitudeEntries = await _getAllEntries();
      }
      final entries = gratitudeEntries;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return entries.any((e) => e.date == today);
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<bool> hasMoreThanTenEntries() async {
    try {
      if (gratitudeEntries.isEmpty) {
        gratitudeEntries = await _getAllEntries();
      }
      return gratitudeEntries.length >= 10;
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<Map<String, List>> getAllEntriesString() async {
    try {
      gratitudeEntries = await _getAllEntries();

      final entries = gratitudeEntries;
      final Map<String, List> entriesMap = {};
      entriesMap['entries'] = [];

      for (final entry in entries) {
        entriesMap['entries']!.add(entry.toString());
      }

      return entriesMap;
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<List<GratitudeEntry>> _getAllEntries() async {
    try {
      await checkIsarNull();
      final entries = await isar!.gratitudeEntrys.where().findAll();
      return entries;
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }

  Future<Set<String?>> getDatesOfEntries() async {
    try {
      if (gratitudeEntries.isEmpty) {
        gratitudeEntries = await _getAllEntries();
      }
      return gratitudeEntries.map((e) => e.date).toSet();
    } catch (e) {
      throw Exception("Error in DB: $e");
    }
  }
}
