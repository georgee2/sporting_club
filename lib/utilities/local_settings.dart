import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporting_club/data/model/advertisements_list_data.dart';
import 'package:sporting_club/data/model/login_data.dart';
import 'dart:convert';
import 'package:sporting_club/data/model/user.dart';

class LocalSettings {
  static final LocalSettings _singleton = LocalSettings._internal();
  factory LocalSettings() {
    return _singleton;
  }
  LocalSettings._internal();

  //local settings names
  static const String _IS_INTRO_SHOWN = 'is_intro_shown';
  static const String _TOKEN = 'token';
  static const String _REFRESHTOKEN = 'refresh_token';
  static const String _USER = 'user';
  static const String _LOGIN_DATA= 'login_data';
  static const String _PLAYER_ID = "player_id";
  static const String _NOTIFICATIONS_COUNT = "notifications_count";
  static const String _IS_OPENED_BEFORE = "is_opened_before";
  static const String _ADVERTISEMENTS = "advertisements";
  static const String _INTERESTS = "interests";
  static const String _dataff = "_dataff";

  static  bool open_ads = true;
  static  bool open_notificatonlist = false;
  static  String data_not = "interests";
  static  bool open_fromterminated = true;

  //local settings values
  static bool? isIntroShownBefore = false;
  static String? token = "";
  static User? user;
  static LoginData? loginData1;
  static String? dataf ;
  static String? refreshToken = "";
  static String? playerId = "";
  static int? notificationsCount = 0;
  static Map<String, dynamic>? savedTags;
  static Map<String, dynamic>? newTags;
  static String? firebaseToken = "";
  static AdvertisementsListData? advertisements;
  static bool? adsNetworkError = false;
  static List<String>? interests = [];
  static String? link = "";
  static String? newsId = null;

  void setIsIntroShown(bool isIntroShown) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_IS_INTRO_SHOWN, isIntroShown).then((value) {
      isIntroShownBefore = value;
    });
  }

  Future<bool?> isIntroShown() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    isIntroShownBefore = preferences.getBool(_IS_INTRO_SHOWN);
    return preferences.getBool(_IS_INTRO_SHOWN);
  }

  void setToken(String userToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_TOKEN, "bearer " + userToken).then((value) {
      token = "bearer " + userToken;
    });
  }
  void setPlayerId(String? oneSignelPlayerId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_PLAYER_ID, oneSignelPlayerId??"").then((value) {
      playerId = oneSignelPlayerId;
      print(  "$playerId playerid");
    });
  }
  // SharedPreferences? preferences;
  Future<String?> getToken() async {
     mPreferences ??= await SharedPreferences.getInstance();
    token = mPreferences?.getString(_TOKEN);
    if(token!=null){
      getUser();
    }
    return mPreferences?.getString(_TOKEN);
  }

  void removeToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(_TOKEN);
    token = null;
  }

  Future<String?> getRefreshToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    refreshToken = preferences.getString(_REFRESHTOKEN);
    return preferences.getString(_REFRESHTOKEN);
  }

  void setRefreshToken(String userToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_REFRESHTOKEN, userToken).then((value) {
      refreshToken = userToken;
    });
  }

  void setUser(User userData) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJson = jsonEncode(User.fromJson(userData.toJson()));
    preferences.setString(_USER, userJson).then((value) {
      user = userData;
    });
  }
  Future<String?> getDatan() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      dataf = preferences.getString(_dataff);
      return preferences.getString(_dataff);
    }

    void setDatanot(String datan) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString(_dataff, datan).then((value) {
        dataf = datan;
      });
    }
  SharedPreferences? mPreferences;

  Future<User> getUser() async {
    mPreferences ??= await SharedPreferences.getInstance();
    Map<String, dynamic>  userMap = jsonDecode(mPreferences?.getString('user')??"{}");
    var userData = User.fromJson(userMap);
    user = userData;
    return userData;
  }

  void setAdvertisements(AdvertisementsListData adsList) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String adsJson =
        jsonEncode(AdvertisementsListData.fromJson(adsList.toJson()));
    preferences.setString(_ADVERTISEMENTS, adsJson).then((value) {
      advertisements = adsList;
    });
  }

  Future<AdvertisementsListData> getAdvertisements() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, dynamic>  adsMap = jsonDecode(preferences.getString(_ADVERTISEMENTS)??"{}");
    var adsData = AdvertisementsListData.fromJson(adsMap);
    advertisements = adsData;
    return adsData;
  }

  void setInterests(List<String> interest) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_INTERESTS, interest).then((value) {
      interests = interest;
    });
  }

  Future<List<String>?> getInterests() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getStringList(_INTERESTS) != null) {
      interests = preferences.getStringList(_INTERESTS);
    }
    return preferences.getStringList(_INTERESTS);
  }



  Future<String?> getPlayerId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    playerId = preferences.getString(_PLAYER_ID);
    return preferences.getString(_PLAYER_ID);
  }

  void setNotificationsCount(int count) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_NOTIFICATIONS_COUNT, count).then((value) {
      notificationsCount = count;
    });
  }

  Future<int?> getNotificationsCount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    notificationsCount = preferences.getInt(_NOTIFICATIONS_COUNT);
    return preferences.getInt(_NOTIFICATIONS_COUNT);
  }

  void setOpenedBefore(bool isOpened) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_IS_OPENED_BEFORE, isOpened).then((value) {});
  }

  Future<bool?> isOpenedBefore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_IS_OPENED_BEFORE);
  }

  void removeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(_USER);
  }

  void removeSession() async {
    token=null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(_LOGIN_DATA);
    preferences.remove(_USER);
    preferences.remove(_TOKEN);
    preferences.remove(_REFRESHTOKEN);
    preferences.remove(_NOTIFICATIONS_COUNT);
    preferences.remove(_PLAYER_ID);
    preferences.remove(_INTERESTS);
  }
}
