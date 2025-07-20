class FaqModel {
  final int id;
  final String question;
  final String answer;
  final String category;
  final int order;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      category: json['category'],
      order: json['order'],
    );
  }
}
