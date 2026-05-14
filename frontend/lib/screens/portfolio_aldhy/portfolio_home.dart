import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortfolioHome extends StatelessWidget {
  const PortfolioHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 30, 58, 95),
                      Color(0xFF2A4A8F)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👨‍💻', style: TextStyle(fontSize: 60)),
                ),
              ),

              const SizedBox(height: 40),

              // ── Small label
              const Text(
                'FAJARDO, JOHN ALDHY',
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 158, 173, 198),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // ── Main title
              const Text(
                'Welcome to My Portfolio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 16),

              // ── Subtitle
              Text(
                'BS Information System student &\nIntern at FDS Asya Philippines, Inc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.7,
                ),
              ),

              const Spacer(),

              // ── Get to Know Me button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/portfolio-profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 35, 55, 86),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get to Know Me →',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Divider with "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.1)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── View Full Details button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/portfolio-details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Hobby tags
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['♟ Chess', '🏀 Sports', '🎵 Music']
                    .map((tag) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.5)),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
