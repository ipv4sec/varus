
import 'package:get/get.dart';

class AboutPageViewModel extends GetxController {
var data = AboutViewModel(description: "Copyright © by YuYuai. All rights reserved.").obs;
void updateDescription(String description) {
  data.update((val) {
    val?.description = description;
  });
}
}


class AboutViewModel {
  String description;
  AboutViewModel({required this.description});

}