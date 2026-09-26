import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../data/models/poll_model.dart';
import '../../../data/services/poll_service.dart';

class ResidentPollPage extends StatelessWidget {
  final String apartmentId;
  final String userId;

  ResidentPollPage({super.key, required this.apartmentId, required this.userId});

  final _dao = PollDao();

  // --- MODERN RENK PALETİ (Admin Sayfasıyla Uyumlu) ---
  final Color _bg = const Color(0xFFF8FAFC);         // Slate-50
  final Color _darkText = const Color(0xFF0F172A);   // Slate-900
  final Color _subText = const Color(0xFF64748B);    // Slate-500
  final Color _primaryBlue = const Color(0xFF2563EB); // Blue-600
  final Color _cardBorder = const Color(0xFFE2E8F0); // Slate-200

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      // --- 1. PRO HEADER ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ANKET MERKEZİ",
          style: TextStyle(
            color: _darkText,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _dao.getPolls(apartmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryBlue));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          // Tarihe göre sıralama (Yeniden eskiye)
          docs.sort((a, b) {
            final aDate = (a.data() as Map)['endDate'] as Timestamp;
            final bDate = (b.data() as Map)['endDate'] as Timestamp;
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 50),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final poll = Poll.fromDoc(docs[index]);
              return _buildResidentPollCard(poll, context);
            },
          );
        },
      ),
    );
  }

  // --- BOŞ DURUM TASARIMI ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _cardBorder),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Icon(Icons.poll_outlined, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            "Henüz Oylama Yok",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText),
          ),
          const SizedBox(height: 8),
          Text(
            "Yönetim tarafından anket açıldığında\nburadan oy kullanabilirsiniz.",
            textAlign: TextAlign.center,
            style: TextStyle(color: _subText, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- ANA KART YAPISI ---
  Widget _buildResidentPollCard(Poll poll, BuildContext context) {
    bool hasVoted = poll.votedUsers.contains(userId);
    bool isExpired = DateTime.now().isAfter(poll.endDate) || !poll.isActive;
    bool showResults = hasVoted || isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KART BAŞLIĞI
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(isExpired, hasVoted),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: _subText),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat("d MMM, HH:mm", "tr_TR").format(poll.endDate),
                          style: TextStyle(color: _subText, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  poll.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey.shade100, indent: 24, endIndent: 24),
          const SizedBox(height: 24),

          // İÇERİK (SEÇENEKLER VEYA SONUÇLAR)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: showResults
                  ? _buildResultsView(poll) // Sonuçlar
                  : _buildVotingOptions(context, poll), // Oy Kullanma
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. OY KULLANMA SEÇENEKLERİ ---
  Widget _buildVotingOptions(BuildContext context, Poll poll) {
    return Column(
      key: const ValueKey('voting'),
      children: [
        _buildVoteButton(context, "A", poll.optionA, poll.id),
        const SizedBox(height: 12),
        _buildVoteButton(context, "B", poll.optionB, poll.id),
        if (poll.optionC.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildVoteButton(context, "C", poll.optionC, poll.id),
        ],
        const SizedBox(height: 10),
        Center(
          child: Text(
            "Seçiminizi yapmak için şıklardan birine dokunun",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }

  // Modern Seçim Butonu
  Widget _buildVoteButton(BuildContext context, String optionKey, String text, String pollId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _dao.vote(pollId: pollId, userId: userId, option: optionKey),
        borderRadius: BorderRadius.circular(16),
        splashColor: _primaryBlue.withOpacity(0.1),
        highlightColor: _primaryBlue.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              // Radio Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _subText, // Slate-500
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. SONUÇLAR GÖRÜNÜMÜ ---
  Widget _buildResultsView(Poll poll) {
    return Column(
      key: const ValueKey('results'),
      children: [
        _buildProResultBar(poll.optionA, poll.voteA, poll.totalVotes),
        const SizedBox(height: 16),
        _buildProResultBar(poll.optionB, poll.voteB, poll.totalVotes),
        if (poll.optionC.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildProResultBar(poll.optionC, poll.voteC, poll.totalVotes),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: Colors.green.shade600),
            const SizedBox(width: 6),
            Text(
              "Oyunuz kaydedildi. Toplam ${poll.totalVotes} katılım.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        )
      ],
    );
  }

  // Modern Progress Bar
  Widget _buildProResultBar(String text, int votes, int total) {
    if (text.isEmpty) return const SizedBox();
    double percent = total == 0 ? 0 : (votes / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _darkText),
            ),
            Text(
              "%${(percent * 100).toStringAsFixed(0)}",
              style: TextStyle(fontWeight: FontWeight.w900, color: _primaryBlue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Arka plan çubuğu
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Slate-100
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Doluluk çubuğu
            FractionallySizedBox(
              widthFactor: percent == 0 ? 0.01 : percent,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: _primaryBlue.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- ROZET (Badge) YAPISI ---
  Widget _buildStatusBadge(bool isExpired, bool hasVoted) {
    String text;
    Color textColor;
    Color bgColor;
    IconData icon;

    if (isExpired) {
      text = "SÜRE DOLDU";
      textColor = const Color(0xFFEF4444); // Red-500
      bgColor = const Color(0xFFFEF2F2);   // Red-50
      icon = Icons.timer_off_outlined;
    } else if (hasVoted) {
      text = "OY KULLANDINIZ";
      textColor = const Color(0xFF15803D); // Green-700
      bgColor = const Color(0xFFDCFCE7);   // Green-100
      icon = Icons.check_circle_outline;
    } else {
      text = "OYLAMA AKTİF";
      textColor = _primaryBlue;
      bgColor = const Color(0xFFEFF6FF);   // Blue-50
      icon = Icons.how_to_vote_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}