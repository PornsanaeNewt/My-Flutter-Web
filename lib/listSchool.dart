import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thai Cooking Course',
      home: const SchoolListPage(),
    );
  }
}

class School {
  final String name;
  final String email;
  final String address;

  School({required this.name, required this.email, required this.address});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      name: json['schoolName'],
      email: json['schoolEmail'],
      address: json['schoolAddress'],
    );
  }
}

class SchoolListPage extends StatefulWidget {
  const SchoolListPage({super.key});

  @override
  State<SchoolListPage> createState() => _SchoolListPageState();
}

class _SchoolListPageState extends State<SchoolListPage> {
  List<School> schools = [];
  int currentPage = 1;
  final int itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    final response = await http.get(Uri.parse('http://localhost:3000/listAllSchool'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        schools = data.map((item) => School.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load schools');
    }
  }

  void goToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, schools.length);
    final pagedSchools = schools.sublist(start, end);
    final totalPages = (schools.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai Cooking Course'),
        actions: [
          TextButton(onPressed: () {}, child: const Text("Request")),
          TextButton(onPressed: () {}, child: const Text("Schools")),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(onPressed: () {}, child: const Text("Admin")),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: pagedSchools.map((school) => SchoolCard(school)).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: currentPage > 1 ? () => goToPage(currentPage - 1) : null,
                    icon: const Icon(Icons.arrow_back)),
                for (int i = 1; i <= totalPages; i++)
                  TextButton(
                    onPressed: () => goToPage(i),
                    child: Text('$i',
                        style: TextStyle(
                            fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal)),
                  ),
                IconButton(
                    onPressed: currentPage < totalPages ? () => goToPage(currentPage + 1) : null,
                    icon: const Icon(Icons.arrow_forward)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SchoolCard extends StatelessWidget {
  final School school;

  const SchoolCard(this.school, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                'https://picture1.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(school.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("รายละเอียดโรงเรียน"),
                Text(school.email),
                Text("ที่อยู่: ${school.address}"),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(onPressed: () {}, child: const Text("ปิด")))
              ],
            ),
          )
        ],
      ),
    );
  }
}
