import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/delegates/news_delegate.dart';

class NewsSubCategories extends StatefulWidget {
  List<Category> _subCategories = [];
  NewsDeleagte? _newsDeleagte;
  String _selectedSubcategoryId = "";
  bool isNews;

  NewsSubCategories(
      this._subCategories, this._newsDeleagte, this._selectedSubcategoryId,
      {this.isNews = false});

  @override
  State<StatefulWidget> createState() {
    return NewsSubCategoriesState(
        this._subCategories, this._newsDeleagte, this._selectedSubcategoryId);
  }
}

class NewsSubCategoriesState extends State<NewsSubCategories> {
  List<Category> _subCategories = [];
  NewsDeleagte? _newsDeleagte;
  String _selectedSubcategoryId = "";

  NewsSubCategoriesState(
      this._subCategories, this._newsDeleagte, this._selectedSubcategoryId);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
//    return Center(
//      child: Container(
//        child: Column(
//          children: <Widget>[
//            SizedBox(
//              height: 40,
//            ),
//            Flexible(
////              child: Padding(
////              padding: EdgeInsets.only(top: 0, bottom: 10),
//              child: ListView.builder(
//                itemBuilder: (BuildContext context, int index) {
//                  return _buildSubCategoryItem(index);
//                },
//                itemCount: _subCategories.length,
////              ),
//            ),)
//          ],
//        ),
//        decoration: BoxDecoration(
//          borderRadius: BorderRadius.circular(10),
//          boxShadow: [
//            BoxShadow(
//              color: Colors.grey.withOpacity(.2),
//              blurRadius: 8.0, // has the effect of softening the shadow
//              spreadRadius: 5.0, // has the effect of extending the shadow
//              offset: Offset(
//                0.0, // horizontal, move right 10
//                0.0, // vertical, move down 10
//              ),
//            ),
//          ],
//          color: Colors.white,
//        ),
//        height: height - 210,
//      ),
//    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.70),
        body: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        child: Image.asset('assets/close_ic.png'),
                        alignment: Alignment.centerLeft,
                      ),
                      height: 25,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 10),
                      child: Scrollbar(
                        controller: _scrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildSubCategoryItem(index);
                          },
                          itemCount: _subCategories.length,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.2),
                    blurRadius: 8.0, // has the effect of softening the shadow
                    spreadRadius: 5.0, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      0.0, // vertical, move down 10
                    ),
                  ),
                ],
                color: Colors.white,
              ),
              height: height - 210,
              width: width - 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Container(
        width: width - 100,
        color: Colors.white,
        padding: EdgeInsets.only(top: 0, right: 15, left: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            index != 0
                ? SizedBox(
                    height: 15,
                  )
                : SizedBox(),
            Row(
              children: <Widget>[
                Flexible(
                  child: Align(
                    child: Text(
                      _subCategories[index].name ?? "",
                      style: TextStyle(fontSize: 16),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                Visibility(
                  child: Align(
//                    child: Image.asset(
//                      'assets/noti_tab_act.png',
//                      width: 25,
//                      height: 25,
//                      fit: BoxFit.fitHeight,
//                    ),
                    child: Icon(
                      Icons.check,
                      color: Color(0xff43a047),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  visible: _selectedSubcategoryId == _subCategories[index].id
                      ? true
                      : false,
                ),
                SizedBox(
                  width: 5,
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              height: 1,
            )
          ],
        ),
      ),
      onTap: () {
        if (_newsDeleagte != null) {
          Navigator.pop(context);
          _newsDeleagte?.selectedSubCategory(_subCategories[index]);
        }
        setState(() {
          _selectedSubcategoryId = _subCategories[index].id??"";
        });
      },
    );
  }
}
