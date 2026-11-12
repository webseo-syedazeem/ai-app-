class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String plan; // 'free' | 'plus' | 'pro'
  final int aiCredits;
  final int dailyActionsUsed;
  final int monthlyActionsUsed;
  final int voiceSecondsUsed;
  final String preferredTone; // 'friendly' | 'professional' | 'concise'
  final List<String> focusAreas;
  final String helperContext;
  final String timezone;
  final bool pushNotificationsEnabled;
  final bool onboardingCompleted;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.plan,
    required this.aiCredits,
    required this.dailyActionsUsed,
    required this.monthlyActionsUsed,
    required this.voiceSecondsUsed,
    required this.preferredTone,
    required this.focusAreas,
    required this.helperContext,
    required this.timezone,
    required this.pushNotificationsEnabled,
    required this.onboardingCompleted,
  });

  UserProfileModel copyWith({
    String? fullName,
    String? email,
    String? plan,
    int? aiCredits,
    int? dailyActionsUsed,
    int? monthlyActionsUsed,
    int? voiceSecondsUsed,
    String? preferredTone,
    List<String>? focusAreas,
    String? helperContext,
    String? timezone,
    bool? pushNotificationsEnabled,
    bool? onboardingCompleted,
  }) {
    return UserProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      aiCredits: aiCredits ?? this.aiCredits,
      dailyActionsUsed: dailyActionsUsed ?? this.dailyActionsUsed,
      monthlyActionsUsed: monthlyActionsUsed ?? this.monthlyActionsUsed,
      voiceSecondsUsed: voiceSecondsUsed ?? this.voiceSecondsUsed,
      preferredTone: preferredTone ?? this.preferredTone,
      focusAreas: focusAreas ?? this.focusAreas,
      helperContext: helperContext ?? this.helperContext,
      timezone: timezone ?? this.timezone,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'plan': plan,
        'ai_credits': aiCredits,
        'daily_actions_used': dailyActionsUsed,
        'monthly_actions_used': monthlyActionsUsed,
        'voice_seconds_used': voiceSecondsUsed,
        'preferred_tone': preferredTone,
        'focus_areas': focusAreas,
        'helper_context': helperContext,
        'timezone': timezone,
        'push_notifications_enabled': pushNotificationsEnabled,
        'onboarding_completed': onboardingCompleted,
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        id: json['id']?.toString() ?? 'local-user',
        fullName: json['full_name']?.toString() ?? 'Azeem',
        email: json['email']?.toString() ?? 'azeem@example.com',
        plan: json['plan']?.toString() ?? 'plus',
        aiCredits: (json['ai_credits'] as num?)?.toInt() ?? 1000,
        dailyActionsUsed: (json['daily_actions_used'] as num?)?.toInt() ?? 0,
        monthlyActionsUsed: (json['monthly_actions_used'] as num?)?.toInt() ?? 14,
        voiceSecondsUsed: (json['voice_seconds_used'] as num?)?.toInt() ?? 420,
        preferredTone: json['preferred_tone']?.toString() ?? 'friendly',
        focusAreas: (json['focus_areas'] as List?)?.map((e) => e.toString()).toList() ??
            const ['work', 'shopping', 'personal'],
        helperContext: json['helper_context']?.toString() ?? '',
        timezone: json['timezone']?.toString() ?? 'Asia/Karachi',
        pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
        onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      );
}

class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime? dueAt;
  final String priority; // 'low' | 'normal' | 'high'
  final bool completed;
  final String section; // 'today' | 'upcoming'

  const TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.dueAt,
    this.priority = 'normal',
    this.completed = false,
    this.section = 'today',
  });

  TaskModel copyWith({bool? completed, String? title, String? subtitle, DateTime? dueAt}) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dueAt: dueAt ?? this.dueAt,
      priority: priority,
      completed: completed ?? this.completed,
      section: section,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'due_at': dueAt?.toIso8601String(),
        'priority': priority,
        'completed': completed,
        'section': section,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        dueAt: json['due_at'] != null ? DateTime.tryParse(json['due_at'].toString()) : null,
        priority: json['priority']?.toString() ?? 'normal',
        completed: json['completed'] as bool? ?? (json['status'] == 'completed'),
        section: json['section']?.toString() ?? 'today',
      );
}

