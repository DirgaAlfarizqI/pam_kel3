// Domain Models untuk TaniJagung sesuai Aturan 9

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? profilePhoto;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.profilePhoto,
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? profilePhoto,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'email': email,
    'profilePhoto': profilePhoto,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    userId: map['userId'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    profilePhoto: map['profilePhoto'],
  );
}

class LandModel {
  final String landId;
  final String userId;
  final String name;
  final double areaHa;
  final String? locationNote;
  final String? notes;

  const LandModel({
    required this.landId,
    required this.userId,
    required this.name,
    required this.areaHa,
    this.locationNote,
    this.notes,
  });

  LandModel copyWith({
    String? landId,
    String? userId,
    String? name,
    double? areaHa,
    String? locationNote,
    String? notes,
  }) {
    return LandModel(
      landId: landId ?? this.landId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      areaHa: areaHa ?? this.areaHa,
      locationNote: locationNote ?? this.locationNote,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'landId': landId,
    'userId': userId,
    'name': name,
    'areaHa': areaHa,
    'locationNote': locationNote,
    'notes': notes,
  };

  factory LandModel.fromMap(Map<String, dynamic> map) => LandModel(
    landId: map['landId'] ?? '',
    userId: map['userId'] ?? '',
    name: map['name'] ?? '',
    areaHa: (map['areaHa'] as num?)?.toDouble() ?? 1.0,
    locationNote: map['locationNote'],
    notes: map['notes'],
  );
}

class PlantingModel {
  final String plantingId;
  final String userId;
  final String landId;
  final String name;
  final String cornVariety;
  final DateTime plantingDate;
  final DateTime estimatedHarvestDate;
  final DateTime? actualHarvestDate;
  final String status; // 'aktif' atau 'selesai'
  final String? notes;

  const PlantingModel({
    required this.plantingId,
    required this.userId,
    required this.landId,
    required this.name,
    required this.cornVariety,
    required this.plantingDate,
    required this.estimatedHarvestDate,
    this.actualHarvestDate,
    this.status = 'aktif',
    this.notes,
  });

  bool get isAktif => status.toLowerCase() == 'aktif';
  bool get isSelesai => status.toLowerCase() == 'selesai';

  PlantingModel copyWith({
    String? plantingId,
    String? userId,
    String? landId,
    String? name,
    String? cornVariety,
    DateTime? plantingDate,
    DateTime? estimatedHarvestDate,
    DateTime? actualHarvestDate,
    String? status,
    String? notes,
  }) {
    return PlantingModel(
      plantingId: plantingId ?? this.plantingId,
      userId: userId ?? this.userId,
      landId: landId ?? this.landId,
      name: name ?? this.name,
      cornVariety: cornVariety ?? this.cornVariety,
      plantingDate: plantingDate ?? this.plantingDate,
      estimatedHarvestDate: estimatedHarvestDate ?? this.estimatedHarvestDate,
      actualHarvestDate: actualHarvestDate ?? this.actualHarvestDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'plantingId': plantingId,
    'userId': userId,
    'landId': landId,
    'name': name,
    'cornVariety': cornVariety,
    'plantingDate': plantingDate.toIso8601String(),
    'estimatedHarvestDate': estimatedHarvestDate.toIso8601String(),
    'actualHarvestDate': actualHarvestDate?.toIso8601String(),
    'status': status,
    'notes': notes,
  };

  factory PlantingModel.fromMap(Map<String, dynamic> map) => PlantingModel(
    plantingId: map['plantingId'] ?? '',
    userId: map['userId'] ?? '',
    landId: map['landId'] ?? '',
    name: map['name'] ?? '',
    cornVariety: map['cornVariety'] ?? '',
    plantingDate: DateTime.tryParse(map['plantingDate'] ?? '') ?? DateTime.now(),
    estimatedHarvestDate: DateTime.tryParse(map['estimatedHarvestDate'] ?? '') ?? DateTime.now(),
    actualHarvestDate: map['actualHarvestDate'] != null ? DateTime.tryParse(map['actualHarvestDate']) : null,
    status: map['status'] ?? 'aktif',
    notes: map['notes'],
  );
}

class ExpenseModel {
  final String expenseId;
  final String userId;
  final String plantingId;
  final DateTime date;
  final String category; // 'Pupuk', 'Benih', 'Pestisida', 'Pengolahan Lahan', 'Tenaga Kerja', 'Sewa Alat', 'Transportasi', 'Biaya Panen', 'Biaya Lain-lain'
  final String description;
  final double? quantity;
  final String? unit; // 'kg', 'liter', 'karung', 'hari kerja', dll.
  final double? unitPrice;
  final double amount;
  final String? notes;

  const ExpenseModel({
    required this.expenseId,
    required this.userId,
    required this.plantingId,
    required this.date,
    required this.category,
    required this.description,
    this.quantity,
    this.unit,
    this.unitPrice,
    required this.amount,
    this.notes,
  });

  ExpenseModel copyWith({
    String? expenseId,
    String? userId,
    String? plantingId,
    DateTime? date,
    String? category,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? amount,
    String? notes,
  }) {
    return ExpenseModel(
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      plantingId: plantingId ?? this.plantingId,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'expenseId': expenseId,
    'userId': userId,
    'plantingId': plantingId,
    'date': date.toIso8601String(),
    'category': category,
    'description': description,
    'quantity': quantity,
    'unit': unit,
    'unitPrice': unitPrice,
    'amount': amount,
    'notes': notes,
  };

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
    expenseId: map['expenseId'] ?? '',
    userId: map['userId'] ?? '',
    plantingId: map['plantingId'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    category: map['category'] ?? 'Lain-lain',
    description: map['description'] ?? '',
    quantity: (map['quantity'] as num?)?.toDouble(),
    unit: map['unit'],
    unitPrice: (map['unitPrice'] as num?)?.toDouble(),
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    notes: map['notes'],
  );
}

class HarvestModel {
  final String harvestId;
  final String userId;
  final String plantingId;
  final DateTime harvestDate;
  final double quantityKg;
  final double salePricePerKg;
  final double revenue;
  final String? notes;

