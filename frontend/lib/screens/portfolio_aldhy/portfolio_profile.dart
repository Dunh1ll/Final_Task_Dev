import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortfolioProfile extends StatelessWidget {
  const PortfolioProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  // Avatar small
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF3B82F6), width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'FA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar + Name
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Avatar circle
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2A2A3E),
                                  border: Border.all(
                                    color: const Color(0xFF3B82F6),
                                    width: 3,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'FA',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ),
                              // Online dot
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1A1A1A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Fajardo, Aldhy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'aldhy@main.com',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // View Full Details button
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () =>
                                  context.push('/portfolio-details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'View Full Details →',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Quick Info section label
                    Text(
                      'QUICK INFO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Info rows
                    _infoRow('🎓', const Color(0xFF1E3A5F), 'Education',
                        'BS Information System · 4th Year'),
                    _infoRow('💼', const Color(0xFF1E5F1E), 'Work',
                        'Intern · FDS Asya Philippines'),
                    _infoRow('📍', const Color(0xFF5F3A1E), 'Location',
                        'Laguna, Philippines'),
                    _infoRow('🏆', const Color(0xFF3A1E5F), 'Status',
                        'Currently in Development Unit.'),

                    const SizedBox(height: 28),

                    // ── Hobbies section label
                    Text(
                      'HOBBIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Hobby chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        '♟ Chess',
                        '🏀 Basketball',
                        '🎵 Music',
                        '🎬 Movies',
                        '🍃 Nature',
                      ]
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Bottom nav
            _buildBottomNav(context, 2),
          ],
        ),
      ),
    );
  }

  // ── Info row widget
  Widget _infoRow(String icon, Color bgColor, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bottom navigation bar
Widget _buildBottomNav(BuildContext context, int currentPage) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      border: Border(
        top: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Home
        GestureDetector(
          onTap: () => context.go('/portfolio-home'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.home_rounded,
                color: currentPage == 1
                    ? const Color(0xFF3B82F6)
                    : Colors.white.withOpacity(0.3),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 9,
                  color: currentPage == 1
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),

        // Center button
        GestureDetector(
          onTap: () => currentPage == 1
              ? context.push('/portfolio-profile')
              : context.push('/portfolio-details'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
        ),

        // Details
        GestureDetector(
          onTap: () => context.push('/portfolio-details'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_rounded,
                color: currentPage == 3
                    ? const Color(0xFF3B82F6)
                    : Colors.white.withOpacity(0.3),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 9,
                  color: currentPage == 3
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
