import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imgx/src/config/img_x_config.dart';
import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/image_widget/img_x_source.dart';
import 'package:imgx/src/utils/img_x_logger.dart';

/// Created by lovepreetsingh on 14,November,2024

class ImgXLoader extends StatefulWidget {
  /// Image uri
  final String imageUri;

  /// BoxFit
  final BoxFit fit;

  /// Widget to show while loading the image
  final Widget? progressWidget;

  /// Widget to show if there is an error loading the image
  final Widget? errorWidget;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// Type of cache
  final CacheType? cacheType;

  /// Duration for which the image should be cached
  final Duration? cacheDuration;

  /// Headers for the api like authorization token
  final Map<String, String> headers;

  /// Number of times to retry loading the image
  final int? retryCount;

  /// Callback to get the download progress
  final Function(double progress)? onProgress;

  /// Constructor
  const ImgXLoader({
    required this.imageUri,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.progressWidget,
    this.errorWidget,
    this.cacheType,
    this.headers = const {},
    this.retryCount,
    this.cacheDuration,
    this.onProgress,
    super.key,
  });

  @override
  State<ImgXLoader> createState() => _ImgXLoaderState();
}

class _ImgXLoaderState extends State<ImgXLoader> with ImgXSource {
  late Widget? progressWidget;
  late Widget? errorWidget;
  late CacheType cacheType;
  late Duration cacheDuration;
  late int retryCount;
  late bool logErrors;

  /// Kept in the state so a rebuild does not start another download.
  late Future<Uint8List?> imageFuture;

  @override
  void initState() {
    cacheType = widget.cacheType ?? ImgXConfig.globalCacheType;
    cacheDuration = widget.cacheDuration ?? ImgXConfig.globalCacheDuration;
    progressWidget = widget.progressWidget ?? ImgXConfig.globalProgressWidget;
    errorWidget = widget.errorWidget ?? ImgXConfig.globalErrorWidget;
    retryCount = widget.retryCount ?? ImgXConfig.globalRetryCount;
    logErrors = ImgXConfig.globalLogErrors;
    imageFuture = loadImage();
    super.initState();
  }

  @override
  void didUpdateWidget(ImgXLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUri != widget.imageUri ||
        oldWidget.headers != widget.headers ||
        oldWidget.cacheType != widget.cacheType ||
        oldWidget.cacheDuration != widget.cacheDuration ||
        oldWidget.retryCount != widget.retryCount) {
      cacheType = widget.cacheType ?? ImgXConfig.globalCacheType;
      cacheDuration = widget.cacheDuration ?? ImgXConfig.globalCacheDuration;
      progressWidget = widget.progressWidget ?? ImgXConfig.globalProgressWidget;
      errorWidget = widget.errorWidget ?? ImgXConfig.globalErrorWidget;
      retryCount = widget.retryCount ?? ImgXConfig.globalRetryCount;
      data = null;
      imageFuture = loadImage();
    }
  }

  /// Loads the image with the current configuration.
  Future<Uint8List?> loadImage() => getImage(
    widget.imageUri,
    widget.headers,
    cacheType,
    cacheDuration,
    retryCount,
    logErrors,
    onProgress: widget.onProgress,
  );

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return _imageWidget();
    }
    return FutureBuilder<Uint8List?>(
      future: imageFuture,
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          data = snapshot.data;
        }
        return AnimatedCrossFade(
          firstChild: SizedBox(
            width: widget.width,
            height: widget.height,
            child:
                progressWidget ??
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
          ),
          secondChild: Builder(
            builder: (ctx) {
              if (snapshot.hasData && data != null) {
                return _imageWidget();
              }
              // Browsers block cross origin images without CORS headers, so
              // fall back to an HTML image element for those servers. That
              // path cannot cache or report progress.
              if (kIsWeb) {
                return _imageWebWidget();
              }
              return errorWidget ?? _errorWidget();
            },
          ),
          crossFadeState: snapshot.connectionState == ConnectionState.waiting
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 400),
          firstCurve: Curves.ease,
          secondCurve: Curves.ease,
        );
      },
    );
  }

  Widget _imageWebWidget() => SizedBox(
    width: widget.width,
    height: widget.height,
    child: Image.network(
      widget.imageUri,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      headers: widget.headers.isEmpty ? null : widget.headers,
      // Lets Flutter draw the image with an <img> element when the byte
      // download is blocked, which happens without CORS headers. HTML
      // elements cannot carry headers, so this only helps header-less loads.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (context, error, stackTrace) {
        if (logErrors) {
          ImgXLogger.error(
            error.toString(),
            error: error,
            stackTrace: stackTrace,
          );
        }
        return errorWidget ?? _errorWidget();
      },
    ),
  );

  Widget _imageWidget() => SizedBox(
    width: widget.width,
    height: widget.height,
    child: Image.memory(
      data!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) {
        if (logErrors) {
          ImgXLogger.error(
            error.toString(),
            error: error,
            stackTrace: stackTrace,
          );
        }
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: errorWidget ?? _errorWidget(),
        );
      },
    ),
  );

  Widget _errorWidget() =>
      Icon(Icons.error_outline, size: 36, color: Colors.red);
}
