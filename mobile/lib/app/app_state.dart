import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/database/local_db.dart';
import '../core/models/models.dart';
import '../core/services/api_client.dart';
import '../core/services/notification_service.dart';
import '../core/services/voice_service.dart';

class AppState extends ChangeNotifier {
  final LocalDatabase _localDb;
  final BackendApiClient _api;
  final VoiceService _voice;
  final NotificationService _notifications;

  AppState({
    LocalDatabase? localDb,
    BackendApiClient? api,
    VoiceService? voice,
    NotificationService? notifications,
  })  : _localDb = localDb ?? LocalDatabase(),
        _api = api ?? BackendApiClient(),
        _voice = voice ?? VoiceService(),
        _notifications = notifications ?? NotificationService();

  bool initialized = false;
  bool backendConnected = false;
  bool isAiThinking = false;
  String? authToken;
  String affirmationReminderLabel = 'No reminder scheduled';

  late UserProfileModel user;
  List<TaskModel> tasks = [];
  List<ReminderModel> reminders = [];
  List<ShoppingItemModel> shoppingItems = [];
  List<MemoryModel> memories = [];
  List<KeepForLaterModel> keepForLaterItems = [];
  List<GoalModel> goals = [];
  List<AffirmationModel> affirmations = [];
  List<ChatMessageModel> chatMessages = [];
  List<BrainDumpDraftItem> brainDumpDrafts = [];
  String lastBrainDumpTranscript = '';
  int monthlyBudgetLimit = 45000;
  List<ExpenseModel> expenses = [];
  bool emailReportsEnabled = false;
  bool weeklyEmailSummary = true;
  bool monthlyEmailReview = true;

  VoiceService get voice => _voice;
  String get backendUrl => _api.baseUrl;

  Future<void> setBackendUrl(String url) async {
    _api.baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    backendConnected = await _api.checkHealth();
    await _persist();
    notifyListeners();
  }

  int get pendingTodayTasksCount =>
      tasks.where((t) => !t.completed && t.section == 'today').length;

  int get upcomingRemindersCount =>
      reminders.where((r) => !r.completed).length;

  int get pendingShoppingCount =>
      shoppingItems.where((s) => !s.completed).length;

  int get totalBudgetSpent =>
      expenses.fold<int>(0, (sum, e) => sum + e.amount);

  Future<void> init({bool checkRemote = true}) async {
    await _localDb.init();
    await _notifications.init();
    final snap = await _localDb.readSnapshot();
    if (snap != null) {
      _loadFromSnapshot(snap);
    } else {
      _seedDefaultData();
      await _persist();
    }
    initialized = true;
    notifyListeners();

    if (checkRemote) {
      backendConnected = await _api.checkHealth();
      if (backendConnected && authToken != null && authToken!.isNotEmpty) {
        final me = await _api.get('/auth/me');
        if (me != null && me['user'] is Map) {
          user = UserProfileModel.fromJson(
            Map<String, dynamic>.from(me['user'] as Map),
          );
          _api.userId = user.id;
          await _syncWorkspaceFromBackend();
          await _persist();
        }
      }
      notifyListeners();
    }
  }

