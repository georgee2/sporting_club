import 'category.dart';

class AdministrativesData {

  final List<Category>? administratives;

  AdministrativesData({this.administratives});

  factory AdministrativesData.fromJson(Map<String, dynamic> json) {
    List<Category> administrativesList = [];
    if(json['administrative'] != null){
      var list = json['administrative']  as List;
      if (list != null){
        administrativesList = list.map((i) => Category.fromJson(i)).toList();
      }
    }

    return AdministrativesData(
      administratives: json['administrative'] == null? null: administrativesList,
    );
  }
}