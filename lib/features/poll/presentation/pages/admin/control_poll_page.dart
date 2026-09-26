import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../data/models/poll_model.dart';
import '../../../data/services/poll_service.dart';
import '../../../../complaint/presentation/pages/admin/complaint_list_page..dart';


class AdminPollPage extends StatefulWidget {
  final String apartmentId;

  const AdminPollPage({super.key, required this.apartmentId});

  @override
  State<AdminPollPage> createState() => _AdminPollPageState();
}

class _AdminPollPageState extends State<AdminPollPage> {
  // 0: Liste, 1: Yeni Ekle
  int _selectedIndex = 0;
  final _dao = PollDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50

      // --- 1. PRO HEADER ---
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "KONTROL PANELİ",
          style: TextStyle(
            color: Color(0xFF0F172A), // Slate-900
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),
          // --- 2. ÜST KISIM (Hızlı Erişim ve Toggle) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildComplaintActionCard(),
                const SizedBox(height: 20),
                // MODERN SEGMENTED TOGGLE
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      _buildSegmentBtn(
                          "Aktif Oylamalar", Icons.bar_chart_rounded, 0),
                      _buildSegmentBtn("Yeni Oylama",
                          Icons.add_circle_outline_rounded, 1),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- 3. İÇERİK ALANI ---
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _selectedIndex == 0
                  ? _buildPollList()
                  : _AdminCreateFormInternal(apartmentId: widget.apartmentId),
            ),
          ),
        ],
      ),
    );
  }

  // Şikayetlere Git Butonu
  Widget _buildComplaintActionCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ComplaintListPage(
                    apartmentId: widget.apartmentId,
                    isAdmin: true
                )
            )
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.mark_email_unread_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Talep & Şikayetler",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text("Gelen bildirimleri incele",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18)),
          ],
        ),
      ),
    );
  }

  // Toggle Butonları
  Widget _buildSegmentBtn(String text, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LİSTE GÖRÜNÜMÜ ---
  Widget _buildPollList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _dao.getPolls(widget.apartmentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade100)),
                  child: Icon(Icons.query_stats_rounded,
                      size: 60, color: Colors.grey.shade300),
                ),
                const SizedBox(height: 16),
                Text("Aktif oylama bulunmuyor",
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final poll = Poll.fromDoc(docs[index]);
            return _buildProPollCard(poll);
          },
        );
      },
    );
  }

  // 🔥🔥 YENİLENEN KART TASARIMI (DURDUR + SİL BUTONLARI) 🔥🔥
  Widget _buildProPollCard(Poll poll) {
    bool isExpired = DateTime.now().isAfter(poll.endDate) || !poll.isActive;

    // Kartın ana rengi
    final Color accentColor =
    isExpired ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İkon Alanı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                      isExpired
                          ? Icons.history_toggle_off_rounded
                          : Icons.how_to_vote_rounded,
                      color: accentColor,
                      size: 24),
                ),
                const SizedBox(width: 14),
                // Başlık ve Tarih
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poll.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isExpired
                              ? "Sonlandı"
                              : "Bitiş: ${DateFormat("dd MMM, HH:mm", "tr_TR").format(poll.endDate)}",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SAĞ TARAFTAKİ AKSİYON BUTONLARI ---
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. DURDUR BUTONU (Sadece Aktifse Görünür)
                    if (!isExpired)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: IconButton(
                          onPressed: () => _confirmClosePoll(poll.id),
                          icon: const Icon(Icons.stop_circle_outlined, size: 22),
                          color: const Color(0xFFEF4444),
                          style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              padding: const EdgeInsets.all(8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          tooltip: "Oylamayı Bitir",
                        ),
                      ),

                    // 2. SİL BUTONU (Her Zaman Görünür - Çöp Kutusu)
                    IconButton(
                      onPressed: () => _confirmDeletePoll(poll.id),
                      icon: const Icon(Icons.delete_outline_rounded, size: 22),
                      color: Colors.grey.shade400, // Daha silik gri
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      tooltip: "Tamamen Sil",
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 24, endIndent: 24),
          const SizedBox(height: 20),

          // Card Body (Sonuçlar)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              children: [
                _buildProResultBar("A", poll.optionA, poll.voteA,
                    poll.totalVotes, accentColor),
                const SizedBox(height: 16),
                _buildProResultBar("B", poll.optionB, poll.voteB,
                    poll.totalVotes, accentColor),
                if (poll.optionC.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildProResultBar("C", poll.optionC, poll.voteC,
                      poll.totalVotes, accentColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProResultBar(
      String letter, String text, int votes, int total, Color color) {
    double percent = total == 0 ? 0 : (votes / total);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF475569))),
            ),
            Text("${(percent * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
                height: 10,
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12))),
            FractionallySizedBox(
              widthFactor: percent == 0 ? 0.02 : percent,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // --- ONAY PENCERELERİ ---

  // 1. Bitirme (Durdurma) Onayı
  void _confirmClosePoll(String pollId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Oylamayı Bitir",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Bu oylamayı erken sonlandırmak istediğinize emin misiniz?"),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () {
              _dao.closePoll(pollId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text("BİTİR"),
          ),
        ],
      ),
    );
  }

  // 2. Silme Onayı (Yeni Eklendi)
  void _confirmDeletePoll(String pollId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Oylamayı Sil",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Bu oylamayı tamamen silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
            style: TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _dao.deletePoll(widget.apartmentId, pollId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Oylama silindi"),
                  backgroundColor: Colors.redAccent));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }
}

