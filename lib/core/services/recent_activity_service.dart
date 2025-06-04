// lib/core/services/recent_activity_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/recent_activity.dart';

class RecentActivityService {
  // REMOVA O UNDERSCORE '_' para torná-los públicos
  static const String boxName = 'recentActivitiesBox'; // Agora público
  static const int maxActivities =
      5; // Agora público (e o erro de digitação corrigido)

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecentActivityAdapter());
    }
    await Hive.openBox<RecentActivity>(
      boxName,
    ); // Use o nome público aqui também
  }

  // Se você decidir manter addActivity e getRecentActivities como métodos de instância,
  // então o getter abaixo está bom.
  // Box<RecentActivity> get _activityBox => Hive.box<RecentActivity>(boxName);

  // Se você seguir minha sugestão anterior de torná-los estáticos, acessaria a box diretamente
  // static Box<RecentActivity> get _activityBox => Hive.box<RecentActivity>(boxName);

  Future<void> addActivity({
    required String type,
    required String description,
  }) async {
    final activity = RecentActivity(
      id: const Uuid().v4(),
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );

    // Acesse a box publicamente
    final activityBox = Hive.box<RecentActivity>(boxName);
    await activityBox.add(activity);

    if (activityBox.length > maxActivities) {
      // Use o nome público
      await activityBox.deleteAt(0);
    }
  }

  List<RecentActivity> getRecentActivities() {
    // Acesse a box publicamente
    final activityBox = Hive.box<RecentActivity>(boxName);
    final activities =
        activityBox.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(maxActivities).toList(); // Use o nome público
  }
}
