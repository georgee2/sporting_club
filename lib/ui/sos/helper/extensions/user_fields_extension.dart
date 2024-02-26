enum EmergencyCategoryFieldType {
  skinny,
  neurologists,
  heartDisease,
bones,
}

extension EmergencyCategoryExtension on EmergencyCategoryFieldType {
  String get categoryIcon {
    switch (this) {
      case EmergencyCategoryFieldType.skinny:
        return 'assets/skin_category_ic.png';
      case EmergencyCategoryFieldType.neurologists:
        return 'assets/brain_category_ic.png';
        case EmergencyCategoryFieldType.heartDisease:
      return 'assets/heart_category_ic.png';
      case EmergencyCategoryFieldType.bones:
      return 'assets/bones_category_ic.png';

      default:
        return '';
    }
  }

  static EmergencyCategoryFieldType getCategoryType(String field) {
    switch (field) {
      case 'skinny':
        return EmergencyCategoryFieldType.skinny;
      case 'neurologists':
        return EmergencyCategoryFieldType.neurologists;
      case 'heart-disease':
        return EmergencyCategoryFieldType.heartDisease;
      case 'bones':
        return EmergencyCategoryFieldType.bones;

      default:
        return EmergencyCategoryFieldType.skinny;
    }
  }
}