  const HarvestModel({
    required this.harvestId,
    required this.userId,
    required this.plantingId,
    required this.harvestDate,
    required this.quantityKg,
    required this.salePricePerKg,
    required this.revenue,
    this.notes,
  });

  HarvestModel copyWith({
    String? harvestId,
    String? userId,
    String? plantingId,
    DateTime? harvestDate,
    double? quantityKg,
    double? salePricePerKg,
    double? revenue,
    String? notes,
  }) {
    return HarvestModel(
      harvestId: harvestId ?? this.harvestId,
      userId: userId ?? this.userId,
      plantingId: plantingId ?? this.plantingId,
      harvestDate: harvestDate ?? this.harvestDate,
      quantityKg: quantityKg ?? this.quantityKg,
      salePricePerKg: salePricePerKg ?? this.salePricePerKg,
      revenue: revenue ?? this.revenue,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'harvestId': harvestId,
    'userId': userId,
    'plantingId': plantingId,
    'harvestDate': harvestDate.toIso8601String(),
    'quantityKg': quantityKg,
    'salePricePerKg': salePricePerKg,
    'revenue': revenue,
    'notes': notes,
  };

  factory HarvestModel.fromMap(Map<String, dynamic> map) => HarvestModel(
    harvestId: map['harvestId'] ?? '',
    userId: map['userId'] ?? '',
    plantingId: map['plantingId'] ?? '',
    harvestDate: DateTime.tryParse(map['harvestDate'] ?? '') ?? DateTime.now(),
    quantityKg: (map['quantityKg'] as num?)?.toDouble() ?? 0.0,
    salePricePerKg: (map['salePricePerKg'] as num?)?.toDouble() ?? 0.0,
    revenue: (map['revenue'] as num?)?.toDouble() ?? 0.0,
    notes: map['notes'],
  );
}

class ActivityModel {
  final String activityId;
  final String userId;
  final String plantingId;
  final DateTime date;
  final String type; // 'Penanaman', 'Pemupukan', 'Penggunaan pestisida', 'Penyiraman', 'Pengolahan lahan', 'Tenaga kerja', 'Panen', 'Lainnya'
  final String description;
  final String? photoUrl;
  final double? quantity;
  final String? unit;
  final double? cost;
  final String? notes;

  const ActivityModel({
    required this.activityId,
    required this.userId,
    required this.plantingId,
    required this.date,
    required this.type,
    required this.description,
    this.photoUrl,
    this.quantity,
    this.unit,
    this.cost,
    this.notes,
  });

  ActivityModel copyWith({
    String? activityId,
    String? userId,
    String? plantingId,
    DateTime? date,
    String? type,
    String? description,
    String? photoUrl,
    double? quantity,
    String? unit,
    double? cost,
    String? notes,
  }) {
    return ActivityModel(
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      plantingId: plantingId ?? this.plantingId,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'activityId': activityId,
    'userId': userId,
    'plantingId': plantingId,
    'date': date.toIso8601String(),
    'type': type,
    'description': description,
    'photoUrl': photoUrl,
    'quantity': quantity,
    'unit': unit,
    'cost': cost,
    'notes': notes,
  };

  factory ActivityModel.fromMap(Map<String, dynamic> map) => ActivityModel(
    activityId: map['activityId'] ?? '',
    userId: map['userId'] ?? '',
    plantingId: map['plantingId'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    type: map['type'] ?? 'Lainnya',
    description: map['description'] ?? '',
    photoUrl: map['photoUrl'],
    quantity: (map['quantity'] as num?)?.toDouble(),
    unit: map['unit'],
    cost: (map['cost'] as num?)?.toDouble(),
    notes: map['notes'],
  );
}

class ReminderModel {
  final String reminderId;
  final String userId;
  final String? plantingId;
  final String title;
  final DateTime scheduledDate;
  final String? description;
  final bool isCompleted;

  const ReminderModel({
    required this.reminderId,
    required this.userId,
    this.plantingId,
    required this.title,
    required this.scheduledDate,
    this.description,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? reminderId,
    String? userId,
    String? plantingId,
    String? title,
    DateTime? scheduledDate,
    String? description,
    bool? isCompleted,
  }) {
    return ReminderModel(
      reminderId: reminderId ?? this.reminderId,
      userId: userId ?? this.userId,
      plantingId: plantingId ?? this.plantingId,
      title: title ?? this.title,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() => {
    'reminderId': reminderId,
    'userId': userId,
    'plantingId': plantingId,
    'title': title,
    'scheduledDate': scheduledDate.toIso8601String(),
    'description': description,
    'isCompleted': isCompleted,
  };

  factory ReminderModel.fromMap(Map<String, dynamic> map) => ReminderModel(
    reminderId: map['reminderId'] ?? '',
    userId: map['userId'] ?? '',
    plantingId: map['plantingId'],
    title: map['title'] ?? '',
    scheduledDate: DateTime.tryParse(map['scheduledDate'] ?? '') ?? DateTime.now(),
    description: map['description'],
    isCompleted: map['isCompleted'] ?? false,
  );
}
