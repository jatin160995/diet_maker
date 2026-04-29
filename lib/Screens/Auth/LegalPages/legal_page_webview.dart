import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String link;

  const WebViewScreen({Key? key, required this.title, required this.link})
    : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = true;
  dynamic responseFromServer;
  String content = "";

  void _getDataRequest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.getWithToken(widget.link, {});
      setState(() {
        _isLoading = false;
        responseFromServer = data;
        content = responseFromServer['data']['body'];
      });
      print(data);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: heading(widget.title),
        backgroundColor: backgroundColor(),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? loader("Loading")
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Html(
                  data: content,
                  style: {
                    "p": Style(fontSize: FontSize(16)),
                    "h2": Style(
                      fontSize: FontSize(22),
                      fontWeight: FontWeight.bold,
                    ),
                  },
                ),
              ),
    );
  }
}
