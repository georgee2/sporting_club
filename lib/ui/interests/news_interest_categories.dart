import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/interest.dart';
import 'package:sporting_club/delegates/interest_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';

class NewsInterestCategories extends StatefulWidget {
  List<Interest> _interests = [];
  InterestDeleagte _newsDeleagte;
  List<String> _selectedSubcategoryId = [];

  NewsInterestCategories(
      this._interests, this._newsDeleagte, this._selectedSubcategoryId);

  @override
  State<StatefulWidget> createState() {
    if (_interests.length > 0) {
      _interests.insert(0, Interest(title: "اختيار الكل", id: "0"));
      // _interests.add(Interest(title: "الكل", id: "0"));
    }
    return NewsInterestCategoriesState(
        this._interests, this._newsDeleagte, this._selectedSubcategoryId);
  }
}

class NewsInterestCategoriesState extends State<NewsInterestCategories> {
  List<Interest> _interests = [];
  InterestDeleagte _newsDeleagte;
  List<String> _selectedSubcategoryId = [];
  List<Interest> selected_interst = [];

  NewsInterestCategoriesState(
      this._interests, this._newsDeleagte, this._selectedSubcategoryId);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
//
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
                          itemCount: _interests.length,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 20),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Image.asset('assets/done.png'),
                      ),
                    ),
                    onTap: () {
                      if (_newsDeleagte != null) {
                        Navigator.pop(context);
                        _newsDeleagte.selectedNewsInterests(
                            selected_interst, _selectedSubcategoryId);
                      }
                    },
                  ),
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
                      _interests[index].title ??"",
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
                  visible:
                      (_selectedSubcategoryId.contains(_interests[index].id) &&
                              index != 0)
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
          //  Navigator.pop(context);
          //_newsDeleagte.selectedNewsInterests(_selectedSubcategoryId);
        }
        setState(() {
          int isAllSelected = 0;
          for (var i = 1; i < _interests.length; i++) {
              if(_selectedSubcategoryId.contains(_interests[i].id)){
                isAllSelected ++;
            }
          }
          if (_interests[index].id == "0" &&
              (_interests.length - 1) == isAllSelected) {
            for (var i = 1; i < _interests.length; i++) {
              _interests[i].selected = false;
              _selectedSubcategoryId.remove(_interests[i].id);
              selected_interst.remove(_interests[i]);
            }
          } else if (_interests[index].id == "0" &&
              ( _interests.length-1) != isAllSelected) {
            selected_interst.clear();
            for (var i = 1; i < _interests.length; i++) {
              _interests[i].selected = true;
              if(!_selectedSubcategoryId.contains(_interests[i].id)){
                _selectedSubcategoryId.add(_interests[i].id??"");
              }
              selected_interst.add(_interests[i]);
            }
          } else if (_selectedSubcategoryId.contains(_interests[index].id)) {
            _selectedSubcategoryId.remove(_interests[index].id);
            _interests[index].selected = false;
            selected_interst.remove(_interests[index]);
          } else {
            _interests[index].selected = true;

            _selectedSubcategoryId.add(_interests[index].id??"");
            selected_interst.add(_interests[index]);
          }
        });
      },
    );
  }
}
