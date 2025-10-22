import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/user.dart';

class Search_Controller extends GetxController {
  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);
  List<User> get searchedUsers => _searchedUsers.value;

  void searchUser(String typedUser) {
    if (typedUser.trim().isEmpty) {
      _searchedUsers.value = []; // reset khi không nhập gì
      return;
    }

    _searchedUsers.bindStream(
      firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: typedUser)
          .where('username', isLessThanOrEqualTo: '$typedUser\uf8ff')
          .snapshots()
          .map((QuerySnapshot query) {
        List<User> retVal = [];
        for (var element in query.docs) {
          retVal.add(User.fromJson(element.data() as Map<String, dynamic>));
        }
        return retVal;
      }),
    );
  }
}
