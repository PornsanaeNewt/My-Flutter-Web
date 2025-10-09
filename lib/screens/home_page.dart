import 'package:flutter/material.dart';
import 'package:project_web/services/custom_app_bar.dart';
import 'package:project_web/widgets/home_page_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(activeMenu: 'Home'),
      body: HomePageForm(),
    );
  }
}
