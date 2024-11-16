// Created by lovepreetsingh on 14,November,2024

/// Image cache type enum to save in memory or disk
enum CacheType {
  /// Save in memory, will remain saved while app is opened or cacheDuration is not expired
  memory,

  /// Save in disk, will remain saved even after app is closed
  disk,

  /// Do not save, will not save in memory or disk
  none
}
