// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:audiobook_record/ui/views/audio/audio_view.dart' as _i4;
import 'package:audiobook_record/ui/views/audio_tool/audio_tool_view.dart'
    as _i6;
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_view.dart'
    as _i5;
import 'package:audiobook_record/ui/views/home/home_view.dart' as _i3;
import 'package:audiobook_record/ui/views/startup/startup_view.dart' as _i2;
import 'package:flutter/material.dart' as _i7;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i8;

class Routes {
  static const startupView = '/startup-view';

  static const homeView = '/home-view';

  static const audioView = '/audio-view';

  static const chapterListView = '/chapter-list-view';

  static const audioToolView = '/audio-tool-view';

  static const all = <String>{
    startupView,
    homeView,
    audioView,
    chapterListView,
    audioToolView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i3.HomeView,
    ),
    _i1.RouteDef(
      Routes.audioView,
      page: _i4.AudioView,
    ),
    _i1.RouteDef(
      Routes.chapterListView,
      page: _i5.ChapterListView,
    ),
    _i1.RouteDef(
      Routes.audioToolView,
      page: _i6.AudioToolView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i7.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartupView(),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      return _i7.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.HomeView(),
        settings: data,
      );
    },
    _i4.AudioView: (data) {
      final args = data.getArgs<AudioViewArguments>(nullOk: false);
      return _i7.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.AudioView(
            key: args.key, title: args.title, bookTitle: args.bookTitle),
        settings: data,
      );
    },
    _i5.ChapterListView: (data) {
      final args = data.getArgs<ChapterListViewArguments>(
        orElse: () => const ChapterListViewArguments(),
      );
      return _i7.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i5.ChapterListView(key: args.key, booktitle: args.booktitle),
        settings: data,
      );
    },
    _i6.AudioToolView: (data) {
      final args = data.getArgs<AudioToolViewArguments>(nullOk: false);
      return _i7.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.AudioToolView(
            key: args.key,
            bookTitle: args.bookTitle,
            audioPath: args.audioPath),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class AudioViewArguments {
  const AudioViewArguments({
    this.key,
    required this.title,
    this.bookTitle,
  });

  final _i7.Key? key;

  final String title;

  final String? bookTitle;

  @override
  String toString() {
    return '{"key": "$key", "title": "$title", "bookTitle": "$bookTitle"}';
  }

  @override
  bool operator ==(covariant AudioViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.title == title &&
        other.bookTitle == bookTitle;
  }

  @override
  int get hashCode {
    return key.hashCode ^ title.hashCode ^ bookTitle.hashCode;
  }
}

class ChapterListViewArguments {
  const ChapterListViewArguments({
    this.key,
    this.booktitle,
  });

  final _i7.Key? key;

  final String? booktitle;

  @override
  String toString() {
    return '{"key": "$key", "booktitle": "$booktitle"}';
  }

  @override
  bool operator ==(covariant ChapterListViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.booktitle == booktitle;
  }

  @override
  int get hashCode {
    return key.hashCode ^ booktitle.hashCode;
  }
}

class AudioToolViewArguments {
  const AudioToolViewArguments({
    this.key,
    required this.bookTitle,
    required this.audioPath,
  });

  final _i7.Key? key;

  final String bookTitle;

  final dynamic audioPath;

  @override
  String toString() {
    return '{"key": "$key", "bookTitle": "$bookTitle", "audioPath": "$audioPath"}';
  }

  @override
  bool operator ==(covariant AudioToolViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.bookTitle == bookTitle &&
        other.audioPath == audioPath;
  }

  @override
  int get hashCode {
    return key.hashCode ^ bookTitle.hashCode ^ audioPath.hashCode;
  }
}

extension NavigatorStateExtension on _i8.NavigationService {
  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAudioView({
    _i7.Key? key,
    required String title,
    String? bookTitle,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.audioView,
        arguments:
            AudioViewArguments(key: key, title: title, bookTitle: bookTitle),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToChapterListView({
    _i7.Key? key,
    String? booktitle,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.chapterListView,
        arguments: ChapterListViewArguments(key: key, booktitle: booktitle),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAudioToolView({
    _i7.Key? key,
    required String bookTitle,
    required dynamic audioPath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.audioToolView,
        arguments: AudioToolViewArguments(
            key: key, bookTitle: bookTitle, audioPath: audioPath),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAudioView({
    _i7.Key? key,
    required String title,
    String? bookTitle,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.audioView,
        arguments:
            AudioViewArguments(key: key, title: title, bookTitle: bookTitle),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithChapterListView({
    _i7.Key? key,
    String? booktitle,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.chapterListView,
        arguments: ChapterListViewArguments(key: key, booktitle: booktitle),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAudioToolView({
    _i7.Key? key,
    required String bookTitle,
    required dynamic audioPath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.audioToolView,
        arguments: AudioToolViewArguments(
            key: key, bookTitle: bookTitle, audioPath: audioPath),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
