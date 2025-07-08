import 'package:hive_flutter/hive_flutter.dart';

class CacheUtils {
  static const List<String> _boxNames = [
    'storeCache',
    'userCache',
    'productCache',
    'menuCache',
    'promotionCache',
    'discountCodeCache',
    'payment_method',
    'searchCache',
  ];

  /// Clear all cache boxes safely
  static Future<void> clearAllCache() async {
    print('🧹 Starting cache cleanup...');

    for (final boxName in _boxNames) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
        print('✅ Cleared $boxName');
      } catch (e) {
        print('⚠️ Error clearing $boxName: $e');
      }
    }

    print('✅ Cache cleanup completed');
  }

  /// Open all cache boxes safely
  static Future<void> openAllBoxes() async {
    print('📦 Opening all cache boxes...');

    for (final boxName in _boxNames) {
      try {
        await Hive.openBox(boxName);
        print('✅ Opened $boxName');
      } catch (e) {
        print('❌ Error opening $boxName: $e');
        // Try to recreate the box
        try {
          await Hive.deleteBoxFromDisk(boxName);
          await Hive.openBox(boxName);
          print('✅ Recreated and opened $boxName');
        } catch (e2) {
          print('❌ Failed to recreate $boxName: $e2');
        }
      }
    }

    print('✅ All boxes opened');
  }

  /// Safe cache operation wrapper
  static T? safeGet<T>(Box box, String key, T? defaultValue) {
    try {
      return box.get(key) ?? defaultValue;
    } catch (e) {
      print('❌ Error reading from cache: $e');
      return defaultValue;
    }
  }

  /// Safe cache put operation
  static Future<void> safePut(Box box, String key, dynamic value) async {
    try {
      await box.put(key, value);
    } catch (e) {
      print('❌ Error writing to cache: $e');
    }
  }

  /// Safe cache delete operation
  static Future<void> safeDelete(Box box, String key) async {
    try {
      await box.delete(key);
    } catch (e) {
      print('❌ Error deleting from cache: $e');
    }
  }

  /// Check and repair cache if needed
  static Future<void> checkAndRepairCache() async {
    print('🔧 Checking cache integrity...');

    for (final boxName in _boxNames) {
      try {
        final box = Hive.box(boxName);
        // Try to read a test value to check if box is accessible
        box.get('test_key');
        print('✅ $boxName is healthy');
      } catch (e) {
        print('❌ $boxName is corrupted: $e');
        // Try to repair by recreating the box
        try {
          await Hive.deleteBoxFromDisk(boxName);
          await Hive.openBox(boxName);
          print('✅ $boxName repaired successfully');
        } catch (e2) {
          print('❌ Failed to repair $boxName: $e2');
        }
      }
    }

    print('🔧 Cache integrity check completed');
  }

  /// Get cache statistics
  static Map<String, int> getCacheStats() {
    final stats = <String, int>{};

    for (final boxName in _boxNames) {
      try {
        final box = Hive.box(boxName);
        stats[boxName] = box.length;
      } catch (e) {
        stats[boxName] = -1; // Error
      }
    }

    return stats;
  }
}