  void _seedDefaultData() {
    user = const UserProfileModel(
      id: '00000000-0000-0000-0000-000000000001',
      fullName: 'Azeem',
      email: 'azeem@example.com',
      plan: 'plus',
      aiCredits: 986,
      dailyActionsUsed: 0,
      monthlyActionsUsed: 14,
      voiceSecondsUsed: 420,
      preferredTone: 'friendly',
      focusAreas: ['work', 'shopping', 'personal'],
      helperContext:
          'Help me stay on top of work, remember appointments and organize errands.',
      timezone: 'Asia/Karachi',
      pushNotificationsEnabled: true,
      onboardingCompleted: false,
    );

    tasks = [
      TaskModel(
        id: 't1',
        title: 'Send client proposal',
        subtitle: 'Today · 11:00 AM',
        dueAt: DateTime(2026, 11, 10, 11, 0),
        priority: 'high',
        section: 'today',
      ),
      TaskModel(
        id: 't2',
        title: 'Review homepage design',
        subtitle: 'Today · 3:30 PM',
        dueAt: DateTime(2026, 11, 10, 15, 30),
        priority: 'normal',
        section: 'today',
      ),
      TaskModel(
        id: 't3',
        title: 'Book car service',
        subtitle: 'Tomorrow · 10:00 AM',
        dueAt: DateTime(2026, 11, 11, 10, 0),
        priority: 'normal',
        section: 'upcoming',
      ),
      TaskModel(
        id: 't4',
        title: 'Plan weekend groceries',
        subtitle: 'Thursday · 6:00 PM',
        dueAt: DateTime(2026, 11, 12, 18, 0),
        priority: 'normal',
        section: 'upcoming',
      ),
      TaskModel(
        id: 't5',
        title: 'Finish project handover',
        subtitle: 'Friday · 4:00 PM',
        dueAt: DateTime(2026, 11, 13, 16, 0),
        priority: 'high',
        section: 'upcoming',
      ),
    ];

    reminders = [
      ReminderModel(
        id: 'r1',
        title: 'Call Ali',
        displayTime: 'Wed, Nov 11 · 5:00 PM',
        remindAt: DateTime(2026, 11, 11, 17, 0),
        section: 'tomorrow',
        iconKind: 'bell',
      ),
      ReminderModel(
        id: 'r2',
        title: 'Dentist appointment',
        displayTime: 'Thu, Nov 12 · 4:00 PM',
        remindAt: DateTime(2026, 11, 12, 16, 0),
        section: 'this_week',
        iconKind: 'calendar',
      ),
      ReminderModel(
        id: 'r3',
        title: 'Send final website',
        displayTime: 'Fri, Nov 13 · 11:00 AM',
        remindAt: DateTime(2026, 11, 13, 11, 0),
        section: 'this_week',
        iconKind: 'briefcase',
      ),
    ];

    shoppingItems = const [
      ShoppingItemModel(id: 's1', item: 'Eggs', category: 'Dairy & essentials'),
      ShoppingItemModel(id: 's2', item: 'Bread', category: 'Bakery'),
      ShoppingItemModel(id: 's3', item: 'Detergent', category: 'Household'),
      ShoppingItemModel(id: 's4', item: 'Toothpaste', category: 'Personal care'),
      ShoppingItemModel(id: 's5', item: 'Milk', category: 'Dairy & essentials', completed: true),
      ShoppingItemModel(id: 's6', item: 'Fruit', category: 'Produce', completed: true),
    ];

    memories = const [
      MemoryModel(
        id: 'm1',
        title: 'Mom’s birthday',
        content: 'Mom’s birthday is on March 5.',
        subtitle: 'March 5 · Saved by you',
        category: 'dates',
        iconKind: 'calendar',
      ),
      MemoryModel(
        id: 'm2',
        title: 'Project kickoff',
        content: 'Project kickoff scheduled Feb 10 at 10:00 AM.',
        subtitle: 'Feb 10 · 10:00 AM',
        category: 'dates',
        iconKind: 'briefcase',
      ),
      MemoryModel(
        id: 'm3',
        title: 'Ali’s contact number',
        content: '+92 300 1234567 — Personal',
        subtitle: 'Saved yesterday · Personal',
        category: 'people',
        iconKind: 'user',
      ),
      MemoryModel(
        id: 'm4',
        title: 'Preferred meeting hours',
        content: 'Weekdays after 10 AM',
        subtitle: 'Weekdays after 10 AM',
        category: 'preferences',
        iconKind: 'note',
      ),
    ];

    keepForLaterItems = const [
      KeepForLaterModel(
        id: 'k1',
        title: 'Article about building better habits',
        capturedLabel: 'Today · 9:41 AM',
      ),
      KeepForLaterModel(
        id: 'k2',
        title: 'Weekend trip idea',
        capturedLabel: 'Yesterday · 7:15 PM',
      ),
      KeepForLaterModel(
        id: 'k3',
        title: 'Ask Sara about the new course',
        capturedLabel: 'Nov 6 · 2:20 PM',
      ),
    ];

    goals = const [
      GoalModel(
        id: 'g1',
        title: 'Complete 3 work tasks',
        currentValue: 2,
        targetValue: 3,
        unitLabel: 'complete',
        period: 'week',
        iconKind: 'briefcase',
      ),
      GoalModel(
        id: 'g2',
        title: 'Read for 30 minutes',
        currentValue: 3,
        targetValue: 7,
        unitLabel: 'days',
        period: 'week',
        iconKind: 'book',
      ),
      GoalModel(
        id: 'g3',
        title: 'Organize shopping',
        currentValue: 1,
        targetValue: 1,
        unitLabel: 'Completed',
        period: 'week',
        iconKind: 'shopping',
      ),
    ];

    affirmations = const [
      AffirmationModel(
        id: 'a1',
        quote: '“I will finish what I start, one step at a time.”',
        savedLabel: 'Saved Nov 8, 2026',
      ),
      AffirmationModel(
        id: 'a2',
        quote: '“Progress matters more than perfection.”',
        savedLabel: 'Saved Nov 3, 2026',
      ),
    ];

    chatMessages = const [
      ChatMessageModel(
        id: 'c1',
        isUser: true,
        text: 'Remind me to call Ali tomorrow at 5 PM.',
        timeLabel: 'TODAY · 10:42 AM',
      ),
      ChatMessageModel(
        id: 'c2',
        isUser: false,
        text: 'I can set that up. Here’s what I understood:',
        pendingAction: ChatPendingAction(
          type: 'create_reminder',
          title: 'Call Ali',
          displayTime: 'Wed, Nov 11 · 5:00 PM',
          timezone: 'Asia/Karachi',
        ),
      ),
    ];

    brainDumpDrafts = const [
      BrainDumpDraftItem(
        id: 'bd1',
        kind: 'task',
        title: 'Prepare the project update',
        subtitle: 'Tomorrow',
      ),
      BrainDumpDraftItem(
        id: 'bd2',
        kind: 'task',
        title: 'Email the meeting notes',
        subtitle: 'Friday',
      ),
      BrainDumpDraftItem(
        id: 'bd3',
        kind: 'reminder',
        title: 'Call Ali',
        subtitle: 'Tomorrow at 5:00 PM',
      ),
      BrainDumpDraftItem(
        id: 'bd4',
        kind: 'shopping',
        title: 'Eggs',
        subtitle: 'Dairy & essentials',
      ),
      BrainDumpDraftItem(
        id: 'bd5',
        kind: 'shopping',
        title: 'Bread',
        subtitle: 'Bakery',
      ),
      BrainDumpDraftItem(
        id: 'bd6',
        kind: 'shopping',
        title: 'Detergent',
        subtitle: 'Household',
      ),
    ];

    expenses = const [
      ExpenseModel(id: 'e1', category: 'Groceries', title: 'Weekly groceries', amount: 8500),
      ExpenseModel(id: 'e2', category: 'Bills', title: 'Electricity & internet', amount: 6250),
      ExpenseModel(id: 'e3', category: 'Personal', title: 'Coffee & dining', amount: 3500),
    ];
  }

