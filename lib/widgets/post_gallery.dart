import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/data/model/gallery_data.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';

class PostGallery extends StatelessWidget  {
  final List<GalleryData> _postGalleryData;

  PostGallery( this._postGalleryData);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> widgets = [];
    for(GalleryData galleryItem in _postGalleryData){
      widgets.add(
        Align(
          child: Text(
            '${galleryItem.title}',
            style: TextStyle(color: Color(0xff43a047), fontSize: 18),
          ),
          alignment: AlignmentDirectional.centerStart,
        ),
      );
      widgets.add(
          CarouselSlider(
            options: CarouselOptions(
              height: 400,
              aspectRatio: 16/9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: galleryItem.gallery?.map((imageGalley) {
              return Builder(
                builder: (BuildContext context) {
                  return InkWell(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => FullImage( imageGalley)));
                      Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) => FullImage(
                            imageGalley            ),
                      ));

                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        //decoration: BoxDecoration(color: Colors.amber),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image: imageGalley,
                          height: 200,
                          // width: width - 30,
                          fit: BoxFit.contain,
                        )),
                  );
                },
              );
            }).toList(),
          )
      );
    }
    return Column(
      children: widgets,
    );
  }
}