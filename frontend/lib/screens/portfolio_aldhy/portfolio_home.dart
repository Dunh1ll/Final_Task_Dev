import 'package:flutter/material.dart';

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Row(
        children: [
          // ── Left Sidebar
          Container(
            width: 260,
            height: double.infinity,
            color: const Color(0xFF111111),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // ── Profile picture
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile3.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Name
                  const Text(
                    'Fajardo, Aldhy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // ── Role badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Intern Student',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Divider
                  Divider(color: Colors.white.withOpacity(0.1)),

                  const SizedBox(height: 16),

                  // ── Contact Info
                  _contactRow(Icons.email, 'EMAIL', 'aldhy@main.com'),
                  _contactRow(Icons.phone, 'PHONE', '+63 9759488949'),
                  _contactRow(
                      Icons.location_on, 'LOCATION', 'Laguna, Philippines'),
                  _contactRow(
                      Icons.school, 'EDUCATION', 'BS Information System'),
                  _contactRow(Icons.work, 'WORK', 'FDS Asya Philippines, Inc'),
                  _contactRow(Icons.cake, 'AGE', '22'),
                  _contactRow(Icons.people, 'STATUS', 'Single'),
                ],
              ),
            ),
          ),

          // ── Right Content
          Expanded(
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Text(
                  'Content',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact row helper
  Widget _contactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 14,
            ),
          ),

          const SizedBox(width: 12),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
