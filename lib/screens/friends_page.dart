import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/app_localizations.dart';
import '../models/dades_usr.dart';
import '../services/amics_service.dart';
import '../../models/avatar_stack.dart';
import 'friend_garden_page.dart';
import '../widgets/centered_message.dart';


const Color _pageBackground = Color(0xFFF5F9F0);
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _darkGreen = Color(0xFF2E7D32);
const Color _deepGreen = Color(0xFF1B5E20);
const Color _cardWhite = Colors.white;

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  final AmicsService _amicsService = AmicsService();
  late TabController _tabController;

  List<Map<String, dynamic>> _friends = [];
  List<String> _sentRequests = [];
  List<String> _receivedRequests = [];
  bool _loading = true;
  String? _error;
  final Map<String, Map<String, dynamic>?> _avatarCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
  final token = Provider.of<UserModel>(context, listen: false).token;

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final results = await Future.wait([
      _amicsService.fetchFriends(token: token),
      _amicsService.fetchFriendRequests(action: 'sent', token: token),
      _amicsService.fetchFriendRequests(action: 'received', token: token),
    ]);

    final friends = results[0] as List<Map<String, dynamic>>;
    final sentRequests = results[1] as List<String>;
    final receivedRequests = results[2] as List<String>;

    final usernames = <String>{};

    for (final friend in friends) {
      final username = friend['username'] as String?;
      if (username != null && username.isNotEmpty) {
        usernames.add(username);
      }
    }

    usernames.addAll(sentRequests);
    usernames.addAll(receivedRequests);

    await Future.wait(
      usernames.map((username) async {
        if (!_avatarCache.containsKey(username)) {
          _avatarCache[username] = await _amicsService.fetchAvatar(
            username: username,
            token: token,
          );
        }
      }),
    );

    if (!mounted) return;

    setState(() {
      _friends = friends;
      _sentRequests = sentRequests;
      _receivedRequests = receivedRequests;
      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
    });
  }
}

  void _openAddFriendSheet() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: _AddFriendSheet(
          amicsService: _amicsService,
          onRequestSent: _loadAll,
        ),
      ),
    );
  }

  Future<void> _answerRequest(String requester, String action) async {
    final token = Provider.of<UserModel>(context, listen: false).token;
    try {
      final msg = await _amicsService.answerFriendRequest(
        requesterUsername: requester,
        action: action,
        token: token,
      );
      if (!mounted) return;
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      CenteredMessage.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        type: CenteredMessageType.error,
      );
    }
  }

  Future<void> _cancelRequest(String requested) async {
    final token = Provider.of<UserModel>(context, listen: false).token;

    try {
      final msg = await _amicsService.cancelFriendRequest(
        requestedUsername: requested,
        token: token,
      );
      if (!mounted) return;
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      CenteredMessage.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        type: CenteredMessageType.error,
      );
    }
  }

  Future<void> _confirmDeleteFriend(String username) async {
    final t = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.person_remove_rounded,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.deleteFriendTitle,
                style: const TextStyle(
                  color: _deepGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          t.deleteFriendMessage(username),
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 14,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              t.cancel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(
              t.delete,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteFriend(username);
    }
  }

  Future<void> _deleteFriend(String username) async {
    final token = Provider.of<UserModel>(context, listen: false).token;

    try {
      final msg = await _amicsService.deleteFriend(
        username: username,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _friends.removeWhere((friend) => friend['username'] == username);
        _avatarCache.remove(username);
      });

    } catch (e) {
      if (!mounted) return;
      CenteredMessage.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        type: CenteredMessageType.error,
      );
    }
  }

  void _openFriendGarden(Map<String, dynamic> friend) {
  final username = friend['username'] as String;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FriendGardenPage(
        friendUsername: username,
        gardenName: friend['garden_name'] as String? ?? username,
        avatarParts: _avatarCache[username],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: _pageBackground),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.76),
                    _pageBackground.withValues(alpha: 0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final t = AppLocalizations.of(context)!;
    final totalRequests = _sentRequests.length + _receivedRequests.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 28,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.eco,
                            color: _primaryGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MeteoGarden',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.friends,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _deepGreen,
                      ),
                    ),
                    if (!_loading && _error == null)
                      Text(
                        totalRequests == 0
                            ? t.friendsCount(_friends.length)
                            : t.friendsCountWithRequests(
                                _friends.length,
                                totalRequests,
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: _primaryGreen,
                ),
                tooltip: t.sendFriendRequestTooltip,
                onPressed: _openAddFriendSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
  final t = AppLocalizations.of(context)!;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: _primaryGreen,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              _FriendTab(
                icon: Icons.people_alt_rounded,
                label: t.friends,
                selected: _tabController.index == 0,
              ),
              _FriendTab(
                icon: Icons.outbox_rounded,
                label: t.sent,
                count: _sentRequests.length,
                selected: _tabController.index == 1,
              ),
              _FriendTab(
                icon: Icons.mark_email_unread_rounded,
                label: t.received,
                count: _receivedRequests.length,
                selected: _tabController.index == 2,
              ),
            ],
          );
        },
      ),
    ),
  );
}

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryGreen),
      );
    }

    if (_error != null) {
      return _ErrorView(error: _error!, onRetry: _loadAll);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildFriendsList(),
        _buildSentList(),
        _buildReceivedList(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB: AMICS
  // ---------------------------------------------------------------------------

  Widget _buildFriendsList() {
  final t = AppLocalizations.of(context)!;

  if (_friends.isEmpty) {
    return _EmptyState(
      icon: Icons.people_outline,
      message: t.noFriendsYet,
    );
  }

  return RefreshIndicator(
    color: const Color(0xFF388E3C),
    onRefresh: _loadAll,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _friends.length,
      itemBuilder: (context, i) {
        final friend = _friends[i];
        final username = friend['username'] as String;

        return _FriendTile(
          username: username,
          avatarParts: _avatarCache[username],
          onTap: () => _openFriendGarden(friend),
          onDelete: () => _confirmDeleteFriend(username),
        );
      },
    ),
  );
}

  // ---------------------------------------------------------------------------
  // TAB: ENVIADES
  // ---------------------------------------------------------------------------

  Widget _buildSentList() {
  final t = AppLocalizations.of(context)!;

  if (_sentRequests.isEmpty) {
    return _EmptyState(
      icon: Icons.send_outlined,
      message: t.noSentRequests,
    );
  }

  return RefreshIndicator(
    color: const Color(0xFF388E3C),
    onRefresh: _loadAll,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _sentRequests.length,
      itemBuilder: (context, i) {
        final username = _sentRequests[i];

        return _RequestTile(
          username: username,
          avatarParts: _avatarCache[username],
          trailing: TextButton.icon(
            onPressed: () => _cancelRequest(username),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: Text(t.cancel),
            style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
          ),
        );
      },
    ),
  );
}

  // ---------------------------------------------------------------------------
  // TAB: REBUDES
  // ---------------------------------------------------------------------------

  Widget _buildReceivedList() {
  final t = AppLocalizations.of(context)!;

  if (_receivedRequests.isEmpty) {
    return _EmptyState(
      icon: Icons.inbox_outlined,
      message: t.noReceivedRequests,
    );
  }

  return RefreshIndicator(
    color: const Color(0xFF388E3C),
    onRefresh: _loadAll,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, i) {
        final username = _receivedRequests[i];

        return _RequestTile(
          username: username,
          avatarParts: _avatarCache[username],
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: const Color(0xFF388E3C),
                tooltip: t.accept,
                onPressed: () => _answerRequest(username, 'accept'),
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                color: Colors.red[400],
                tooltip: t.reject,
                onPressed: () => _answerRequest(username, 'reject'),
              ),
            ],
          ),
        );
      },
    ),
  );
}
}