class ReminderModel {
  final String id;
  final String title;
  final String displayTime;
  final DateTime remindAt;
  final String section; // 'tomorrow' | 'this_week'
  final bool completed;
  final String iconKind; // 'bell' | 'calendar' | 'briefcase'

  const ReminderModel({
    required this.id,
    required this.title,
    required this.displayTime,
    required this.remindAt,
    this.section = 'tomorrow',
    this.completed = false,
    this.iconKind = 'bell',
  });

  ReminderModel copyWith({bool? completed, String? title, String? displayTime}) {
    return ReminderModel(
      id: id,
      title: title ?? this.title,
      displayTime: displayTime ?? this.displayTime,
      remindAt: remindAt,
      section: section,
      completed: completed ?? this.completed,
      iconKind: iconKind,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'display_time': displayTime,
        'remind_at': remindAt.toIso8601String(),
        'section': section,
        'completed': completed,
        'icon_kind': iconKind,
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        displayTime: json['display_time']?.toString() ?? '',
        remindAt: DateTime.tryParse(json['remind_at']?.toString() ?? '') ?? DateTime.now(),
        section: json['section']?.toString() ?? 'tomorrow',
        completed: json['completed'] as bool? ?? (json['status'] == 'completed'),
        iconKind: json['icon_kind']?.toString() ?? 'bell',
      );
}

class ShoppingItemModel {
  final String id;
  final String item;
  final String category;
  final bool completed;

  const ShoppingItemModel({
    required this.id,
    required this.item,
    required this.category,
    this.completed = false,
  });

  ShoppingItemModel copyWith({bool? completed, String? item, String? category}) {
    return ShoppingItemModel(
      id: id,
      item: item ?? this.item,
      category: category ?? this.category,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item,
        'category': category,
        'completed': completed,
      };

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) => ShoppingItemModel(
        id: json['id']?.toString() ?? '',
        item: json['item']?.toString() ?? '',
        category: json['category']?.toString() ?? 'General',
        completed: json['completed'] as bool? ?? false,
      );
}

class MemoryModel {
  final String id;
  final String title;
  final String content;
  final String subtitle;
  final String category; // 'people' | 'dates' | 'preferences'
  final String iconKind; // 'calendar' | 'briefcase' | 'user' | 'note'

  const MemoryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.subtitle,
    required this.category,
    this.iconKind = 'note',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'subtitle': subtitle,
        'category': category,
        'icon_kind': iconKind,
      };

  factory MemoryModel.fromJson(Map<String, dynamic> json) => MemoryModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        category: json['category']?.toString() ?? 'preferences',
        iconKind: json['icon_kind']?.toString() ?? 'note',
      );
}

class KeepForLaterModel {
  final String id;
  final String title;
  final String capturedLabel;

  const KeepForLaterModel({
    required this.id,
    required this.title,
    required this.capturedLabel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'captured_label': capturedLabel,
      };

  factory KeepForLaterModel.fromJson(Map<String, dynamic> json) => KeepForLaterModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        capturedLabel: json['captured_label']?.toString() ??
            (json['captured_at'] != null ? 'Captured earlier' : 'Today · Just now'),
      );
}

class GoalModel {
  final String id;
  final String title;
  final int currentValue;
  final int targetValue;
  final String unitLabel;
  final String period; // 'week' | 'month'
  final String iconKind; // 'briefcase' | 'book' | 'shopping'

  const GoalModel({
    required this.id,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.unitLabel,
    this.period = 'week',
    this.iconKind = 'briefcase',
  });

  double get progress => (currentValue / (targetValue == 0 ? 1 : targetValue)).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
  bool get isCompleted => currentValue >= targetValue;

