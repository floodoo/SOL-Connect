import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/api/models/news.dart';
import 'package:sol_connect/core/service/services.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({Key? key}) : super(key: key);
  static final routeName = (NewsScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsMessages = ModalRoute.of(context)!.settings.arguments as List<NewsMessage>;
    final theme = ref.watch(themeService).theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Benachrichtigungen",
          style: TextStyle(color: theme.colors.text),
        ),
        iconTheme: IconThemeData(color: theme.colors.icon),
        backgroundColor: theme.colors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: newsMessages.isEmpty
            ? const Center(child: Text("Es sind keine Benachrichtigungen vorhanden."))
            : ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                newsMessages[index].getTitle(),
                                style: const TextStyle(fontSize: 20),
                              ),
                              Html(data: newsMessages[index].getHTMLFormattedText()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: newsMessages.length,
              ),
      ),
    );
  }
}