// =============================================================================
// BOTTOM SHEET: AFEGIR AMIC
// =============================================================================

class _AddFriendSheet extends StatefulWidget {
  final AmicsService amicsService;
  final VoidCallback onRequestSent;

  const _AddFriendSheet({
    required this.amicsService,
    required this.onRequestSent,
  });

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  // Caché d'avatars: username → parts de l'avatar (o null si no en té)
  final Map<String, Map<String, dynamic>?> _avatarCache = {};
  bool _searching = false;
  String? _resultMessage;
  bool _resultSuccess = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final userModel = Provider.of<UserModel>(context, listen: false);
    final token = userModel.token;
    final currentUsername = userModel.username;
    setState(() => _searching = true);
    try {
      final results = await widget.amicsService.searchUsers(
        query: query.trim(),
        token: token,
      );

      final filteredResults = results.where((user) {
        final username = user['username'] as String? ?? '';
        return username.toLowerCase() != currentUsername.toLowerCase();
      }).toList();

      // Carreguem els avatars de cada resultat en paral·lel
      final avatarFutures = filteredResults.map((user) async {
        final username = user['username'] as String;
        if (!_avatarCache.containsKey(username)) {
          _avatarCache[username] = await widget.amicsService.fetchAvatar(
            username: username,
            token: token,
          );
        }
      });
      await Future.wait(avatarFutures);

      setState(() {
        _searchResults = filteredResults;
        _searching = false;
      });
    } catch (_) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
    }
  }

  Future<void> _sendRequest(String username) async {
  final t = AppLocalizations.of(context)!;
  final token = Provider.of<UserModel>(context, listen: false).token;

  setState(() {
    _resultMessage = null;
  });

  try {
    final msg = await widget.amicsService.sendFriendRequest(
      requestedUsername: username,
      token: token,
    );

    if (!mounted) return;

    setState(() {
      _resultMessage =
          msg.isNotEmpty ? msg : t.friendRequestSentSuccessfully;
      _resultSuccess = true;
    });

    widget.onRequestSent();
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _resultMessage = e.toString().replaceFirst('Exception: ', '');
      _resultSuccess = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.70),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: _primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: _primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.addFriend,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _deepGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.addFriendSubtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey,
                          tooltip: t.close,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F9F0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _primaryGreen.withValues(alpha: 0.12),
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: t.usernameHint,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: _primaryGreen),
                          ),
                        ),
                        onChanged: _search,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_searching)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: CircularProgressIndicator(color: _primaryGreen),
                        ),
                      ),
                    if (_resultMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _resultSuccess
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _resultSuccess
                                ? _primaryGreen
                                : Colors.red[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _resultSuccess
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: _resultSuccess
                                  ? _darkGreen
                                  : Colors.red[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _resultMessage!,
                                style: TextStyle(
                                  color: _resultSuccess
                                      ? _darkGreen
                                      : Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_searchResults.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final user = _searchResults[i];
                            final username = user['username'] as String;
                            final avatarParts = _avatarCache[username];

                            return _SearchResultTile(
                              username: username,
                              avatarParts: avatarParts,
                              onSend: () => _sendRequest(username),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGETS AUXILIARS
// =============================================================================

class _AvatarCircle extends StatelessWidget {
  final String username;
  final Map<String, dynamic>? avatarParts;
  final double size;

  const _AvatarCircle({
    required this.username,
    required this.avatarParts,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarParts != null
            ? AvatarStack(
                body: avatarParts!['body'] as String? ?? '',
                eye: avatarParts!['eye'] as String? ?? '',
                expression: avatarParts!['expression'] as String? ?? '',
                hair: avatarParts!['hair'] as String? ?? '',
                facialHair: avatarParts!['facialHair'] as String? ?? '',
                clothing: avatarParts!['clothing'] as String? ?? '',
                accessories: avatarParts!['accessories'] as String? ?? '',
              )
            : Center(
                child: Text(
                  username.isEmpty ? '?' : username[0].toUpperCase(),
                  style: const TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final String username;
  final Map<String, dynamic>? avatarParts;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FriendTile({
    required this.username,
    required this.avatarParts,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: _cardWhite.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _AvatarCircle(username: username, avatarParts: avatarParts),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  t.visitGarden,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  tooltip: t.friendOptions,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_remove_rounded,
                              color: Colors.red[700],
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            t.deleteFriend,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String username;
  final Map<String, dynamic>? avatarParts;
  final Widget trailing;

  const _RequestTile({
    required this.username,
    required this.avatarParts,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardWhite.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _AvatarCircle(username: username, avatarParts: avatarParts),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final String username;
  final Map<String, dynamic>? avatarParts;
  final VoidCallback onSend;

  const _SearchResultTile({
    required this.username,
    required this.avatarParts,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          _AvatarCircle(username: username, avatarParts: avatarParts, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          FilledButton(
            onPressed: onSend,
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              t.sendRequest,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final bool selected;

  const _Badge({
    required this.count,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? Colors.white : _primaryGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: selected ? _primaryGreen : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FriendTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;

  const _FriendTab({
    required this.icon,
    required this.label,
    this.count = 0,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 4),
              _Badge(
                count: count,
                selected: selected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: _primaryGreen),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(t.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
