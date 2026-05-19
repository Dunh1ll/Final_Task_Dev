import 'package:flutter/material.dart';

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  String _selectedTab = 'About';

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
                  const SizedBox(height: 20),

                  // ── Divider
                  Divider(color: Colors.white.withOpacity(0.1)),

                  const SizedBox(height: 16),

                  // ── Social links label
                  Text(
                    'SOCIAL LINKS',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Social icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton('G', 'GitHub'),
                      const SizedBox(width: 10),
                      _socialButton('In', 'LinkedIn'),
                      const SizedBox(width: 10),
                      _socialButton('ig', 'Instagram'),
                      const SizedBox(width: 10),
                      _socialButton('fb', 'Facebook'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Right Content
          Expanded(
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tab bar
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: ['About', 'Resume', 'Portfolio', 'Contact']
                          .map((tab) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTab = tab;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _selectedTab == tab
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _selectedTab == tab
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: _selectedTab == tab
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // ── Tab content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _buildTabContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab content switcher
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'About':
        return _buildAboutContent();
      case 'Resume':
        return _buildResumeContent();
      case 'Portfolio':
        return _buildPortfolioContent();
      case 'Contact':
        return _buildContactContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── About page content
  Widget _buildAboutContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          const Text(
            'About Me',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          // ── Underline
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 24),
            width: 40,
            height: 3,
            color: Colors.white,
          ),

          // ── Bio
          Text(
            'Hi, I\'m John Aldhy Fajardo, a 4th-year BS Information Systems student at CARD MRI Development Institute, Inc.\n\nI\'m interested in building clean and functional systems and enjoy learning new things through actual development work and team projects. I\'ve worked with technologies like Flutter, Dart, Go, PostgreSQL, Firebase, Next.js, and Node.js in both school and internship projects.\n\nRight now, I\'m an intern at FDS Asya Philippines, Inc., where I help develop collaborative system applications by working on Flutter mobile apps, Go backends, and frontend profile management features.\n\nI enjoy turning ideas into working applications, improving my skills, and gaining experience through hands-on development.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.8,
            ),
          ),

          const SizedBox(height: 32),

          // ── What I'm Doing title
          const Text(
            "What I'm Doing",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // ── Cards grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _doingCard('Flutter Development',
                  'Building collaborative systems using Flutter and Dart.'),
              _doingCard('Strategic Thinking',
                  'Applying logical and analytical thinking in every task.'),
              _doingCard('System Analysis',
                  'Analyzing and designing information systems.'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Doing card
  Widget _doingCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          const Text(
            'Resume',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          // ── Underline
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 32),
            width: 40,
            height: 3,
            color: Colors.white,
          ),

          // ── Education section
          _resumeSection(
            Icons.school,
            'Education',
            [
              _resumeItem(
                'Bachelor of Science in Information System',
                '2022 — Present',
                'Card MRI Development Institute, Inc. · Brgy. Tranca, Bay Laguna',
              ),
              _resumeItem(
                'Humanities and Social Sciences',
                '2020 — 2022',
                'Laguna State Polytechnic University · Brgy. Bubukal, Sta. Cruz, Laguna',
              ),
              _resumeItem(
                'Junior High School',
                '2016 — 2020',
                'Banca Banca Integrated National High School · Brgy. Banca-Banca Victoria, Laguna',
              ),
              _resumeItem(
                'Elementary',
                '2010 — 2016',
                'Banca Banca Elementary School · Brgy. Banca-Banca Victoria, Laguna',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Experience section
          _resumeSection(
            Icons.work,
            'Internship Journey',
            [
              _resumeItem(
                'Business Relation Management',
                'FDS Asya Philippines, Inc',
                'Handled business relations and client communications.',
              ),
              _resumeItem(
                'Project Management Office',
                'FDS Asya Philippines, Inc',
                'Assisted in project planning and documentation.',
              ),
              _resumeItem(
                'Quality Assurance',
                'FDS Asya Philippines, Inc',
                'Performed testing and quality checks on software systems.',
              ),
              _resumeItem(
                'Technical Support',
                'FDS Asya Philippines, Inc',
                'Provided technical assistance and troubleshooting.',
              ),
              _resumeItem(
                'Development — Current',
                'FDS Asya Philippines, Inc',
                'Building a full-stack profile management system using Flutter, Go, and PostgreSQL.',
              ),
            ],
          ),
        ],
      ),
    );
  }

// ── Resume section (Education or Experience)
  Widget _resumeSection(IconData icon, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Timeline items
        ...items,
      ],
    );
  }

// ── Resume timeline item
  Widget _resumeItem(String title, String period, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline dot + line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.15),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // ── Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Portfolio content

  Widget _buildPortfolioContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          const Text(
            'Portfolio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          // ── Underline
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 32),
            width: 40,
            height: 3,
            color: Colors.white,
          ),

          // ── Projects title
          const Text(
            'Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // ── Projects grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _portfolioCard(
                'Profile Management System',
                'Flutter · Dart',
                'Built the frontend UI of a profile management system during internship at FDS Asya Philippines, Inc. Includes dashboard, profile cards, and detail screens.',
              ),
              _portfolioCard(
                'Chess Profile UI',
                'Flutter · Dart',
                'A creative individual profile detail screen with chess piece theme and interactive expandable sections.',
              ),
              _portfolioCard(
                'RTAS — Capstone Project',
                'RFID · Hardware · Software',
                'Real-Time Attendance System using RFID scanner. Built as a capstone project to automate attendance tracking.',
              ),
              _portfolioCard(
                'Custom UI Components',
                'Flutter · Dart',
                'Designed and built various custom UI components and screens including animated cards, carousels, and themed layouts.',
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ── Tech Stack title
          const Text(
            'Tech Stack',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // ── Tech stack grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _techChip('Flutter'),
              _techChip('Dart'),
              _techChip('Golang'),
              _techChip('PostgreSQL'),
              _techChip('GitHub'),
              _techChip('VS Code'),
              _techChip('macOS'),
              _techChip('Claude'),
              _techChip('ChatGPT'),
            ],
          ),
        ],
      ),
    );
  }

// ── Portfolio card
  Widget _portfolioCard(String title, String tech, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tech,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

// ── Tech chip
  Widget _techChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact content
  Widget _buildContactContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          const Text(
            'Contact',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          // ── Underline
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 32),
            width: 40,
            height: 3,
            color: Colors.white,
          ),

          // ── Contact cards row
          Row(
            children: [
              Expanded(
                child: _contactCard(
                  Icons.email,
                  'Email',
                  'aldhy@main.com',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _contactCard(
                  Icons.phone,
                  'Phone',
                  '+63 9759488949',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _contactCard(
                  Icons.location_on,
                  'Location',
                  'Laguna, Philippines',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Message section
          const Text(
            "Let's Work Together",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Feel free to reach out for collaborations, questions, or just to say hi!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
              height: 1.7,
            ),
          ),

          const SizedBox(height: 24),

          // ── Info rows
          _contactInfoRow(Icons.school, 'Course', 'BS Information System'),
          _contactInfoRow(Icons.work, 'Company', 'FDS Asya Philippines, Inc'),
          _contactInfoRow(Icons.group, 'Group', 'Group 2 · Development Dept.'),
          _contactInfoRow(Icons.cake, 'Age', '22 years old'),
          _contactInfoRow(Icons.people, 'Status', 'Single'),
        ],
      ),
    );
  }

  // ── Contact card
  Widget _contactCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// ── Social button
  Widget _socialButton(String label, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Contact info row
  Widget _contactInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.4),
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
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