  void _loadFromSnapshot(Map<String, dynamic> snap) {
    user = UserProfileModel.fromJson(Map<String, dynamic>.from(snap['user'] as Map));
    tasks = (snap['tasks'] as List? ?? const [])
        .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    reminders = (snap['reminders'] as List? ?? const [])
        .map((e) => ReminderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    shoppingItems = (snap['shopping_items'] as List? ?? const [])
        .map((e) => ShoppingItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    memories = (snap['memories'] as List? ?? const [])
        .map((e) => MemoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    keepForLaterItems = (snap['keep_for_later'] as List? ?? const [])
        .map((e) => KeepForLaterModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    goals = (snap['goals'] as List? ?? const [])
        .map((e) => GoalModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    affirmations = (snap['affirmations'] as List? ?? const [])
        .map((e) => AffirmationModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    chatMessages = (snap['chat_messages'] as List? ?? const [])
        .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    expenses = (snap['expenses'] as List? ?? const [])
        .map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    monthlyBudgetLimit = (snap['monthly_budget_limit'] as num?)?.toInt() ?? 45000;
    emailReportsEnabled = snap['email_reports_enabled'] as bool? ?? false;
    weeklyEmailSummary = snap['weekly_email_summary'] as bool? ?? true;
    monthlyEmailReview = snap['monthly_email_review'] as bool? ?? true;
    affirmationReminderLabel =
        snap['affirmation_reminder_label']?.toString() ?? 'No reminder scheduled';
    authToken = snap['auth_token']?.toString();
    _api.authToken = authToken;
    _api.userId = user.id;
    final savedUrl = snap['backend_url']?.toString().trim();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _api.baseUrl = savedUrl;
    }

    if (brainDumpDrafts.isEmpty) {
      brainDumpDrafts = const [
        BrainDumpDraftItem(
          id: 'bd1',
          kind: 'task',
          title: 'Prepare the project update',
          subtitle: 'Tomorrow',
        ),
        BrainDumpDraftItem(
          id: 'bd2',
          kind: 'task',
          title: 'Email the meeting notes',
          subtitle: 'Friday',
        ),
        BrainDumpDraftItem(
          id: 'bd3',
          kind: 'reminder',
          title: 'Call Ali',
          subtitle: 'Tomorrow at 5:00 PM',
        ),
        BrainDumpDraftItem(
          id: 'bd4',
          kind: 'shopping',
          title: 'Eggs',
          subtitle: 'Dairy & essentials',
        ),
        BrainDumpDraftItem(
          id: 'bd5',
          kind: 'shopping',
          title: 'Bread',
          subtitle: 'Bakery',
        ),
        BrainDumpDraftItem(
          id: 'bd6',
          kind: 'shopping',
          title: 'Detergent',
          subtitle: 'Household',
        ),
      ];
    }
  }

  Future<void> _persist() async {
    await _localDb.writeSnapshot({
      'user': user.toJson(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((e) => e.toJson()).toList(),
      'shopping_items': shoppingItems.map((e) => e.toJson()).toList(),
      'memories': memories.map((e) => e.toJson()).toList(),
      'keep_for_later': keepForLaterItems.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'affirmations': affirmations.map((e) => e.toJson()).toList(),
      'chat_messages': chatMessages.map((e) => e.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'monthly_budget_limit': monthlyBudgetLimit,
      'email_reports_enabled': emailReportsEnabled,
      'weekly_email_summary': weeklyEmailSummary,
      'monthly_email_review': monthlyEmailReview,
      'affirmation_reminder_label': affirmationReminderLabel,
      'auth_token': authToken,
      'backend_url': _api.baseUrl,
    });
  }

  Future<void> _syncWorkspaceFromBackend() async {
    if (!backendConnected) return;
    final results = await Future.wait([
      _api.get('/tasks'),
      _api.get('/reminders'),
      _api.get('/shopping'),
      _api.get('/memories'),
    ]);

    final remoteTasks = results[0]?['tasks'];
    if (remoteTasks is List && remoteTasks.isNotEmpty) {
      tasks = remoteTasks
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final remoteReminders = results[1]?['reminders'];
    if (remoteReminders is List && remoteReminders.isNotEmpty) {
      reminders = remoteReminders
          .map((e) => ReminderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final remoteShopping = results[2]?['items'];
    if (remoteShopping is List && remoteShopping.isNotEmpty) {
      shoppingItems = remoteShopping
          .map((e) => ShoppingItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final remoteMemories = results[3]?['memories'];
    if (remoteMemories is List && remoteMemories.isNotEmpty) {
      memories = remoteMemories
          .map((e) => MemoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  // ---------------- ACCOUNT & ONBOARDING ----------------
  Future<String?> updateOnboardingAccount({
    required String fullName,
    required String email,
    String? password,
  }) async {
    final cleanName = fullName.trim().isEmpty ? 'Azeem' : fullName.trim();
    final cleanEmail = email.trim().isEmpty ? user.email : email.trim().toLowerCase();

    if (password != null && password.isNotEmpty) {
      if (!backendConnected) {
        backendConnected = await _api.checkHealth();
      }
      if (backendConnected) {
        final res = await _api.postResult('/auth/signup', {
          'full_name': cleanName,
          'email': cleanEmail,
          'password': password,
        });
        if (!res.ok) {
          return res.error ?? 'Could not create account. Please try again.';
        }
        final data = res.data ?? const {};
        authToken = data['token']?.toString();
        _api.authToken = authToken;
        if (data['user'] is Map) {
          user = UserProfileModel.fromJson(
            Map<String, dynamic>.from(data['user'] as Map),
          );
          _api.userId = user.id;
        }
        await _persist();
        notifyListeners();
        return null;
      }
    }

    user = user.copyWith(
      fullName: cleanName,
      email: cleanEmail,
    );
    await _persist();
    notifyListeners();
    _api.patch('/user', {'full_name': user.fullName, 'email': user.email});
    return null;
  }

  void toggleFocusArea(String area) {
    final list = List<String>.from(user.focusAreas);
    if (list.contains(area)) {
      list.remove(area);
    } else {
      list.add(area);
    }
    user = user.copyWith(focusAreas: list);
    _persist();
    notifyListeners();
  }

  Future<void> completePersonalization({
    required String contextNote,
    required String tone,
  }) async {
    user = user.copyWith(
      helperContext: contextNote.trim(),
      preferredTone: tone,
      onboardingCompleted: true,
    );
    await _persist();
    notifyListeners();
    _api.patch('/user', {
      'helper_context': user.helperContext,
      'preferred_tone': tone,
      'focus_areas': user.focusAreas,
      'onboarding_completed': true,
    });
  }

  Future<void> updatePreferences({
    String? fullName,
    String? tone,
    String? timezone,
    bool? pushEnabled,
    String? plan,
  }) async {
    user = user.copyWith(
      fullName: fullName,
      preferredTone: tone,
      timezone: timezone,
      pushNotificationsEnabled: pushEnabled,
      plan: plan,
    );
    await _persist();
    notifyListeners();
    _api.patch('/user', {
      'full_name': ?fullName,
      'preferred_tone': ?tone,
      'timezone': ?timezone,
      'push_notifications_enabled': ?pushEnabled,
      'plan': ?plan,
    });
  }

  Future<String?> signInExisting({String? email, String? password}) async {
    final cleanEmail = email?.trim().toLowerCase();
    if (cleanEmail != null &&
        cleanEmail.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      if (!backendConnected) {
        backendConnected = await _api.checkHealth();
      }
      if (backendConnected) {
        final res = await _api.postResult('/auth/login', {
          'email': cleanEmail,
          'password': password,
        });
        if (!res.ok) {
          return res.error ?? 'Invalid email or password.';
        }
        final data = res.data ?? const {};
        authToken = data['token']?.toString();
        _api.authToken = authToken;
        if (data['user'] is Map) {
          user = UserProfileModel.fromJson(
            Map<String, dynamic>.from(data['user'] as Map),
          ).copyWith(onboardingCompleted: true);
          _api.userId = user.id;
        }
        await _syncWorkspaceFromBackend();
        await _persist();
        notifyListeners();
        return null;
      }
    }

    final derivedName = (cleanEmail != null && cleanEmail.contains('@'))
        ? cleanEmail.split('@').first
        : null;
    user = user.copyWith(
      email: (cleanEmail != null && cleanEmail.isNotEmpty) ? cleanEmail : user.email,
      fullName: (user.fullName.isEmpty && derivedName != null && derivedName.isNotEmpty)
          ? derivedName[0].toUpperCase() + derivedName.substring(1)
          : user.fullName,
      onboardingCompleted: true,
    );
    await _persist();
    notifyListeners();
    return null;
  }

  Future<String?> requestPasswordReset(String email) async {
    if (!backendConnected) {
      backendConnected = await _api.checkHealth();
    }
    if (!backendConnected) {
      return 'Recovery link queued locally for ${email.trim()}';
    }
    final res = await _api.postResult('/auth/forgot-password', {
      'email': email.trim(),
    });
    if (!res.ok) {
      return res.error ?? 'Could not process recovery request.';
    }
    return res.data?['message']?.toString() ?? 'Recovery link sent to ${email.trim()}';
  }

  Future<void> logOut() async {
    authToken = null;
    _api.authToken = null;
    user = user.copyWith(onboardingCompleted: false);
    await _persist();
    notifyListeners();
  }

  // ---------------- TASKS ----------------
  Future<void> toggleTask(String id) async {
    tasks = tasks
        .map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t)
        .toList();
    await _persist();
    notifyListeners();
    final toggled = tasks.firstWhere((t) => t.id == id);
    _api.patch('/tasks/$id', {'status': toggled.completed ? 'completed' : 'pending'});
  }

  Future<void> addTask(String title, {String subtitle = 'Today · 5:00 PM', String section = 'today', String priority = 'normal'}) async {
    final task = TaskModel(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      subtitle: subtitle,
      dueAt: DateTime.now().add(const Duration(hours: 2)),
      priority: priority,
      section: section,
    );
    tasks = [task, ...tasks];
    await _persist();
    notifyListeners();
    _api.post('/tasks', {'title': task.title, 'priority': priority});
  }

  Future<void> deleteTask(String id) async {
    tasks = tasks.where((t) => t.id != id).toList();
    await _persist();
    notifyListeners();
    _api.delete('/tasks/$id');
  }

  Future<void> editTask(
    String id, {
    String? title,
    String? subtitle,
    String? section,
    String? priority,
  }) async {
    tasks = tasks.map((t) {
      if (t.id != id) return t;
      return TaskModel(
        id: t.id,
        title: title?.trim().isNotEmpty == true ? title!.trim() : t.title,
        subtitle: subtitle ?? t.subtitle,
        dueAt: t.dueAt,
        priority: priority ?? t.priority,
        completed: t.completed,
        section: section ?? t.section,
      );
    }).toList();
    await _persist();
    notifyListeners();
    _api.patch('/tasks/$id', {
      'title': ?title,
      'priority': ?priority,
    });
  }

  Future<int> moveTodayUnfinishedToTomorrow() async {
    int count = 0;
    tasks = tasks.map((t) {
      if (!t.completed && t.section == 'today') {
        count++;
        return TaskModel(
          id: t.id,
          title: t.title,
          subtitle: 'Tomorrow · 10:00 AM',
          dueAt: (t.dueAt ?? DateTime.now()).add(const Duration(days: 1)),
          priority: t.priority,
          completed: false,
          section: 'upcoming',
        );
      }
      return t;
    }).toList();
    await _persist();
    notifyListeners();
    _api.post('/ai/evening/rollover', {});
    return count;
  }

  // ---------------- REMINDERS ----------------
  Future<void> toggleReminder(String id) async {
    reminders = reminders
        .map((r) => r.id == id ? r.copyWith(completed: !r.completed) : r)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> addReminder(String title, {String displayTime = 'Tomorrow · 5:00 PM', DateTime? when}) async {
    final targetTime = when ?? DateTime.now().add(const Duration(days: 1));
    final rem = ReminderModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      displayTime: displayTime,
      remindAt: targetTime,
      section: 'tomorrow',
    );
    reminders = [rem, ...reminders];
    await _persist();
    notifyListeners();
    await _notifications.scheduleReminder(
      id: rem.id.hashCode & 0x7fffffff,
      title: rem.title,
      when: targetTime,
    );
    _api.post('/reminders', {'title': rem.title, 'remind_at': targetTime.toIso8601String()});
  }

  Future<void> deleteReminder(String id) async {
    reminders = reminders.where((r) => r.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> editReminder(String id, {required String title, required String displayTime}) async {
    reminders = reminders.map((r) {
      if (r.id != id) return r;
      return r.copyWith(title: title.trim(), displayTime: displayTime.trim());
    }).toList();
    await _persist();
    notifyListeners();
  }

  // ---------------- SHOPPING ----------------
  Future<void> toggleShopping(String id) async {
    shoppingItems = shoppingItems
        .map((s) => s.id == id ? s.copyWith(completed: !s.completed) : s)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> addShoppingItem(String item, {String category = 'General'}) async {
    final created = ShoppingItemModel(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      item: item.trim(),
      category: category,
    );
    shoppingItems = [created, ...shoppingItems];
    await _persist();
    notifyListeners();
    _api.post('/shopping', {'item': created.item, 'category': category});
  }

  Future<void> deleteShoppingItem(String id) async {
    shoppingItems = shoppingItems.where((s) => s.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> editShoppingItem(String id, {required String item, required String category}) async {
    shoppingItems = shoppingItems
        .map((s) => s.id == id ? s.copyWith(item: item.trim(), category: category) : s)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clearBoughtShopping() async {
    shoppingItems = shoppingItems.where((s) => !s.completed).toList();
    await _persist();
    notifyListeners();
  }

  // ---------------- MEMORIES & KEEP FOR LATER ----------------
  Future<void> addMemory(String title, String content, {String category = 'preferences', String subtitle = 'Saved by you'}) async {
    final iconKind = category == 'dates'
        ? 'calendar'
        : category == 'people'
            ? 'user'
            : 'note';
    final created = MemoryModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      content: content.trim(),
      subtitle: subtitle,
      category: category,
      iconKind: iconKind,
    );
    memories = [created, ...memories];
    await _persist();
    notifyListeners();
    _api.post('/memories', {
      'title': created.title,
      'content': created.content,
      'category': category,
      'subtitle': subtitle,
    });
  }

  Future<void> deleteMemory(String id) async {
    memories = memories.where((m) => m.id != id).toList();
    await _persist();
    notifyListeners();
    _api.delete('/memories/$id');
  }

  Future<void> editMemory(
    String id, {
    required String title,
    required String content,
    required String category,
    required String subtitle,
  }) async {
    final iconKind = category == 'dates'
        ? 'calendar'
        : category == 'people'
            ? 'user'
            : 'note';
    memories = memories.map((m) {
      if (m.id != id) return m;
      return MemoryModel(
        id: m.id,
        title: title.trim(),
        content: content.trim(),
        subtitle: subtitle.trim().isEmpty ? 'Saved by you' : subtitle.trim(),
        category: category,
        iconKind: iconKind,
      );
    }).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clearAllMemories() async {
    memories = [];
    await _persist();
    notifyListeners();
    _api.delete('/user/memories');
  }

  Future<void> addKeepForLater(String title) async {
    final created = KeepForLaterModel(
      id: 'k_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      capturedLabel: 'Today · Just now',
    );
    keepForLaterItems = [created, ...keepForLaterItems];
    await _persist();
    notifyListeners();
  }

  Future<void> deleteKeepForLater(String id) async {
    keepForLaterItems = keepForLaterItems.where((k) => k.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> moveKeepToMemories(String id) async {
    final item = keepForLaterItems.firstWhere((e) => e.id == id);
    keepForLaterItems = keepForLaterItems.where((e) => e.id != id).toList();
    await addMemory(item.title, item.title, category: 'preferences', subtitle: 'Moved from Keep for later');
  }

  // ---------------- GOALS & AFFIRMATIONS ----------------
  Future<void> incrementGoal(String id) async {
    goals = goals.map((g) {
      if (g.id != id) return g;
      final next = (g.currentValue + 1).clamp(0, g.targetValue);
      return g.copyWith(currentValue: next);
    }).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    goals = goals.where((g) => g.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> addGoal(String title, int target, String unitLabel, {String period = 'week'}) async {
    final created = GoalModel(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      currentValue: 0,
      targetValue: target,
      unitLabel: unitLabel,
      period: period,
    );
    goals = [...goals, created];
    await _persist();
    notifyListeners();
  }

  Future<void> addAffirmation(String quote) async {
    final formatted = quote.startsWith('“') ? quote : '“${quote.trim()}”';
    affirmations = [
      AffirmationModel(
        id: 'a_${DateTime.now().millisecondsSinceEpoch}',
        quote: formatted,
        savedLabel: _formattedSavedDate(),
      ),
      ...affirmations,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> editAffirmation(String id, String quote) async {
    final formatted = quote.startsWith('“') ? quote : '“${quote.trim()}”';
    affirmations = affirmations.map((a) {
      if (a.id != id) return a;
      return AffirmationModel(id: a.id, quote: formatted, savedLabel: a.savedLabel);
    }).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteAffirmation(String id) async {
    affirmations = affirmations.where((a) => a.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> scheduleAffirmationReminder(String label) async {
    affirmationReminderLabel = label;
    await addReminder('Revisit affirmations', displayTime: label);
    await _persist();
    notifyListeners();
  }

  String _formattedSavedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return 'Saved ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // ---------------- AI ASSISTANT, VOICE & BRAIN DUMP ----------------
  Future<void> sendChatMessage(String text, {bool speakReply = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    chatMessages = [
      ...chatMessages,
      ChatMessageModel(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        isUser: true,
        text: trimmed,
      ),
    ];
    isAiThinking = true;
    notifyListeners();

    final remote = backendConnected
        ? await _api.post('/ai/chat', {
            'message': trimmed,
            'require_confirm': true,
          })
        : null;

    if (remote != null && remote['message'] != null) {
      final msgMap = Map<String, dynamic>.from(remote['message'] as Map);
      final pa = msgMap['pending_action'] != null
          ? ChatPendingAction.fromJson(Map<String, dynamic>.from(msgMap['pending_action'] as Map))
          : null;
      final replyText = msgMap['content']?.toString() ?? 'Done.';
      chatMessages = [
        ...chatMessages,
        ChatMessageModel(
          id: msgMap['id']?.toString() ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
          isUser: false,
          text: replyText,
          pendingAction: pa,
        ),
      ];
      user = user.copyWith(
        monthlyActionsUsed: user.monthlyActionsUsed + 1,
        aiCredits: (user.aiCredits - 1).clamp(0, 9999),
      );
      isAiThinking = false;
      await _persist();
      notifyListeners();
      if (speakReply) await _voice.speak(replyText);
      return;
    }

    // Smart local assistant fallback when offline or backend not started yet
    final lower = trimmed.toLowerCase();
    String replyText;
    ChatPendingAction? pending;

    if (lower.contains('forgetting') || lower.contains('bhool')) {
      replyText = buildWhatAmIForgettingSummary();
    } else if (lower.contains('due today') || lower.contains('today')) {
      replyText =
          'You have $pendingTodayTasksCount tasks due today, $upcomingRemindersCount upcoming reminders, and $pendingShoppingCount items on your shopping list.';
    } else if (lower.contains('shopping') ||
        lower.contains('eggs') ||
        lower.contains('milk') ||
        lower.contains('rice') ||
        lower.contains('coffee') ||
        lower.contains('banana')) {
      final cleaned = trimmed
          .replaceAll(RegExp(r'^(add|buy|get|need)\s+', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+to\s+(my\s+)?shopping.*$', caseSensitive: false), '');
      final parts = cleaned
          .split(RegExp(r',|\band\b|\baur\b', caseSensitive: false))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      for (final p in parts) {
        final cap = p[0].toUpperCase() + p.substring(1);
        await addShoppingItem(cap, category: 'General');
      }
      replyText = parts.isEmpty
          ? 'Added to your shopping list.'
          : 'Done. I’ve added ${parts.join(', ')} to your shopping list.';
    } else if (lower.contains('birthday') || lower.contains('remember')) {
      final note = trimmed.replaceAll(RegExp(r'^(remember that|remember)\s*', caseSensitive: false), '');
      await addMemory(note, note, category: lower.contains('birthday') ? 'dates' : 'preferences');
      replyText = 'Got it. I’ll remember that.';
    } else if (lower.contains('remind') || lower.contains('call') || lower.contains('meeting')) {
      final cleanedTitle = trimmed
          .replaceAll(RegExp(r'^(remind me to|please remind me to)\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+(tomorrow|today|at \d+.*)$', caseSensitive: false), '')
          .trim();
      final title = cleanedTitle.isEmpty
          ? 'Follow up reminder'
          : cleanedTitle[0].toUpperCase() + cleanedTitle.substring(1);
      pending = ChatPendingAction(
        type: 'create_reminder',
        title: title,
        displayTime: lower.contains('today') ? 'Today · 5:00 PM' : 'Tomorrow · 5:00 PM',
        timezone: user.timezone,
      );
      replyText = 'I can set that up. Here’s what I understood:';
    } else {
      await addTask(trimmed);
      replyText = 'Done. Added "$trimmed" to your tasks.';
    }

    chatMessages = [
      ...chatMessages,
      ChatMessageModel(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: replyText,
        pendingAction: pending,
      ),
    ];
    user = user.copyWith(
      monthlyActionsUsed: user.monthlyActionsUsed + 1,
      aiCredits: (user.aiCredits - 1).clamp(0, 9999),
    );
    isAiThinking = false;
    await _persist();
    notifyListeners();
    if (speakReply) await _voice.speak(replyText);
  }

  void updatePendingChatAction(
    String messageId, {
    required String title,
    required String displayTime,
  }) {
    chatMessages = chatMessages.map((m) {
      if (m.id == messageId && m.pendingAction != null) {
        return m.copyWith(
          pendingAction: m.pendingAction!.copyWith(
            title: title.trim(),
            displayTime: displayTime.trim(),
          ),
        );
      }
      return m;
    }).toList();
    _persist();
    notifyListeners();
  }

  Future<void> clearChat() async {
    chatMessages = [];
    await _persist();
    notifyListeners();
  }

  Future<void> confirmPendingChatAction(String messageId) async {
    ChatPendingAction? actionToSave;
    chatMessages = chatMessages.map((m) {
      if (m.id == messageId && m.pendingAction != null && !m.pendingAction!.confirmed) {
        actionToSave = m.pendingAction!.copyWith(confirmed: true);
        return m.copyWith(pendingAction: actionToSave);
      }
      return m;
    }).toList();

    if (actionToSave != null) {
      await addReminder(actionToSave!.title, displayTime: actionToSave!.displayTime);
      chatMessages = [
        ...chatMessages,
        ChatMessageModel(
          id: 'ai_conf_${DateTime.now().millisecondsSinceEpoch}',
          isUser: false,
          text: 'Done. I’ve confirmed "${actionToSave!.title}" for ${actionToSave!.displayTime}.',
        ),
      ];
      await _persist();
      notifyListeners();
    }
  }

  Future<void> processVoiceBrainDump(String transcript) async {
    lastBrainDumpTranscript = transcript;
    final remote = backendConnected
        ? await _api.post('/ai/brain-dump', {'transcript': transcript})
        : null;
    if (remote != null) {
      final list = <BrainDumpDraftItem>[];
      for (final t in (remote['tasks'] as List? ?? const [])) {
        list.add(BrainDumpDraftItem(
          id: t['id'].toString(),
          kind: 'task',
          title: t['title'].toString(),
          subtitle: t['subtitle']?.toString() ?? 'Tomorrow',
        ));
      }
      for (final r in (remote['reminders'] as List? ?? const [])) {
        list.add(BrainDumpDraftItem(
          id: r['id'].toString(),
          kind: 'reminder',
          title: r['title'].toString(),
          subtitle: r['subtitle']?.toString() ?? 'Tomorrow at 5:00 PM',
        ));
      }
      for (final s in (remote['shopping'] as List? ?? const [])) {
        list.add(BrainDumpDraftItem(
          id: s['id'].toString(),
          kind: 'shopping',
          title: s['title'].toString(),
          subtitle: s['subtitle']?.toString() ?? 'General',
        ));
      }
      if (list.isNotEmpty) {
        brainDumpDrafts = list;
        notifyListeners();
        return;
      }
    }

    // Local intelligent brain dump parser
    final parts = transcript
        .split(RegExp(r'[,.;\n]+|\band\b|\baur\b', caseSensitive: false))
        .map((e) => e.trim())
        .where((e) => e.length > 2)
        .toList();
    final extracted = <BrainDumpDraftItem>[];
    int idx = 0;
    for (final p in parts) {
      final lower = p.toLowerCase();
      idx++;
      if (RegExp(r'call|remind|meeting|appointment').hasMatch(lower)) {
        extracted.add(BrainDumpDraftItem(
          id: 'bd_$idx',
          kind: 'reminder',
          title: p[0].toUpperCase() + p.substring(1),
          subtitle: lower.contains('tomorrow') ? 'Tomorrow at 5:00 PM' : 'Upcoming reminder',
        ));
      } else if (RegExp(r'eggs|bread|milk|detergent|toothpaste|buy|grocer').hasMatch(lower)) {
        final clean = p.replaceAll(RegExp(r'^(buy|get|need)\s+', caseSensitive: false), '').trim();
        extracted.add(BrainDumpDraftItem(
          id: 'bd_$idx',
          kind: 'shopping',
          title: clean[0].toUpperCase() + clean.substring(1),
          subtitle: 'Shopping',
        ));
      } else {
        extracted.add(BrainDumpDraftItem(
          id: 'bd_$idx',
          kind: 'task',
          title: p[0].toUpperCase() + p.substring(1),
          subtitle: lower.contains('friday') ? 'Friday' : 'Tomorrow',
        ));
      }
    }
    if (extracted.isNotEmpty) {
      brainDumpDrafts = extracted;
      notifyListeners();
    }
  }

  void toggleBrainDumpItem(String id) {
    brainDumpDrafts = brainDumpDrafts
        .map((d) => d.id == id ? d.copyWith(selected: !d.selected) : d)
        .toList();
    notifyListeners();
  }

  void updateBrainDumpItem(String id, {required String title, required String subtitle}) {
    brainDumpDrafts = brainDumpDrafts
        .map((d) => d.id == id ? d.copyWith(title: title.trim(), subtitle: subtitle.trim()) : d)
        .toList();
    notifyListeners();
  }

  void removeBrainDumpItem(String id) {
    brainDumpDrafts = brainDumpDrafts.where((d) => d.id != id).toList();
    notifyListeners();
  }

  String buildMorningBriefingText() {
    final pendingToday = tasks.where((t) => !t.completed && t.section == 'today').toList();
    final upcomingRems = reminders.where((r) => !r.completed).toList();
    final parts = <String>[
      'Good morning ${user.fullName}. Here is your day.',
      if (pendingToday.isNotEmpty)
        'You have ${pendingToday.length} tasks due today, starting with ${pendingToday.first.title}.'
      else
        'You have no tasks due today.',
      if (upcomingRems.isNotEmpty)
        'Next reminder: ${upcomingRems.first.title} at ${upcomingRems.first.displayTime}.',
      if (pendingShoppingCount > 0)
        'There are $pendingShoppingCount items on your shopping list.',
    ];
    return parts.join(' ');
  }

  Future<int> saveSelectedBrainDumpActions() async {
    int count = 0;
    for (final item in brainDumpDrafts.where((d) => d.selected)) {
      if (item.kind == 'task') {
        await addTask(item.title, subtitle: item.subtitle, section: 'upcoming');
      } else if (item.kind == 'reminder') {
        await addReminder(item.title, displayTime: item.subtitle);
      } else if (item.kind == 'shopping') {
        await addShoppingItem(item.title, category: item.subtitle);
      } else if (item.kind == 'memory') {
        await addMemory(item.title, item.title, category: 'dates');
      }
      count++;
    }
    return count;
  }

  String buildWhatAmIForgettingSummary() {
    final pendingTasks = tasks.where((t) => !t.completed).toList();
    final upcoming = reminders.where((r) => !r.completed).toList();
    final shopCount = pendingShoppingCount;

    final highlights = <String>[];
    if (pendingTasks.isNotEmpty) {
      highlights.add('${pendingTasks.first.title} (${pendingTasks.first.subtitle})');
    }
    if (upcoming.isNotEmpty) {
      highlights.add('${upcoming.first.title} (${upcoming.first.displayTime})');
    }
    if (shopCount > 0) {
      highlights.add('$shopCount items left on your shopping list');
    }
    if (memories.isNotEmpty) {
      highlights.add(memories.first.title);
    }

    if (highlights.isEmpty) {
      return 'You have nothing overdue or forgotten right now.';
    }
    return 'You have ${highlights.length} things you might want to handle: ${highlights.take(3).join(', ')}.';
  }

  // ---------------- PHASE 2 ----------------
  Future<void> setMonthlyBudgetLimit(int limit) async {
    monthlyBudgetLimit = limit.clamp(1000, 10000000);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    expenses = expenses.where((e) => e.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> addExpense(String title, int amount, String category) async {
    expenses = [
      ExpenseModel(
        id: 'e_${DateTime.now().millisecondsSinceEpoch}',
        category: category,
        title: title,
        amount: amount,
      ),
      ...expenses,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> updateEmailReportPrefs({
    bool? enabled,
    bool? weekly,
    bool? monthly,
  }) async {
    emailReportsEnabled = enabled ?? emailReportsEnabled;
    weeklyEmailSummary = weekly ?? weeklyEmailSummary;
    monthlyEmailReview = monthly ?? monthlyEmailReview;
    await _persist();
    notifyListeners();
  }

  String exportAllDataJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'exported_at': DateTime.now().toIso8601String(),
      'user': user.toJson(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((e) => e.toJson()).toList(),
      'shopping_items': shoppingItems.map((e) => e.toJson()).toList(),
      'memories': memories.map((e) => e.toJson()).toList(),
      'keep_for_later': keepForLaterItems.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'affirmations': affirmations.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> deleteAllMyData() async {
    tasks = [];
    reminders = [];
    shoppingItems = [];
    memories = [];
    keepForLaterItems = [];
    goals = [];
    affirmations = [];
    chatMessages = [];
    expenses = [];
    await _localDb.clearAll();
    await _persist();
    notifyListeners();
    _api.delete('/user/account-data');
  }
}
