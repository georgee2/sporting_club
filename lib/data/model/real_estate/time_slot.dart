class TimeSlot {
  String? id;
  final String? start;
  final String? end;
  final String? total;
  final bool? disabled;
  final int? count;
  bool? selected;

  TimeSlot({
    this.id,
    this.start,
    this.end,
    this.total,
    this.count,
    this.disabled = false,
    this.selected = false,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] == null ? null : json['start'],
      end: json['end'] == null ? null : json['end'],
      total: json['total'] == null ? null : json['total'],
      count: json['count'] == null ? 0 : json['count'],
      disabled: json['disable'] == null ? false : json['disable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "start": this.start,
      "end": this.end,
      "total": this.total,
      "count": this.count,
      "disable": this.disabled,
    };
  }
}