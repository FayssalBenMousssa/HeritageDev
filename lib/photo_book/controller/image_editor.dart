
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageEditor extends  GetxController {

  Rx<XFile> imageFile = XFile('').obs;
  final imagePiker = ImagePicker() ;
  pickImage() async {

    imageFile.value = ( await imagePiker.pickImage(source: ImageSource.gallery , imageQuality:  100))! ;
    imageFile.refresh() ;
  }



}