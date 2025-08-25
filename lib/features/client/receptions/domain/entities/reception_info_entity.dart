class ReceptionInfoEntity {
  final String? diagnosis;
  final String? treatmentPlan;
  final List<AttachedFile>? attachedFiles;

  ReceptionInfoEntity({
    this.diagnosis,
    this.treatmentPlan,
    this.attachedFiles,
  });
}

class AttachedFile {
  final String name;
  final String base64;

  AttachedFile({
    required this.name,
    required this.base64,
  });

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      name: json['name'] ?? '',
      base64: json['base64'] ?? '',
    );
  }
}
