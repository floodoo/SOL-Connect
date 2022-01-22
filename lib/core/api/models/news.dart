//Author Philipp Gersch

import 'package:untis_phasierung/core/exceptions.dart';

class NewsMessage {
  int _id = -1;
  String _subject = "";
  String _htmltext = "";

  NewsMessage(dynamic data) {
    if (data == null) return;

    if (data['id'] != null) {
      _id = data['id'];
    }

    if (data['subject'] != null) {
      _subject = data['subject'];
    }

    if (data['text'] != null) {
      _htmltext = data['text'];
    }
  }

  int getId() {
    return _id;
  }

  String getTitle() {
    return _subject;
  }

  String getHTMLFormattedText() {
    return _htmltext;
  }
}

class News {
  NewsMessage _systemMessage = NewsMessage(null);
  final _messagesOfDay = <NewsMessage>[];
  String _rssUrl = "";

  News(dynamic jsonData) {
    if (jsonData == null) return;

    if (jsonData['errorMessage'] != null) {
      throw FailedToFetchNewsException(jsonData['errorMessage']);
    }

    dynamic data = jsonData['data'];
    if (data['systemMessage'] != null) {
      if (data['systemMessage'] != "null") {
        _systemMessage = NewsMessage(data['systemMessage']);
      }
    }

    for (dynamic d in data['messagesOfDay']) {
      _messagesOfDay.add(NewsMessage(d));
    }

    _rssUrl = data['rssUrl'];
  }

  String getRssUrl() {
    return _rssUrl;
  }

  ///Komischerweise immer leer
  NewsMessage getSystemNews() {
    return _systemMessage;
  }

  List<NewsMessage> getNewsMessages() {
    return _messagesOfDay;
  }
}
