class PlanModel {
  final String id;
  final String name;
  final String badge;
  final int price;
  final int ads;
  final String term;
  final int dailyIncome;
  final int totalIncome;
  final String color;

  PlanModel({
    required this.id,
    required this.name,
    required this.badge,
    required this.price,
    required this.ads,
    required this.term,
    required this.dailyIncome,
    required this.totalIncome,
    required this.color,
  });

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      id: map['id'] as String,
      name: map['name'] as String,
      badge: map['badge'] as String,
      price: map['price'] as int,
      ads: map['ads'] as int,
      term: map['term'] as String,
      dailyIncome: map['dailyIncome'] as int,
      totalIncome: map['totalIncome'] as int,
      color: map['color'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'badge': badge,
      'price': price,
      'ads': ads,
      'term': term,
      'dailyIncome': dailyIncome,
      'totalIncome': totalIncome,
      'color': color,
    };
  }
}

// Predefined plans from the web app
class Plans {
  static  List<PlanModel> allPlans = [
    PlanModel(
      id: 'starter',
      name: 'Starter',
      badge: 'Basic',
      price: 2000,
      ads: 20,
      term: '30 days',
      dailyIncome: 750,
      totalIncome: 22500,
      color: 'from-blue-500 to-blue-600',
    ),
    PlanModel(
      id: 'bronze',
      name: 'Bronze',
      badge: 'Standard',
      price: 5000,
      ads: 20,
      term: '30 days',
      dailyIncome: 1800,
      totalIncome: 54000,
      color: 'from-orange-500 to-orange-600',
    ),
    PlanModel(
      id: 'silver',
      name: 'Silver',
      badge: 'Premium',
      price: 10000,
      ads: 20,
      term: '30 days',
      dailyIncome: 3500,
      totalIncome: 105000,
      color: 'from-gray-400 to-gray-500',
    ),
    PlanModel(
      id: 'gold',
      name: 'Gold',
      badge: 'VIP',
      price: 20000,
      ads: 20,
      term: '30 days',
      dailyIncome: 7000,
      totalIncome: 210000,
      color: 'from-yellow-500 to-yellow-600',
    ),
    PlanModel(
      id: 'platinum',
      name: 'Platinum',
      badge: 'Elite',
      price: 50000,
      ads: 20,
      term: '30 days',
      dailyIncome: 17500,
      totalIncome: 525000,
      color: 'from-purple-500 to-purple-600',
    ),
    PlanModel(
      id: 'diamond',
      name: 'Diamond',
      badge: 'Royal',
      price: 100000,
      ads: 20,
      term: '30 days',
      dailyIncome: 35000,
      totalIncome: 1050000,
      color: 'from-cyan-500 to-cyan-600',
    ),
  ];
}
