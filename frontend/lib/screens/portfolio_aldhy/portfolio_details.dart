import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortfolioDetails extends StatefulWidget {
  const PortfolioDetails({super.key});

  @override
  State<PortfolioDetails> createState() => _PortfolioDetailsState();
}

class _PortfolioDetailsState extends State<PortfolioDetails> {
  // ── Tracks which row is expanded
  String? _expanded;

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
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(12),
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
                    'Full Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  // Avatar
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

            // ── Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: Colors.white.withOpacity(0.3), size: 16),
                    const SizedBox(width: 10),
                    Text(
                      'Search details...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Scrollable list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Personal Info
                    _sectionLabel('PERSONAL INFO'),
                    _expandableRow(
                      id: 'name',
                      icon: '👤',
                      bgColor: const Color(0xFF1E3A5F),
                      label: 'Full Name',
                      value: 'Fajardo, John Aldhy',
                      detail:
                          'Born and raised in Laguna, Philippines. A 4th year BS Information System student.',
                    ),
                    _expandableRow(
                      id: 'age',
                      icon: '🎂',
                      bgColor: const Color(0xFF3A1E5F),
                      label: 'Age',
                      value: '22 years old',
                      detail: 'Born in 2003.',
                    ),
                    _expandableRow(
                      id: 'hometown',
                      icon: '📍',
                      bgColor: const Color(0xFF5F3A1E),
                      label: 'Hometown',
                      value: 'Laguna, Philippines',
                      detail:
                          'From the province of Laguna, one of the most developed provinces in the Philippines.',
                    ),
                    _expandableRow(
                      id: 'status',
                      icon: '❤️',
                      bgColor: const Color(0xFF5F1E1E),
                      label: 'Status',
                      value: 'Single',
                      detail: 'Currently focused on career and studies.',
                    ),
                    _expandableRow(
                      id: 'email',
                      icon: '📧',
                      bgColor: const Color(0xFF1E3A5F),
                      label: 'Email',
                      value: 'aldhy@main.com',
                      detail:
                          'Feel free to reach out via email for any inquiries.',
                    ),
                    _expandableRow(
                      id: 'phone',
                      icon: '📞',
                      bgColor: const Color(0xFF1E5F3A),
                      label: 'Phone',
                      value: '+63 9759488949',
                      detail: 'Available on call or text.',
                    ),

                    const SizedBox(height: 8),

                    // ── Education & Work
                    _sectionLabel('EDUCATION & WORK'),
                    _expandableRow(
                      id: 'edu',
                      icon: '🎓',
                      bgColor: const Color(0xFF1E3A5F),
                      label: 'BS Information System',
                      value: 'Card MRI Development, Inc · 4th Year',
                      detail:
                          'Currently in 4th year, focused on software development, databases, and system design.',
                    ),
                    _expandableRow(
                      id: 'work',
                      icon: '💼',
                      bgColor: const Color(0xFF1E5F1E),
                      label: 'Intern Student',
                      value: 'FDS Asya Philippines, Inc',
                      detail:
                          'Working as a full-stack intern building a profile management system using Flutter and Go with PostgreSQL.',
                    ),

                    const SizedBox(height: 8),

                    // ── Tech Skills
                    _sectionLabel('TECH SKILLS'),
                    _expandableRow(
                      id: 'skills',
                      icon: '⚡',
                      bgColor: const Color(0xFF2A1E5F),
                      label: 'Tech Stack',
                      value: 'Flutter · Go · PostgreSQL · Git',
                      detail:
                          'Flutter (75%) · Go (65%) · PostgreSQL (60%) · Git (80%) · VS Code (90%)',
                    ),

                    const SizedBox(height: 8),

                    // ── Internship Journey
                    _sectionLabel('INTERNSHIP JOURNEY'),
                    _expandableRow(
                      id: 'journey',
                      icon: '🗺️',
                      bgColor: const Color(0xFF1E5F3A),
                      label: 'Department Progress',
                      value: '4 Done · Currently in Dev',
                      detail:
                          '✓ BRM · ✓ PMO · ✓ Quality Assurance · ✓ Tech Support · ● Development (Current)',
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Bottom nav
            _buildBottomNav(context, 3),
          ],
        ),
      ),
    );
  }

  // ── Section label
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.35),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Expandable row
  Widget _expandableRow({
    required String id,
    required String icon,
    required Color bgColor,
    required String label,
    required String value,
    required String detail,
  }) {
    final isOpen = _expanded == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          // If same row tapped → close it, else open new one
          _expanded = isOpen ? null : id;
        });
      },
      child: Column(
        children: [
          // ── Row item
          Container(
            margin: EdgeInsets.only(bottom: isOpen ? 0 : 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isOpen ? 0 : 14),
                bottomRight: Radius.circular(isOpen ? 0 : 14),
              ),
              border: Border.all(
                color: isOpen
                    ? const Color(0xFF3B82F6)
                    : Colors.white.withOpacity(0.07),
              ),
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
                Expanded(
                  child: Column(
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
                ),
                // Chevron
                AnimatedRotation(
                  turns: isOpen ? 0.25 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.chevron_right,
                    color: isOpen
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // ── Expanded detail
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: isOpen
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                    ),
                    child: Text(
                      detail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.7,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Bottom nav (reused from portfolio_profile.dart)
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
        Container(
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
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
        ),
        GestureDetector(
          onTap: () => context.push('/portfolio-profile'),
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
                'Profile',
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
