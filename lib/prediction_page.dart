// ignore_for_file: must_be_immutable

import 'package:canine_ai/prediction_score.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class PredictionPage extends StatefulWidget {
  final List _heap;
  final List<String> _labels;
  const PredictionPage(this._heap, this._labels, {super.key});

  @override
  _PredictionPageState createState() => _PredictionPageState(_heap, _labels);
}

class _PredictionPageState extends State<PredictionPage>
    with SingleTickerProviderStateMixin {
  final List _heap;
  final List<String> _labels;
  _PredictionPageState(this._heap, this._labels);
  late PageController _pageController;
  int totalPage = 1;

  // String _formatBreedForApi(String breed) {
  //   const Map<String, String> breedApiMap = {
  //     'Maltese_dog': 'maltese',
  //     'English_foxhound': 'hound/english',
  //     'American_Staffordshire_terrier': 'terrier/american',
  //     'Dandie_Dinmont': 'terrier/dandie',
  //     'Boston_bull': 'bulldog/boston',
  //     'standard_schnauzer': 'schnauzer',
  //     'West_Highland_white_terrier': 'terrier/westhighland',
  //     'Labrador_retriever': 'labrador',
  //     'German_short': 'pointer/german',
  //     'Welsh_springer_spaniel': 'springer/welsh',
  //     'Irish_water_spaniel': 'spaniel/irish',
  //     'Bouvier_des_Flandres': 'bouvier',
  //     'German_shepherd': 'germanshepherd',
  //     'Saint_Bernard': 'stbernard',
  //     'Eskimo_dog': 'eskimo',
  //     'Siberian_husky': 'husky',
  //     'Brabancon_griffon': 'brabancon',
  //     'Mexican_hairless': 'mexicanhairless',
  //     'African_hunting_dog': 'african',
  //     'black': 'coonhound',
  //     'wire': 'terrier/fox',
  //     'soft': 'terrier/wheaten',
  //     'flat': 'retriever/flatcoated',
  //     'curly': 'retriever/curly',
  //     'Shih': 'shihtzu',
  //   };

  //   if (breedApiMap.containsKey(breed)) {
  //     return breedApiMap[breed]!;
  //   }

  //   List<String> parts = breed.toLowerCase().split('_');
  //   if (parts.length > 1) {
  //     return '${parts.last}/${parts.first}';
  //   }
  //   return parts.first;
  // }

  // Future<Map<String, dynamic>> fetchBreedInfo(String breed) async {
  //   try {
  //     // Dog CEO API: https://dog.ceo/api/breed/{breed}/images/random
  //     final apiBreed = _formatBreedForApi(breed);
  //     final imageUrlResp = await http
  //         .get(Uri.parse('https://dog.ceo/api/breed/$apiBreed/images/random'));
  //     String imageUrl = '';
  //     if (imageUrlResp.statusCode == 200) {
  //       final data = jsonDecode(imageUrlResp.body);
  //       if (data['status'] == 'success') {
  //         imageUrl = data['message'];
  //       } else {
  //         print('Dog CEO API returned an error: ${data['message']}');
  //       }
  //     } else {
  //       print(
  //           'Failed to fetch dog image. Status code: ${imageUrlResp.statusCode}');
  //     }

  //     // Fun fact API (random dog fact)
  //     final factResp =
  //         await http.get(Uri.parse('https://dog-api.kinduff.com/api/facts'));
  //     String funFact = 'Could not fetch a fun fact at this time.';
  //     if (factResp.statusCode == 200) {
  //       final data = jsonDecode(factResp.body);
  //       funFact = data['facts'][0];
  //     } else {
  //       print('Failed to fetch fun fact. Status code: ${factResp.statusCode}');
  //     }

  //     return {
  //       'imageUrl': imageUrl,
  //       'funFact': funFact,
  //     };
  //   } catch (e) {
  //     print('An error occurred in fetchBreedInfo: $e');
  //     throw Exception(
  //         'Failed to fetch breed info. Please check your network connection.');
  //   }
  // }

  @override
  void initState() {
    _pageController = PageController(initialPage: 0)..addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For demo, use the top prediction
    final top = _heap[0];
    final breedName = getBreedName(top['index']);

    // Save prediction to history
    savePredictionToHistory(breedName, top['score']);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            stops: const [0.3, 0.9],
            colors: [
              Colors.black.withOpacity(.9),
              Colors.black.withOpacity(.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      breedName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ConfidenceScoreWidget(confidence: top['score']),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      final shareText =
                          '🐶 CanineAI Prediction\nBreed: $breedName\nConfidence: ${(top['score'] * 100).toStringAsFixed(2)}%';
                      Share.share(shareText);
                    },
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> savePredictionToHistory(
      String breed, double confidence, [String? imageUrl]) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final prediction = {
      'breed': breed,
      'confidence': confidence,
      'imageUrl': imageUrl ?? '',
      'date': now,
    };
    List<String> history = prefs.getStringList('prediction_history') ?? [];
    history.insert(0, jsonEncode(prediction)); // newest first
    await prefs.setStringList('prediction_history', history);
  }

  // Helper to map index to breed name (replace with your actual mapping)
  String getBreedName(int index) {
    if (index < _labels.length) {
      return _labels[index];
    }
    return _labels[0];
  }
}
