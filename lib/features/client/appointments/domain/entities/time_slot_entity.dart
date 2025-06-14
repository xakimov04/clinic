class TimeSlotEntity {
  final String time;
  final bool isAvailable;
  final bool isSelected;

  const TimeSlotEntity({
    required this.time,
    required this.isAvailable,
    this.isSelected = false,
  });

  TimeSlotEntity copyWith({
    String? time,
    bool? isAvailable,
    bool? isSelected,
  }) {
    return TimeSlotEntity(
      time: time ?? this.time,
      isAvailable: isAvailable ?? this.isAvailable,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
