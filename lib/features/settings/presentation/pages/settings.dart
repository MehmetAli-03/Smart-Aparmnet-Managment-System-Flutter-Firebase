import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ==========================================
// ANA AYARLAR SAYFASI
// ==========================================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Ayarlar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionTitle("HESAP YÖNETİMİ"),
          _buildSettingsCard([
            _buildListTile(
              icon: Icons.person_rounded,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
              title: "Profil Bilgileri",
              subtitle: "Kişisel verilerinizi güncelleyin",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileInfoPage())),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.vpn_key_rounded,
              iconBgColor: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: "Şifre İşlemleri",
              subtitle: "Hesap güvenliğinizi sağlayın",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
            ),
          ]),

          const SizedBox(height: 28),

          _buildSectionTitle("TERCİHLER"),
          _buildSettingsCard([
            _buildListTile(
              icon: Icons.notifications_active_rounded,
              iconBgColor: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF10B981),
              title: "Bildirimler",
              trailing: Switch(
                value: notificationsEnabled,
                activeColor: const Color(0xFF3B82F6),
                onChanged: (val) => setState(() => notificationsEnabled = val),
              ),
              onTap: () => setState(() => notificationsEnabled = !notificationsEnabled),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.dark_mode_rounded,
              iconBgColor: const Color(0xFFF5F3FF),
              iconColor: const Color(0xFF8B5CF6),
              title: "Karanlık Tema",
              trailing: Switch(
                value: isDarkMode,
                activeColor: const Color(0xFF3B82F6),
                onChanged: (val) {
                  setState(() => isDarkMode = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Karanlık tema yakında aktif olacak!"), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              onTap: () => setState(() => isDarkMode = !isDarkMode),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.language_rounded,
              iconBgColor: const Color(0xFFFCE7F3),
              iconColor: const Color(0xFFEC4899),
              title: "Uygulama Dili",
              trailing: const Text("Türkçe", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 28),

          _buildSectionTitle("DESTEK & GİZLİLİK"),
          _buildSettingsCard([
            _buildListTile(
              icon: Icons.help_outline_rounded,
              iconBgColor: const Color(0xFFF3F4F6),
              iconColor: const Color(0xFF6B7280),
              title: "Yardım Merkezi",
              onTap: () {},
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.shield_rounded,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              title: "Veri Gizliliği",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
            ),
          ]),

          const SizedBox(height: 28),

          // Tehlikeli Bölge
          _buildSettingsCard([
            _buildListTile(
              icon: Icons.delete_forever_rounded,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: Colors.redAccent,
              title: "Hesabımı Sil",
              titleColor: Colors.redAccent,
              showChevron: false,
              onTap: () => _showDeleteDialog(context),
            ),
          ]),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                const Text("Bina Yönetim App", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("Versiyon 1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: titleColor ?? const Color(0xFF1E293B))),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                    ]
                  ],
                ),
              ),
              if (trailing != null) trailing
              else if (showChevron) Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9), indent: 70, endIndent: 20);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text("Hesabı Sil", style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text("Tüm verileriniz kalıcı olarak silinecektir. Bu işlemi onaylıyor musunuz?", style: TextStyle(color: Color(0xFF64748B), height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu özellik şu an güvenlik nedeniyle kapalıdır.")));
            },
            child: const Text("Kalıcı Olarak Sil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. PROFİL BİLGİLERİ SAYFASI (DİNAMİK)
// ==========================================
class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate() && user != null) {
      setState(() => _isSaving = true);
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil harika görünüyor, güncellendi! 🚀"), backgroundColor: Color(0xFF10B981)));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB), // MAVİ YAPILDI
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // İKON BEYAZ YAPILDI
        title: const Text("Profil Bilgileri", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)), // YAZI BEYAZ YAPILDI
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : "👤",
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildInputLabel("E-posta Adresi (Değiştirilemez)"),
              _buildTextField(initialValue: user?.email ?? "Bilinmiyor", enabled: false, icon: Icons.email_rounded),
              const SizedBox(height: 24),
              _buildInputLabel("Ad Soyad"),
              _buildTextField(controller: _nameController, icon: Icons.person_rounded, hint: "Adınız Soyadınız", validator: (val) => val!.isEmpty ? "Ad boş bırakılamaz" : null),
              const SizedBox(height: 24),
              _buildInputLabel("Telefon Numarası"),
              _buildTextField(controller: _phoneController, icon: Icons.phone_rounded, hint: "05XX XXX XX XX", isPhone: true),
              const SizedBox(height: 48),
              _buildGradientButton("Değişiklikleri Kaydet", _isSaving, _updateProfile),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. ŞİFRE DEĞİŞTİRME SAYFASI (DİNAMİK)
// ==========================================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        await user?.updatePassword(_newPasswordController.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifreniz başarıyla güncellendi! 🔒"), backgroundColor: Color(0xFF10B981)));
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String msg = "Bir hata oluştu.";
        if (e.code == 'requires-recent-login') msg = "Güvenlik nedeniyle şifre değiştirmeden önce hesaptan çıkış yapıp tekrar giriş yapmalısınız.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB), // MAVİ YAPILDI
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // İKON BEYAZ YAPILDI
        title: const Text("Şifre Değiştir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)), // YAZI BEYAZ YAPILDI
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Color(0xFFFFFBEB), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_person_rounded, size: 64, color: Color(0xFFF59E0B)),
                ),
              ),
              const SizedBox(height: 32),
              const Text("Güçlü bir şifre kullanmanız hesap güvenliğiniz için önemlidir.", style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _buildInputLabel("Yeni Şifre"),
              _buildPasswordField(controller: _newPasswordController, obscureText: _obscure1, onToggle: () => setState(() => _obscure1 = !_obscure1), validator: (val) => val != null && val.length < 6 ? "Şifre en az 6 karakter olmalı" : null),
              const SizedBox(height: 24),
              _buildInputLabel("Yeni Şifre (Tekrar)"),
              _buildPasswordField(controller: _confirmPasswordController, obscureText: _obscure2, onToggle: () => setState(() => _obscure2 = !_obscure2), validator: (val) => val != _newPasswordController.text ? "Şifreler uyuşmuyor" : null),
              const SizedBox(height: 48),
              _buildGradientButton("Şifreyi Güncelle", _isSaving, _changePassword),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. VERİ GİZLİLİĞİ SAYFASI (STATİK)
// ==========================================
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Veri Gizliliği", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Icon(Icons.shield_rounded, size: 80, color: const Color(0xFF3B82F6).withOpacity(0.2))),
            const SizedBox(height: 24),
            const Text("Gizlilik Politikası ve KVKK", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            _buildPolicyText("1. Veri Toplama", "Uygulamamız, apartman ve site yönetimini kolaylaştırmak amacıyla adınız, e-posta adresiniz, telefon numaranız ve daire numaranız gibi temel iletişim bilgilerinizi toplar."),
            _buildPolicyText("2. Verilerin Kullanımı", "Toplanan bu veriler yalnızca bina içi iletişimi sağlamak, aidat bildirimleri yapmak ve yönetimsel süreçleri yürütmek amacıyla kullanılır. Üçüncü şahıslarla reklam veya pazarlama amacıyla kesinlikle paylaşılmaz."),
            _buildPolicyText("3. Veri Güvenliği", "Kullanıcı bilgileri bulut altyapısı kullanılarak üst düzey şifreleme yöntemleriyle saklanmaktadır. Şifreleriniz sistem tarafında daima kriptoludur."),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B)),
                  SizedBox(width: 12),
                  Text("İletişim: kvkk@binayonetim.com", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyText(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6)),
        ],
      ),
    );
  }
}

// ==========================================
// ORTAK YARDIMCI WIDGET'LAR (UI POLISH)
// ==========================================

Widget _buildInputLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 13)),
  );
}

Widget _buildTextField({String? initialValue, TextEditingController? controller, required IconData icon, bool enabled = true, String? hint, bool isPhone = false, String? Function(String?)? validator}) {
  return TextFormField(
    initialValue: initialValue,
    controller: controller,
    enabled: enabled,
    keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
    validator: validator,
    style: TextStyle(color: enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: enabled ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8)),
      filled: true,
      fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
    ),
  );
}

Widget _buildPasswordField({required TextEditingController controller, required bool obscureText, required VoidCallback onToggle, String? Function(String?)? validator}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFF59E0B)),
      suffixIcon: IconButton(icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF94A3B8)), onPressed: onToggle),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2)),
    ),
  );
}

Widget _buildGradientButton(String text, bool isSaving, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      onPressed: isSaving ? null : onPressed,
      child: isSaving
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
    ),
  );
}