  GoalModel copyWith({int? currentValue}) => GoalModel(
        id: id,
        title: title,
        currentValue: currentValue ?? this.currentValue,
        targetValue: targetValue,
        unitLabel: unitLabel,
        period: period,
        iconKind: iconKind,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'current_value': currentValue,
        'target_value': targetValue,
        'unit_label': unitLabel,
        'period': period,
        'icon_kind': iconKind,
      };

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final category = json['category']?.toString() ?? '';
    final fallbackIcon = category == 'learning'
        ? 'book'
        : category == 'shopping'
            ? 'shopping'
            : 'briefcase';
    return GoalModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      currentValue: (json['current_value'] as num?)?.toInt() ?? 0,
      targetValue: (json['target_value'] as num?)?.toInt() ?? 1,
      unitLabel: json['unit_label']?.toString() ?? '',
      period: json['period']?.toString() ?? 'week',
      iconKind: json['icon_kind']?.toString() ?? fallbackIcon,
    );
  }
}

class AffirmationModel {
  final String id;
  final String quote;
  final String savedLabel;

  const AffirmationModel({
    required this.id,
    required this.quote,
    required this.savedLabel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'quote': quote,
        'saved_label': savedLabel,
      };

  factory AffirmationModel.fromJson(Map<String, dynamic> json) => AffirmationModel(
        id: json['id']?.toString() ?? '',
        quote: json['quote']?.toString() ?? '',
        savedLabel: json['saved_label']?.toString() ??
            json['reminder_label']?.toString() ??
            'Saved',
      );
}

class ChatPendingAction {
  final String type;
  final String title;
  final String displayTime;
  final String timezone;
  final bool confirmed;

  const ChatPendingAction({
    required this.type,
    required this.title,
    required this.displayTime,
    required this.timezone,
    this.confirmed = false,
  });

  ChatPendingAction copyWith({bool? confirmed, String? title, String? displayTime}) =>
      ChatPendingAction(
        type: type,
        title: title ?? this.title,
        displayTime: displayTime ?? this.displayTime,
        timezone: timezone,
        confirmed: confirmed ?? this.confirmed,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'display_time': displayTime,
        'timezone': timezone,
        'confirmed': confirmed,
      };

  factory ChatPendingAction.fromJson(Map<String, dynamic> json) => ChatPendingAction(
        type: json['type']?.toString() ?? 'create_reminder',
        title: json['title']?.toString() ?? '',
        displayTime: json['display_time']?.toString() ?? '',
        timezone: json['timezone']?.toString() ?? 'Asia/Karachi',
        confirmed: json['confirmed'] as bool? ?? false,
      );
}

class ChatMessageModel {
  final String id;
  final bool isUser;
  final String text;
  final ChatPendingAction? pendingAction;
  final String timeLabel;

  const ChatMessageModel({
    required this.id,
    required this.isUser,
    required this.text,
    this.pendingAction,
    this.timeLabel = 'TODAY · 10:42 AM',
  });

  ChatMessageModel copyWith({ChatPendingAction? pendingAction}) => ChatMessageModel(
        id: id,
        isUser: isUser,
        text: text,
        pendingAction: pendingAction ?? this.pendingAction,
        timeLabel: timeLabel,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'is_user': isUser,
        'text': text,
        'pending_action': pendingAction?.toJson(),
        'time_label': timeLabel,
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final isUserMsg = json['is_user'] is bool
        ? json['is_user'] as bool
        : (json['role']?.toString() == 'user');
    final bodyText = json['text']?.toString() ?? json['content']?.toString() ?? '';
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      isUser: isUserMsg,
      text: bodyText,
      pendingAction: json['pending_action'] != null
          ? ChatPendingAction.fromJson(Map<String, dynamic>.from(json['pending_action']))
          : null,
      timeLabel: json['time_label']?.toString() ?? 'TODAY',
    );
  }
}

class BrainDumpDraftItem {
  final String id;
  final String kind; // 'task' | 'reminder' | 'shopping' | 'memory'
  final String title;
  final String subtitle;
  final bool selected;

  const BrainDumpDraftItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.selected = true,
  });

  BrainDumpDraftItem copyWith({bool? selected, String? title, String? subtitle}) =>
      BrainDumpDraftItem(
        id: id,
        kind: kind,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        selected: selected ?? this.selected,
      );
}

class ExpenseModel {
  final String id;
  final String category;
  final String title;
  final int amount;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'amount': amount,
      };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Personal',
        title: json['title']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
      );
}
