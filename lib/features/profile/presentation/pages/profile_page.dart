import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:edurise/core/theme/app_colors.dart';
import 'package:edurise/core/widgets/safe_network_image.dart';
import 'add_course_page.dart';
import 'admin_dashboard_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
//    final size = MediaQuery.of(context).size;
    final authAsync = ref.watch(authStateProvider);
    final authActions = ref.read(authActionsProvider);

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: Column(
          children: [
            // top banner with back and title
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/profile_bg.png'),
                    fit: BoxFit.cover),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),

            // avatar positioned overlapping (shows real user data when available)
            Center(
              child: authAsync.when(
                data: (user) {
                  final displayName = user?.displayName ?? 'No name';
                  final email = user?.email;
                  final phone = user?.phoneNumber;
                  final photoUrl = user?.photoURL;
                  return Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 6))
                            ]),
                        padding: const EdgeInsets.all(6),
                        child: ClipOval(
                          child: SafeNetworkImage(
                            src: photoUrl,
                            fallbackAsset: 'assets/images/author.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(displayName,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: appPrimary)),
                      const SizedBox(height: 6),
                      if (email != null)
                        Text(email,
                            style: GoogleFonts.montserrat(
                                fontSize: 13, color: appSecondary)),
                      if (phone != null)
                        Text(phone,
                            style: GoogleFonts.montserrat(
                                fontSize: 13, color: appSecondary)),
                      const SizedBox(height: 8),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        ElevatedButton(
                            onPressed: () => authActions.signOut(),
                            child: const Text('Sign out')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () async {
                              try {
                                await authActions.pickAndUploadAvatar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Avatar updated')));
                                // refresh handled by authStateChanges after reload
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Avatar upload failed: $e')));
                              }
                            },
                            child: const Text('Change avatar')),
                        const SizedBox(width: 8),
                        // Admin panel button (visible to all users for now) + AddCoursePage
                        Row(children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboardPage(),
                                ),
                              );
                            },
                            child: const Text('Admin panel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final res = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(builder: (_) => const AddCoursePage()),
                              );
                              if (res == true) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course added')));
                              }
                            },
                            child: const Text('Add course page'),
                          ),
                        ]),
                      ])
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 6))
                          ]),
                      padding: const EdgeInsets.all(8),
                      child: ClipOval(
                          child:
                              Icon(Icons.person, size: 56, color: appPrimary)),
                    ),
                    const SizedBox(height: 18),
                    const CircularProgressIndicator(),
                  ],
                ),
                error: (e, st) => Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 6))
                          ]),
                      padding: const EdgeInsets.all(8),
                      child: ClipOval(
                          child:
                              Icon(Icons.person, size: 56, color: appPrimary)),
                    ),
                    const SizedBox(height: 18),
                    Text('Error loading user',
                        style: GoogleFonts.montserrat(color: appPrimary)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            // content: Completed Courses
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Completed Courses',
                            style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: appPrimary)),
                        Text('View All',
                            style: GoogleFonts.montserrat(
                                fontSize: 14, color: appAccentEnd)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // make list full-bleed without negative margin
                  LayoutBuilder(builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    return Transform.translate(
                      offset: const Offset(0, 0),
                      child: SizedBox(
                        width: screenWidth,
                        height: 220,
                        child: ListView.separated(
                          padding: EdgeInsets.only(left: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) =>
                              _ProfileCourseCard(index: index),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 18),
                  // additional spacing or other profile sections could go here
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool debugModeCheck({required dynamic user}) {
  if (user == null) return false;
  try {
    final email = (user.email ?? '').toString();
    if (email == 'admin@local' || email.endsWith('@example.com')) return true;
  } catch (_) {}
  return false;
}

class _ProfileCourseCard extends StatelessWidget {
  final int index;
  const _ProfileCourseCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final grads = [
      [const Color(0xffFFAC71), const Color(0xffFF8450)],
      [const Color(0xFF6C5CFF), const Color(0xFF5043FF)],
      [const Color(0xFF00C7B7), const Color(0xFF00A899)],
      [const Color(0xFFFFA76B), const Color(0xFFFF7A3D)],
    ];
    final grad = grads[index % grads.length];
    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: grad.last.withAlpha(51),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          // image placeholder top-right
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
          child: Align(
          alignment: Alignment.topRight,
          child: Image.asset('assets/images/card-${(index % 2) + 1}.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
              const FlutterLogo(size: 88))),
            ),
          ),
          // play button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.white.withAlpha(204), shape: BoxShape.circle),
              child: Icon(Icons.play_arrow, color: appPrimary),
            ),
          ),
          // title and author
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find Powerful Tips for\nWealth & Success',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 8),
                Row(children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage('assets/images/author.png')),
                  const SizedBox(width: 8),
                  Text('Kunal Shah',
                      style: GoogleFonts.montserrat(color: Colors.white))
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
