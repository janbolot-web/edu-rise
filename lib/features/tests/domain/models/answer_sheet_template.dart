import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerSheetTemplate {
  final String id;
  final String barcodeData;
  final int numQuestions;
  final int numOptions;
  final DateTime createdAt;
  final String createdBy;

  AnswerSheetTemplate({
    required this.id,
    required this.barcodeData,
    required this.numQuestions,
    required this.numOptions,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'barcodeData': barcodeData,
        'numQuestions': numQuestions,
        'numOptions': numOptions,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };

  factory AnswerSheetTemplate.fromJson(Map<String, dynamic> json) {
    return AnswerSheetTemplate(
      id: json['id'] as String,
      barcodeData: json['barcodeData'] as String,
      numQuestions: json['numQuestions'] as int,
      numOptions: json['numOptions'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String,
    );
  }
}
