import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/chat_room.dart';
import '/models/user.dart';

class ConversationController extends GetxController {
  final Rx<List<ChatRoom>> _conversations = Rx<List<ChatRoom>>([]);
  List<ChatRoom> get conversations => _conversations.value;

  final RxList<User> friendsList = <User>[].obs;

  Future<void> loadFriends() async {
    final String myUid = authController.userAccount.uid;
    DocumentSnapshot myDoc =
    await firestore.collection('users').doc(myUid).get();

    if (!myDoc.exists) return;
    final data = myDoc.data() as Map<String, dynamic>? ?? {};
    List<String> friendUids = List<String>.from(data['friends'] ?? []);

    if (friendUids.isEmpty) {
      friendsList.clear();
      return;
    }

    var snapshot = await firestore
        .collection('users')
        .where('uid', whereIn: friendUids)
        .get();

    friendsList.value = snapshot.docs
        .map((d) => User.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    String currentUserId = authController.userAccount.uid;
    _conversations.bindStream(
      firestore
          .collection('chatRooms')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs
            .map((doc) => ChatRoom.fromSnap(doc))
            .toList();
      }),
    );
  }
}