import 'dart:io';

class UserValidatorMixin {


  bool isValidPassword(String password) {
    return password.isNotEmpty;
  }
  bool isValidPhone(String phone) {
    return phone.isNotEmpty;
  }
  bool isValidEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  bool isValidImageExtension(File imageFile) {
    String extension = imageFile.path.split('.').last;
    return extension == 'png' || extension == 'jpg' || extension == 'jpeg';
  }

  bool isValidCVExtension(File imageFile) {
    String extension = imageFile.path.split('.').last;
    return extension == 'pdf';
  }

  bool isValidImageSize(File imageFile) {
    return imageFile.lengthSync() / (1024 * 1024) < 20;
  }
}
