import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sol_connect/core/api/models/news.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key}) : super(key: key);
  static final routeName = (NewsScreen).toString();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<NewsMessage>;
    return Scaffold(
      appBar: AppBar(title: const Text("Benachrichtigungen")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            args[index].getTitle(),
                            style: const TextStyle(fontSize: 20),
                          ),
                          Html(data: args[index].getHTMLFormattedText()),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: args.length),
      ),
    );
  }
}
