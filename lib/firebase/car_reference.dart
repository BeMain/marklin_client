import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';

class CarReference {
  final CollectionReference<Map<String, dynamic>> collRef;
  final CollectionReference<Lap> lapsRef;

  CarReference({required this.collRef})
      : lapsRef = collRef.withConverter<Lap>(
          fromFirestore: (snapshot, _) => Lap.fromJson(snapshot.data()!),
          toFirestore: (lap, _) => lap.toJson(),
        );

  /// The snapshots of all the laps currently on the database.
  Future<List<DocumentSnapshot<Lap>>> getLapDocs(
      {includeCurrent = false}) async {
    var docs =
        (await lapsRef.orderBy("lapNumber", descending: true).get()).docs;
    if (!includeCurrent) docs.removeWhere((docSnap) => docSnap.id == "current");
    return docs;
  }

  /// Get all the laps currently on the database.
  Future<List<Lap>> getLaps({includeCurrent = false}) async {
    var docSnaps = (await getLapDocs(includeCurrent: includeCurrent));
    return docSnaps.map((doc) => doc.data()!).toList();
  }

  /// The most recent lap for the car that [this] references,
  /// or null if no laps have been completed.
  Future<Lap?> get lastLap async {
    var query =
        await lapsRef.orderBy("lapNumber", descending: true).limit(1).get();
    return query.docs.isNotEmpty ? query.docs[0].data() : null;
  }
}
