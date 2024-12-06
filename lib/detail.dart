import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MealDetailPage extends StatelessWidget {
  final String mealId;

  MealDetailPage({required this.mealId});

  Future<Map<String, dynamic>> fetchMealDetails(String id) async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'][0];
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Details'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchMealDetails(mealId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final meal = snapshot.data as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    meal['strMealThumb'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['strMeal'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Category: ${meal['strCategory']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Area: ${meal['strArea']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Instructions:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          meal['strInstructions'],
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ingredients:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ...List.generate(20, (index) {
                          final ingredient = meal['strIngredient${index + 1}'];
                          final measure = meal['strMeasure${index + 1}'];
                          if (ingredient != null && ingredient.isNotEmpty) {
                            return Text('- $ingredient ($measure)');
                          }
                          return SizedBox.shrink();
                        }),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final tutorialUrl = meal['strYoutube'] ?? '';
                              if (tutorialUrl.isNotEmpty) {
                                _launchURL(tutorialUrl);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('No tutorial available')),
                                );
                              }
                            },
                            child: Text(
                              'Tutorial',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
