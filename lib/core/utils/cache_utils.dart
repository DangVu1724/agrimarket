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

  // Cache expiration times (in milliseconds)
  static const Map<String, int> _cacheExpiration = {
    'storeCache': 30 * 60 * 1000, // 30 phút
    'userCache': 60 * 60 * 1000, // 1 giờ
    'productCache': 15 * 60 * 1000, // 15 phút
    'menuCache': 60 * 60 * 1000, // 1 giờ
    'promotionCache': 10 * 60 * 1000, // 10 phút
    'discountCodeCache': 5 * 60 * 1000, // 5 phút
    'payment_method': 24 * 60 * 60 * 1000, // 24 giờ
    'searchCache': 30 * 60 * 1000, // 30 phút
  };

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

  /// Safe cache operation wrapper with expiration check
  static T? safeGet<T>(Box box, String key, T? defaultValue) {
    try {
      final value = box.get(key);
      if (value == null) return defaultValue;

      // Check if data has timestamp for expiration
      final timestamp = box.get('${key}_timestamp');
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final expirationTime = _cacheExpiration[box.name] ?? 30 * 60 * 1000;

        if (now - timestamp > expirationTime) {
          // Data expired, remove it
          box.delete(key);
          box.delete('${key}_timestamp');
          return defaultValue;
        }
      }

      return value as T;
    } catch (e) {
      print('❌ Error reading from cache: $e');
      return defaultValue;
    }
  }

  /// Safe cache put operation with timestamp
  static Future<void> safePut(Box box, String key, dynamic value) async {
    try {
      await box.put(key, value);
      await box.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error writing to cache: $e');
    }
  }

  /// Safe cache delete operation
  static Future<void> safeDelete(Box box, String key) async {
    try {
      await box.delete(key);
      await box.delete('${key}_timestamp');
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

  /// Get cache statistics with expiration info
  static Map<String, dynamic> getCacheStats() {
    final stats = <String, dynamic>{};

    for (final boxName in _boxNames) {
      try {
        final box = Hive.box(boxName);
        final totalKeys = box.length;
        final expiredKeys = _getExpiredKeysCount(box);

        stats[boxName] = {
          'total_keys': totalKeys,
          'expired_keys': expiredKeys,
          'valid_keys': totalKeys - expiredKeys,
          'expiration_time': _cacheExpiration[boxName] ?? 30 * 60 * 1000,
        };
      } catch (e) {
        stats[boxName] = {'error': e.toString(), 'total_keys': 0, 'expired_keys': 0, 'valid_keys': 0};
      }
    }

    return stats;
  }

  /// Clean expired cache entries
  static Future<void> cleanExpiredCache() async {
    print('🧹 Cleaning expired cache entries...');

    for (final boxName in _boxNames) {
      try {
        final box = Hive.box(boxName);
        final keysToDelete = <String>[];

        for (final key in box.keys) {
          if (key.toString().endsWith('_timestamp')) continue;

          final timestamp = box.get('${key}_timestamp');
          if (timestamp != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final expirationTime = _cacheExpiration[boxName] ?? 30 * 60 * 1000;

            if (now - timestamp > expirationTime) {
              keysToDelete.add(key.toString());
              keysToDelete.add('${key}_timestamp');
            }
          }
        }

        for (final key in keysToDelete) {
          await box.delete(key);
        }

        if (keysToDelete.isNotEmpty) {
          print('✅ Cleaned ${keysToDelete.length ~/ 2} expired entries from $boxName');
        }
      } catch (e) {
        print('❌ Error cleaning expired cache for $boxName: $e');
      }
    }

    print('✅ Cache cleanup completed');
  }

  /// Get count of expired keys in a box
  static int _getExpiredKeysCount(Box box) {
    int expiredCount = 0;
    final expirationTime = _cacheExpiration[box.name] ?? 30 * 60 * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final key in box.keys) {
      if (key.toString().endsWith('_timestamp')) continue;

      final timestamp = box.get('${key}_timestamp');
      if (timestamp != null && now - timestamp > expirationTime) {
        expiredCount++;
      }
    }

    return expiredCount;
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    int totalSize = 0;

    for (final boxName in _boxNames) {
      try {
        final box = Hive.box(boxName);
        // This is an approximation since Hive doesn't provide direct size info
        totalSize += box.length * 1024; // Assume average 1KB per entry
      } catch (e) {
        print('❌ Error getting size for $boxName: $e');
      }
    }

    return totalSize;
  }

  /// Check if cache is healthy
  static Future<bool> isCacheHealthy() async {
    try {
      for (final boxName in _boxNames) {
        final box = Hive.box(boxName);
        // Try to perform a simple operation
        box.get('health_check');
      }
      return true;
    } catch (e) {
      print('❌ Cache health check failed: $e');
      return false;
    }
  }
}
