import 'package:build_managment/features/poll/presentation/pages/resident/poll_list_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/apartment_service.dart';
import '../../../announcement/widgets/annoucment_list.dart';
import '../../../../core/widgets/bottom_navResident.dart';
import '../../../complaint/presentation/pages/admin/complaint_list_page..dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../complaint/presentation/pages/resident/add_complaint_page.dart';
import '../../../payment/presentation/pages/resident/iban_page.dart';

class ResidentPage extends StatefulWidget {
  final String apartmentId;
  final int flatNo;

  const ResidentPage({super.key, required this.apartmentId, required this.flatNo});

  @override
  State<ResidentPage> createState() => _ResidentPageState();
}

class _ResidentPageState extends State<ResidentPage> {
  int currentIndex = 0;

  // 🔥 DAO TANIMLAMASI
  final apartmentDao = ApartmentDao();

  // 🔥 2. İLK YÜKLEME KİLİDİ (Eski mesajlar bildirim olarak düşmesin diye)
  bool _isFirstLoad = true;

  // 🔥 3. SAYFA AÇILDIĞINDA DİNLEYİCİYİ BAŞLATIYORUZ
  @override
  void initState() {
    super.initState();
    _listenForNewNotifications();
  }

  // 🔥 4. İŞTE O SİHİRLİ DİNLEYİCİ FONKSİYON 🔥
  void _listenForNewNotifications() {
    FirebaseFirestore.instance
        .collection('apartments')
        .doc(widget.apartmentId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async { // async ekledik!

      if (_isFirstLoad) {
        _isFirstLoad = false;
        return;
      }

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data();

          if (data != null) {

            // 🔥 BİNA İSMİNİ VERİTABANINDAN ÇEKİYORUZ
            String binaIsmi = "Bina Yönetimi";
            try {
              var doc = await FirebaseFirestore.instance.collection('apartments').doc(widget.apartmentId).get();
              if (doc.exists) {
                binaIsmi = doc.data()?['name'] ?? "Bina Yönetimi";
              }
            } catch (e) {
              print("Bina ismi çekilemedi");
            }

            // 🔥 YENİ PRO BİLDİRİMİ FIRLATIYORUZ
            LocalNotificationService.showNotification(
              title: data['title'] ?? 'Yeni Bildirim',
              body: data['message'] ?? 'Apartmanınızda yeni bir gelişme var.',
              apartmentName: binaIsmi, // İşte burası bildirimin üstüne yazacak!
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Sadece Ana Sayfada (Index 0) Mavi Arka Plan Gradient'i Göster
          if (currentIndex == 0)
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (currentIndex == 0) _buildEnhancedHeader(),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                      child: _buildBody(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddComplaintPage(apartmentId: widget.apartmentId)))
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ModernBottomBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()).toUpperCase(),
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Hoş Geldiniz",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                ],
              ),
              Row(
                children: [
                  // 🔥 YENİ BİLDİRİM BUTONU BURADA
                  _buildNotificationButton(),
                  const SizedBox(width: 12),
                  _headerActionButton(Icons.logout_rounded, () => Navigator.pop(context), isLogout: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Bilgi Kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.apartment_rounded, color: Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                          future: apartmentDao.getApartment(widget.apartmentId),
                          builder: (context, snapshot) {
                            String apartmentName = "Yükleniyor...";
                            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                              final data = snapshot.data!.data() as Map<String, dynamic>;
                              apartmentName = data['name'] ?? "Apartman İsmi Yok";
                            } else if (snapshot.hasError) {
                              apartmentName = "Hata Oluştu";
                            }
                            return Text(
                              apartmentName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                      ),
                      Text("Daire: ${widget.flatNo}", style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BİLDİRİM BUTONU
  Widget _buildNotificationButton() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('apartments')
          .doc(widget.apartmentId)
          .collection('notifications')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        bool hasNotifications = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return InkWell(
          onTap: () => _showNotificationsBottomSheet(context),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                if (hasNotifications)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // AŞAĞIDAN AÇILAN BİLDİRİM PENCERESİ
  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.70,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 24),
                  height: 5,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Bildirimler",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('apartments')
                      .doc(widget.apartmentId)
                      .collection('notifications')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
                    var docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_rounded, size: 64, color: Colors.blueGrey.shade100),
                            const SizedBox(height: 16),
                            const Text("Henüz bildirim yok", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;

                        IconData icon = Icons.campaign_rounded;
                        if (data['type'] == 'aidat') icon = Icons.account_balance_wallet_rounded;
                        if (data['type'] == 'oylama') icon = Icons.how_to_vote_rounded;

                        DateTime date = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now();
                        String formattedDate = DateFormat('d MMM HH:mm', 'tr_TR').format(date);
                        bool isNew = DateTime.now().difference(date).inHours < 24;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(icon, color: const Color(0xFF2563EB), size: 26),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['title'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isNew)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text("YENİ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                                          )
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data['message'] ?? '',
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(fontSize: 12, color: const Color(0xFF64748B).withOpacity(0.7), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerActionButton(IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: isLogout ? Colors.greenAccent : Colors.white, size: 22),
      ),
    );
  }

  Widget _buildBody() {
    switch (currentIndex) {
      case 0: return AnnouncementList(apartmentId: widget.apartmentId);
      case 1: return IbanPage(apartmentId: widget.apartmentId, userId: "TEMP", isAdmin: false);
      case 2: return ComplaintListPage(apartmentId: widget.apartmentId);
      case 3: return ResidentPollPage(apartmentId: widget.apartmentId, userId: (widget.flatNo).toString());
      default: return const SizedBox();
    }
  }
}