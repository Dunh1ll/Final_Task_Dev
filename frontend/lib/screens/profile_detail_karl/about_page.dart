import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'shared.dart';

class KAboutPage extends StatelessWidget {
  final bool isWide;
  const KAboutPage({required this.isWide});

  @override
  Widget build(BuildContext context) => KReveal(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 160 : 32,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(number: '01', title: 'About Me'),
              const SizedBox(height: 48),
              isWide ? _wideLayout() : _narrowLayout(),
            ],
          ),
        ),
      );

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bioText(),
              const SizedBox(height: 32),
              _skillsList(),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 4,
          child: Center(child: _PhotoCard()),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _PhotoCard()),
        const SizedBox(height: 40),
        _bioText(),
        const SizedBox(height: 32),
        _skillsList(),
      ],
    );
  }

  Widget _bioText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BioParagraph(
          "Hello! My name is Karl and I enjoy building things that live on the internet. "
          "My interest in software development started back when I began studying "
          "Information Systems — turns out tinkering with code taught me a lot about "
          "how the digital world works!",
        ),
        const SizedBox(height: 16),
        _BioParagraph(
          "Fast-forward to today, I've had the privilege of working as an intern at "
          "FDSAP, where I focus on building mobile applications and backend systems. "
          "My main focus these days is building accessible, human-centered products.",
        ),
        const SizedBox(height: 16),
        _BioParagraph(
          "When I'm not coding, I enjoy exploring new tech stacks, contributing to "
          "open-source projects, and leveling up my UI/UX design skills.",
        ),
      ],
    );
  }

  Widget _skillsList() {
    final skills = [
      'Flutter & Dart',
      'Golang',
      'PostgreSQL',
      'UI/UX Design',
      'REST APIs',
      'VS Code',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Here are a few technologies I've been working with recently:",
          style: TextStyle(
            color: KC.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 0,
          runSpacing: 4,
          children: List.generate(
            skills.length,
            (i) => SizedBox(
              width: 160,
              child: _SkillItem(skill: skills[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _BioParagraph extends StatelessWidget {
  final String text;
  const _BioParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: KC.textSecondary,
        fontSize: 16,
        height: 1.75,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SkillItem extends StatelessWidget {
  final String skill;
  const _SkillItem({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('▹ ', style: TextStyle(color: KC.mint, fontSize: 14)),
          Text(
            skill,
            style: const TextStyle(
              color: KC.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo Card ────────────────────────────────────────────────────
class _PhotoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: KC.mint.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: KC.mint.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/profile2.png',
          width: 260,
          height: 260,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 260,
            height: 260,
            color: KC.bgLight,
            child: const Icon(Icons.person, color: KC.mint, size: 80),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String number, title;
  const SectionHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$number. ',
          style: const TextStyle(
            color: KC.mint,
            fontSize: 20,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: KC.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            height: 1,
            color: KC.border,
          ),
        ),
      ],
    );
  }
}