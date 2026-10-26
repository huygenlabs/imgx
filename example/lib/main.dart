import 'package:example/home_page.dart';
import 'package:flutter/material.dart';
import 'package:imgx/imgx.dart';

void main() {
  ImgXConfig.globalCacheType = CacheType.memory;
  ImgXConfig.globalCacheDuration = const Duration(days: 1);
  ImgXConfig.globalProgressWidget = const Center(
    child: CircularProgressIndicator(),
  );
  ImgXConfig.globalErrorWidget = const Center(child: Icon(Icons.error));
  ImgXConfig.globalRetryCount = 3;

  ImgX.removeCacheWhere(key: "key");
  ImgX.removeAllCache();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImgX Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
