import 'dart:convert';

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllFaqs extends StatefulWidget {
  const AllFaqs({super.key});

  @override
  State<AllFaqs> createState() => _AllFaqsState();
}

class _AllFaqsState extends State<AllFaqs> {
  @override
  void initState() {
    super.initState();
    //_getAllFaqs();
    getAllFaqs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("FAQs"),
      ),
      body:
          _isLoading
              ? loader("Loading FAQs...")
              : ListView(padding: EdgeInsets.all(20), children: faqWidgets()),
    );
  }

  List<Widget> faqWidgets() {
    List<Widget> faqWidgetList = [];
    for (int i = 0; i < allFaqFromServer.length; i++) {
      faqWidgetList.add(
        Container(
          padding: EdgeInsets.all(10),
          decoration: borderRadius(white, 8),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ExpandablePanel(
            header: Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Text(
                allFaqFromServer[i]['question'],
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            collapsed: Text(
              "Answer: " + allFaqFromServer[i]['answer'].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textMedium()),
            ),
            expanded: Text(
              "Answer: " + allFaqFromServer[i]['answer'],
              style: TextStyle(color: textMedium()),
            ),
          ),
        ),
      );
    }
    return faqWidgetList;
  }

  bool _isLoading = false;
  List<dynamic> allFaqFromServer = [];
  void _getAllFaqs() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.getWithToken(allFaqs, {});
      print(data);
      setState(() {
        allFaqFromServer = data as List;
        _isLoading = false;
      });
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

  getAllFaqs() async {
    String? token = (await StorageService.getLoginData())?.accessToken;
    print('$baseUrl$allFaqs');
    print(token);
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
      Uri.parse('$baseUrl$allFaqs'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print(response.body);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      allFaqFromServer = json.decode(response.body);
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }
}
