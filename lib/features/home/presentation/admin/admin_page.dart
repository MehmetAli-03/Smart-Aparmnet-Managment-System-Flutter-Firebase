import 'package:build_managment/features/poll/presentation/pages/admin/control_poll_page.dart';
import 'package:build_managment/features/home/presentation/resident/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/apartment_service.dart';
import '../../../announcement/widgets/annoucment_list.dart';
import '../../../../core/widgets/bottom_navAdmin.dart';
import '../../../announcement/presentation/pages/admin/add_announcement_page.dart';
import '../../../payment/presentation/pages/admin/iban_edit.dart';
import '../../../auth/presentation/pages/admin/users_list_page.dart';

class AdminPage extends StatefulWidget {
  final String apartmentId;
  final String adminCode;
  final String residentCode;

  const AdminPage({
    super.key,
    required this.apartmentId,
    required this.adminCode,
    required this.residentCode,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int currentIndex = 0;
  final apartmentDao = ApartmentDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder(
        future: apartmentDao.getApartment(widget.apartmentId), // Bina verisini çekiyoruz
        builder: (context, snap) {
          // Veri gelene kadar bir yükleme gösterelim (Header için)
          String apartmentName = "Yükleniyor...";
          if (snap.hasData && snap.data!.exists) {
            final data = snap.data!.data() as Map<String, dynamic>;
            apartmentName = data["name"] ?? "Apartman Yönetimi";
          }

          return Stack(
            children: [
              if (currentIndex == 0)
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    if (currentIndex == 0) _buildAdminHeroHeader(apartmentName),
                    if (currentIndex != 0) _buildSectionTitle(),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddAnnouncement(),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        onCenterTap: () => _goToAddAnnouncement(),
      ),
    );
  }

  Widget _buildAdminHeroHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "YÖNETİCİ PANELİ",
                    style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Hoş Geldin, Yönetici",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              _actionIcon(Icons.logout_rounded, ()  {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  DashboardPage()));
              }),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.amber.shade600, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.domain_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                          const Text("Merkezi Yönetim Sistemi", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _codeBox("YÖNETİCİ KODU", widget.adminCode),
                    _codeBox("SAKİN KODU", widget.residentCode),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeBox(String label, String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label kopyalandı"), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
        );
      },
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Text(code, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, color: Colors.white24, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.redAccent.shade100, size: 22),
      ),
    );
  }

  Widget _buildSectionTitle() {
    List<String> titles = ["Dashboard", "IBAN Ayarları", "Sakin Listesi", "Sistem Ayarları"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(titles[currentIndex], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
    );
  }

  void _goToAddAnnouncement() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddAnnouncementPage(apartmentId: widget.apartmentId)));
  }

  Widget _buildBody() {
    switch (currentIndex) {
      case 0: return AnnouncementList(apartmentId: widget.apartmentId);
      case 1: return IbanEditPage(apartmentId: widget.apartmentId);
      case 2: return UsersListPage(apartmentId: widget.apartmentId);
      case 3: return AdminPollPage(apartmentId: widget.apartmentId);
      default: return const SizedBox();
    }
  }
}