// --- CREATE FORM (Değişiklik yok) ---
class _AdminCreateFormInternal extends StatefulWidget {
  final String apartmentId;
  const _AdminCreateFormInternal({required this.apartmentId});
  @override
  State<_AdminCreateFormInternal> createState() =>
      _AdminCreateFormInternalState();
}

class _AdminCreateFormInternalState extends State<_AdminCreateFormInternal> {
  final _q = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  DateTime? _date;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 20),
            child: Text("Yeni bir oylama oluşturun",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
          ),

          _buildProInput(_q, "Oylama Konusu / Soru", Icons.edit_note_rounded,
              maxLines: 2),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12),
            child: Text("Seçenekler",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700)),
          ),
          _buildProInput(_a, "Seçenek A", Icons.looks_one_rounded),
          const SizedBox(height: 12),
          _buildProInput(_b, "Seçenek B", Icons.looks_two_rounded),
          const SizedBox(height: 12),
          _buildProInput(_c, "Seçenek C (Opsiyonel)", Icons.looks_3_rounded),

          const SizedBox(height: 28),

          // Date Picker Button
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _date == null
                        ? Colors.grey.shade200
                        : const Color(0xFF0F172A),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: Color(0xFF0F172A), size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bitiş Tarihi ve Saati",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                          _date == null
                              ? "Seçiniz..."
                              : DateFormat("dd MMMM yyyy, HH:mm", "tr_TR")
                              .format(_date!),
                          style: TextStyle(
                              color: _date == null
                                  ? Colors.grey.shade400
                                  : const Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.grey.shade300)
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A), // Slate-900
                elevation: 8,
                shadowColor: const Color(0xFF0F172A).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _loading
                  ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("YAYINLA",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProInput(TextEditingController c, String hint, IconData icon,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: Colors.grey.shade400, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  void _submit() async {
    if (_q.text.isEmpty ||
        _a.text.isEmpty ||
        _b.text.isEmpty ||
        _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen zorunlu alanları doldurun")));
      return;
    }
    setState(() => _loading = true);
    await PollDao().createPoll(
        apartmentId: widget.apartmentId,
        question: _q.text,
        optionA: _a.text,
        optionB: _b.text,
        optionC: _c.text,
        endDate: _date!);
    if (mounted) {
      setState(() {
        _loading = false;
        _q.clear();
        _a.clear();
        _b.clear();
        _c.clear();
        _date = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Oylama Yayınlandı!"), backgroundColor: Colors.green));
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
        initialDate: DateTime.now());
    if (d != null && mounted) {
      final t = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 17, minute: 0));
      if (t != null) {
        setState(() => _date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
      }
    }
  }
}