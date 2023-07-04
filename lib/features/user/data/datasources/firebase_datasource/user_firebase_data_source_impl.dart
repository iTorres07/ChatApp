import 'package:chat_app_1/features/user/data/datasources/firebase_datasource/user_firebase_data_source.dart';
import 'package:chat_app_1/features/user/data/models/user_model.dart';
import 'package:chat_app_1/features/user/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirebaseDataSourceImpl implements UserFirebaseDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  UserFirebaseDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<void> forgotPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  @override
  Stream<List<UserEntity>> getAllUsers(UserEntity user) {
    final userCollection = firestore.collection("users");

    return userCollection
        .where("uid", isNotEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    });
  }

  @override
  Future<void> getCreateCurrentUser(UserEntity user) async {
    final userCollection = firestore.collection("users");

    final uid = await getCurrentUId();

    userCollection.doc(uid).get().then((userDoc) {
      if (!userDoc.exists) {
        final newUser = UserModel(
          email: user.email,
          uid: uid,
          status: user.status,
          profileUrl: user.profileUrl,
          name: user.name,
        ).toDocument();

        userCollection.doc(uid).set(newUser);
      } else {
        print("User already exists");
        return;
      }
    });
  }

  @override
  Future<String> getCurrentUId() async => auth.currentUser!.uid;

  @override
  Stream<List<UserEntity>> getSingleUser(UserEntity user) {
    final userCollection = firestore.collection("users");

    return userCollection
        .limit(1)
        .where("uid", isEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    });
  }

  @override
  Future<void> getUpdateUser(UserEntity user) async {
    final userCollection = firestore.collection("users");

    Map<String, dynamic> userInformation = Map();

    if (user.profileUrl != null && user.profileUrl != "") {
      userInformation['profileUrl'] = user.profileUrl;
    }

    if (user.status != null && user.status != "") {
      userInformation['status'] = user.status;
    }

    if (user.name != null && user.name != "") {
      userInformation['name'] = user.name;
    }

    await userCollection.doc(user.uid).update(userInformation);
  }

  @override
  Future<bool> isSignIn() async {
    return auth.currentUser?.uid != null;
  }

  @override
  Future<void> signIn(UserEntity user) async {
    await auth.signInWithEmailAndPassword(
        email: user.email!, password: user.password!);
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }

  @override
  Future<void> signUp(UserEntity user) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );

      // Obtener la referencia a la colección "users"
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Crear un nuevo documento con el ID del usuario recién creado
      await usersCollection.doc(userCredential.user!.uid).set({
        'name': user.name,
        'email': user.email,
        'profileUrl': '',
        'status': '',
        'uid': userCredential.user!.uid
      });

      // El documento se creó correctamente
      print('Usuario creado en Firestore');
    } catch (e) {
      // Hubo un error al crear el usuario o el documento
      print('Error: $e');
    }
  }
}
