import 'package:flutter/material.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/perfil_info.dart';
import '../models/dades_usr.dart';
import 'perfil_edit_page.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import '../models/url.dart';
import '../../models/avatar_stack.dart';
import 'avatar_editor_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/avatar_user.dart';
import '../../widgets/centered_message.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/services/notification_service.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();
    final l10n = AppLocalizations.of(context)!;
    final plantProvider = context.watch<PlantProvider>();
    final plantsDiscovered = plantProvider.plants.length;

    return Scaffold(
      key: const Key('profile_page'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.green.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _GameHeader(
                    username: user.username,
                    email: user.email,
                    city: user.city,
                    language: user.language,
                    coins: user.monedes,
                    plantsDiscovered: plantsDiscovered,
                    onEdit: () async {
                      final profile = PerfilInfo(
                        username: user.username,
                        email: user.email,
                        city: user.city,
                        language: user.language,
                        coins: user.monedes,
                        plantsDiscovered: plantsDiscovered,
                      );

                      final updatedLanguage = await Navigator.of(context)
                          .push<String?>(
                            MaterialPageRoute(
                              builder: (_) => PerfilEditPage(profile: profile),
                            ),
                          );

                      if (updatedLanguage != null && context.mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;

                          final updatedL10n = AppLocalizations.of(context)!;

                          CenteredMessage.show(
                            context,
                            updatedL10n.profileEditUpdated,
                            type: CenteredMessageType.success,
                          );
                        });
                      }
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SectionTitle(
                        icon: Icons.bar_chart_rounded,
                        title: l10n.profileStatsTitle,
                      ),
                      const SizedBox(height: 12),
                      _StatsGrid(
                        coins: user.monedes,
                        plantsDiscovered: plantsDiscovered,
                      ),
                      const SizedBox(height: 24),
                      const _ActionButtons(),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  final String username;
  final String email;
  final String city;
  final String language;
  final int coins;
  final int plantsDiscovered;
  final VoidCallback onEdit;

  const _GameHeader({
    required this.username,
    required this.email,
    required this.city,
    required this.language,
    required this.coins,
    required this.plantsDiscovered,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = username.isEmpty ? l10n.profileDefaultUser : username;
    final displayCity = city.isEmpty ? l10n.profileCityNotDefined : city;
    final displayEmail = email.isEmpty ? '—' : email;
    final displayLanguage = language.isEmpty ? '—' : language;
    final avatar = Provider.of<AvatarUser>(context);
    debugPrint(avatar.body.toString());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E6B48), Color(0xFF355F3F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // --- CÍRCULO DEL AVATAR CLICKABLE ---
                      GestureDetector(
                        key: const Key('edit_avatar_button'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AvatarEditorPage(isNewUser: false),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // círculo con el AvatarStack actual
                            Container(
                              height: 74,
                              width: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: AvatarStack(
                                  body: avatar.body,
                                  eye: avatar.eye,
                                  expression: avatar.expression,
                                  hair: avatar.hair,
                                  facialHair: avatar.facialHair,
                                  clothing: avatar.clothing,
                                  accessories: avatar.accessories,
                                ),
                              ),
                            ),
                            // Icono de edición flotante
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Fondo blanco para que destaque
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Color(
                                  0xFF3E6B48,
                                ), // Tu color verde oscuro
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    displayCity,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Column(
                      children: [
                        _HeaderInfoRow(
                          icon: Icons.person_rounded,
                          label: l10n.profileUserLabel,
                          value: displayName,
                        ),
                        const SizedBox(height: 12),
                        _HeaderInfoRow(
                          icon: Icons.email_rounded,
                          label: l10n.profileEmailLabel,
                          value: displayEmail,
                        ),
                        const SizedBox(height: 12),
                        _HeaderInfoRow(
                          icon: Icons.location_city_rounded,
                          label: l10n.profileCityLabel,
                          value: displayCity,
                        ),
                        const SizedBox(height: 12),
                        _HeaderInfoRow(
                          icon: Icons.language_rounded,
                          label: l10n.profileLanguageLabel,
                          value: displayLanguage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('edit_profile_button'),
                      onPressed: onEdit,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF166534),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.edit_rounded),
                      label: Text(
                        l10n.profileEditButton,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF166534)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1f2937),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int coins;
  final int plantsDiscovered;

  const _StatsGrid({required this.coins, required this.plantsDiscovered});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _GameStatCard(
            icon: Icons.monetization_on_rounded,
            title: l10n.profileCoins,
            value: coins.toString(),
            accent: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GameStatCard(
            icon: Icons.photo_camera_rounded,
            title: l10n.profilePlants,
            value: plantsDiscovered.toString(),
            accent: const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }
}

class _GameStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  const _GameStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.07),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.62),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();
  final storage = const FlutterSecureStorage();

  Future<void> _logout(BuildContext context) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final userToken = userModel.token;

    await NotificationService.deleteTokenFromBackend(userToken);

    if (!context.mounted) return;

    userModel.logout();
    await storage.delete(key: 'auth_token');

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text(l10n.profileDeleteAccountTitle),
          ],
        ),
        content: Text(l10n.profileDeleteAccountMessage),
        actions: [
          TextButton(
            key: const Key('delete_account_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.commonCancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            key: const Key('delete_account_confirm_button'),
            onPressed: () async {
              final user = Provider.of<UserModel>(context, listen: false);
              final token = user.token;
              Navigator.of(ctx).pop();

              final response = await http.delete(
                Uri.parse('${ApiConfig.baseUrl}/api/delete_profile/'),
                headers: {"Authorization": "Token $token"},
              );

              if (!context.mounted) return;

              if (response.statusCode == 200) {
                final userModel = Provider.of<UserModel>(
                  context,
                  listen: false,
                );

                await NotificationService.deleteTokenFromBackend(token);

                if (!context.mounted) return;

                userModel.logout();
                await storage.delete(key: 'auth_token');

                if (!context.mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.profileDeleteAccountError)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            child: Text(l10n.profileDeleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          key: const Key('logout_button'),
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout, size: 20),
          label: Text(
            l10n.profileLogout,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          key: const Key('delete_account_button'),
          onPressed: () => _confirmDeleteAccount(context),
          icon: const Icon(Icons.delete_forever, size: 20),
          label: Text(
            l10n.profileDeleteAccountTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade400,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
