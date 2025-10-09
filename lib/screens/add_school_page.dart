
import 'package:flutter/material.dart';
import '../widgets/add_school_form.dart';

class AddSchoolPage extends StatelessWidget {
  const AddSchoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ลงทะเบียนโรงเรียน'),
      ),
      body: Row(
        children: [
          // Expanded(
          //   child: Image.network(
          //     'https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          const Expanded(
            child: AddSchoolForm(),
          ),
        ],
      ),
    );
  }
}


