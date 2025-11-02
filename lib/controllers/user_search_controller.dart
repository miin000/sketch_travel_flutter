import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/user.dart';

class UserSearchController extends GetxController {
  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);
  List<User> get searchedUsers => _searchedUsers.value;

  void searchUser(String typedUser) {
    String query = typedUser.trim().toLowerCase(); // Luôn tìm kiếm bằng chữ thường

    if (query.isEmpty) {
      _searchedUsers.value = []; // reset khi không nhập gì
      return;
    }

    _searchedUsers.bindStream(
      firestore
          .collection('users')
          .where('searchKeywords', arrayContains: query)
          .snapshots()
          .map((QuerySnapshot query) {

        List<User> retVal = [];
        String currentUserId = authController.user.uid;

        for (var element in query.docs) {
          User user = User.fromJson(element.data() as Map<String, dynamic>);

          if (user.uid != currentUserId) {
            retVal.add(user);
          }

        }
        return retVal;
      }),
    );
  }
}