import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/translations.dart';
import '../models/treatment_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── Language ───
  String _lang = 'en';

  // ─── Lab Test Values ───
  String _cPeptide = '';
  String _glucose = '';
  String _uricAcid = '';
  String _cholesterol = '';
  String _bilirubin = '';

  // ─── Visible Sections ───
  bool _helpExpanded = false;
  String _activeSection = ''; // 't1', 'du', 'dg'
  bool _showResult = false;
  bool _showEmergency = false;
  bool _showMessageBox = false;

  // ─── Selected Symptoms ───
  final Set<String> _selectedSymptoms = {};

  // ─── Result ───
  String _medicineCode = '';
  String _selectedSymptomsText = '';
  String _treatmentUrl = '';

  // ─── Order Form ───
  final _senderController = TextEditingController();
  final _addressController = TextEditingController();
  final _messageController = TextEditingController();
  String _cod = '';
  String _askTreatment = '';

  // ─── Scroll ───
  final _scrollController = ScrollController();
  final _symptomKey = GlobalKey();
  final _resultKey = GlobalKey();

  String _t(String key) => AppTranslations.t(key, _lang);

  bool get _isRtl => AppTranslations.isRtl(_lang);

  @override
  void dispose() {
    _senderController.dispose();
    _addressController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── SHOW SYMPTOMS ───
  void _showSymptoms() {
    if (_cPeptide.isEmpty || _glucose.isEmpty) {
      _showAlert(_t('alertLab'));
      return;
    }

    setState(() {
      _activeSection = '';
      _selectedSymptoms.clear();
    });

    // Low C-Peptide + High Glucose
    if (_cPeptide == 'low' && _glucose == 'high') {
      setState(() => _activeSection = 't1');
      _scrollToSymptoms();
      return;
    }

    // High C-Peptide + High Glucose
    if (_cPeptide == 'high' && _glucose == 'high') {
      if (_uricAcid == 'high' &&
          _cholesterol == 'high' &&
          _bilirubin == 'normal') {
        setState(() => _activeSection = 'du');
        _scrollToSymptoms();
        return;
      }

      if (_uricAcid == 'normal' &&
          _cholesterol == 'normal' &&
          _bilirubin == 'high') {
        setState(() => _activeSection = 'dg');
        _scrollToSymptoms();
        return;
      }

      _showAlert(_t('alertNoPath'));
      return;
    }

    _showAlert(_t('alertNoPath'));
  }

  // ─── FIND TREATMENT ───
  void _findTreatment(String group) {
    final symptoms = _selectedSymptoms.toList();
    if (symptoms.isEmpty) {
      _showAlert(_t('alertSymptoms'));
      return;
    }

    String code;
    if (group == 't1') {
      code = TreatmentData.getT1Treatment(symptoms);
    } else if (group == 'du') {
      code = TreatmentData.getDUTreatment(symptoms);
    } else {
      code = TreatmentData.getDGTreatment(symptoms);
    }

    final url = TreatmentData.treatments[code] ?? '';
    final emergency = TreatmentData.hasEmergencySymptoms(symptoms);

    setState(() {
      _medicineCode = code;
      _selectedSymptomsText = symptoms
          .map((s) => AppTranslations.translateSymptom(s, _lang))
          .join(', ');
      _treatmentUrl = url;
      _showResult = true;
      _showEmergency = emergency;
    });

    _scrollToResult();
  }

  // ─── WHATSAPP ORDER ───
  void _orderWhatsApp() {
    if (_medicineCode.isEmpty) {
      _showAlert(_t('alertTreatmentFirst'));
      return;
    }
    if (_senderController.text.trim().isEmpty) {
      _showAlert(_t('alertSender'));
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showAlert(_t('alertAddress'));
      return;
    }
    if (_cod.isEmpty) {
      _showAlert(_t('alertCOD'));
      return;
    }

    final message = '''Diabetes Treatment Order

Medicine Code: $_medicineCode

Symptoms:
$_selectedSymptomsText

Sender Number:
${_senderController.text.trim()}

Address:
${_addressController.text.trim()}

Cash on Delivery:
$_cod

Treatment Website:
${TreatmentData.treatments[_medicineCode] ?? "Not specified"}

Please process my order.''';

    _openWhatsApp(message);
  }

  // ─── CUSTOM WHATSAPP ───
  void _sendCustomWhatsApp() {
    if (_messageController.text.trim().isEmpty) {
      _showAlert(_t('alertMessage'));
      return;
    }

    final message = '''Treatment Question

${_messageController.text.trim()}''';

    _openWhatsApp(message);
  }

  // ─── RESET ───
  void _resetPage() {
    setState(() {
      _cPeptide = '';
      _glucose = '';
      _uricAcid = '';
      _cholesterol = '';
      _bilirubin = '';
      _activeSection = '';
      _showResult = false;
      _showEmergency = false;
      _showMessageBox = false;
      _selectedSymptoms.clear();
      _medicineCode = '';
      _selectedSymptomsText = '';
      _treatmentUrl = '';
      _cod = '';
      _askTreatment = '';
      _senderController.clear();
      _addressController.clear();
      _messageController.clear();
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  // ─── HELPERS ───
  void _showAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1e3a8a),
      ),
    );
  }

  Future<void> _openWhatsApp(String message) async {
    final url = Uri.parse(
      'https://wa.me/${TreatmentData.whatsappNumber}?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _scrollToSymptoms() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_symptomKey.currentContext != null) {
        Scrollable.ensureVisible(
          _symptomKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ═══════════════ BUILD ═══════════════

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F7FF),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildLanguageSelector(),
                const SizedBox(height: 14),
                _buildHelpCard(),
                const SizedBox(height: 14),
                _buildLabTestsCard(),
                if (_activeSection == 't1') ...[
                  const SizedBox(height: 14),
                  _buildSymptomsCard(
                    key: _symptomKey,
                    heading: _t('t1Heading'),
                    symptoms: TreatmentData.t1Symptoms,
                    group: 't1',
                    videoUrl: TreatmentData.t1VideoUrl,
                  ),
                ],
                if (_activeSection == 'du') ...[
                  const SizedBox(height: 14),
                  _buildSymptomsCard(
                    key: _symptomKey,
                    heading: _t('duHeading'),
                    symptoms: TreatmentData.duSymptoms,
                    group: 'du',
                    videoUrl: TreatmentData.t2VideoUrl,
                  ),
                ],
                if (_activeSection == 'dg') ...[
                  const SizedBox(height: 14),
                  _buildSymptomsCard(
                    key: _symptomKey,
                    heading: _t('dgHeading'),
                    symptoms: TreatmentData.dgSymptoms,
                    group: 'dg',
                    videoUrl: TreatmentData.t2VideoUrl,
                  ),
                ],
                if (_showResult) ...[
                  const SizedBox(height: 14),
                  _buildResultCard(),
                ],
                const SizedBox(height: 14),
                _buildAskTreatmentCard(),
                const SizedBox(height: 14),
                _buildAllResetCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────── HEADER ─────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF075985), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        _t('title'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }

  // ─────────────── LANGUAGE SELECTOR ──────
  Widget _buildLanguageSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('selectLanguage'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF075985),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1e3a8a), width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lang,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                borderRadius: BorderRadius.circular(10),
                items: AppTranslations.supportedLanguages.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e3a8a),
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _lang = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── HELP CARD ──────────────
  Widget _buildHelpCard() {
    return _card(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  setState(() => _helpExpanded = !_helpExpanded),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0b7285),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment:
                    _isRtl ? Alignment.centerRight : Alignment.centerLeft,
              ),
              child: Text(
                _t('helpButton'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_helpExpanded) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF8F5),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: _isRtl
                      ? BorderSide.none
                      : const BorderSide(
                          color: Color(0xFF087f5b), width: 5),
                  right: _isRtl
                      ? const BorderSide(
                          color: Color(0xFF087f5b), width: 5)
                      : BorderSide.none,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('helpTitle'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _helpItem('1', _t('help1')),
                  const SizedBox(height: 8),
                  _helpItem('2', _t('help2')),
                  const SizedBox(height: 8),
                  _helpItem('3', _t('help3')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _helpItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number. ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(text)),
      ],
    );
  }

  // ─────────────── LAB TESTS CARD ─────────
  Widget _buildLabTestsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('labHeading'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF075985),
            ),
          ),
          const SizedBox(height: 15),
          _labField(
            label: _t('cPeptide'),
            value: _cPeptide,
            items: [
              MapEntry('', _t('select')),
              MapEntry('low', _t('low')),
              MapEntry('high', _t('high')),
            ],
            onChanged: (v) => setState(() => _cPeptide = v),
          ),
          const SizedBox(height: 12),
          _labField(
            label: _t('glucose'),
            value: _glucose,
            items: [
              MapEntry('', _t('select')),
              MapEntry('high', _t('high')),
            ],
            onChanged: (v) => setState(() => _glucose = v),
          ),
          const SizedBox(height: 12),
          _labField(
            label: _t('uric'),
            value: _uricAcid,
            items: [
              MapEntry('', _t('select')),
              MapEntry('high', _t('high')),
              MapEntry('normal', _t('normal')),
            ],
            onChanged: (v) => setState(() => _uricAcid = v),
          ),
          const SizedBox(height: 12),
          _labField(
            label: _t('cholesterol'),
            value: _cholesterol,
            items: [
              MapEntry('', _t('select')),
              MapEntry('high', _t('high')),
              MapEntry('normal', _t('normal')),
            ],
            onChanged: (v) => setState(() => _cholesterol = v),
          ),
          const SizedBox(height: 12),
          _labField(
            label: _t('bilirubin'),
            value: _bilirubin,
            items: [
              MapEntry('', _t('select')),
              MapEntry('high', _t('high')),
              MapEntry('normal', _t('normal')),
            ],
            onChanged: (v) => setState(() => _bilirubin = v),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              label: _t('continue'),
              color: const Color(0xFF047857),
              onPressed: _showSymptoms,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labField({
    required String label,
    required String value,
    required List<MapEntry<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFDBEAFE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 7),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(9),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.any((e) => e.key == value) ? value : items.first.key,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                borderRadius: BorderRadius.circular(9),
                items: items.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value,
                        style: const TextStyle(fontSize: 15)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── SYMPTOMS CARD ──────────
  Widget _buildSymptomsCard({
    required Key key,
    required String heading,
    required List<String> symptoms,
    required String group,
    required String videoUrl,
  }) {
    return _card(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF075985),
            ),
          ),
          const SizedBox(height: 12),
          ...symptoms.map((symptom) => _symptomTile(symptom)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionButton(
                label: _t('treatment'),
                color: const Color(0xFF047857),
                onPressed: () => _findTreatment(group),
              ),
              _actionButton(
                label: _t('video'),
                color: const Color(0xFFb91c1c),
                onPressed: () => _openUrl(videoUrl),
              ),
              _actionButton(
                label: _t('reset'),
                color: const Color(0xFFdc2626),
                onPressed: _resetPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _symptomTile(String symptom) {
    final translated = AppTranslations.translateSymptom(symptom, _lang);
    final isChecked = _selectedSymptoms.contains(symptom);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isChecked) {
            _selectedSymptoms.remove(symptom);
          } else {
            _selectedSymptoms.add(symptom);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isChecked
              ? const Color(0xFFECFDF5)
              : const Color(0xFFF8FAFC),
          border: Border.all(
            color: isChecked
                ? const Color(0xFF10B981)
                : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isChecked,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedSymptoms.add(symptom);
                    } else {
                      _selectedSymptoms.remove(symptom);
                    }
                  });
                },
                activeColor: const Color(0xFF047857),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                translated,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isChecked ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── RESULT CARD ────────────
  Widget _buildResultCard() {
    return Container(
      key: _resultKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('resultHeading'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(height: 12),

          // Medicine Code
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(
                  text: _t('medicineCode') + ' ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: _medicineCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFb91c1c),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Selected Symptoms
          Text(
            _t('selectedSymptoms'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(_selectedSymptomsText, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 15),

          // Warning
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              border: Border.all(color: const Color(0xFFF97316), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Color(0xFF9A3412), fontSize: 14),
                children: [
                  TextSpan(
                    text: _t('noticeTitle') + ' ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: _t('notice')),
                ],
              ),
            ),
          ),

          // Emergency Warning
          if (_showEmergency) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                border:
                    Border.all(color: const Color(0xFFDC2626), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color(0xFF991B1B), fontSize: 14),
                  children: [
                    TextSpan(
                      text: _t('emergencyTitle') + ' ',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _t('emergencyText')),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Order Form
          _buildOrderForm(),
        ],
      ),
    );
  }

  // ─────────────── ORDER FORM ─────────────
  Widget _buildOrderForm() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('orderHeading'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF075985),
            ),
          ),
          const SizedBox(height: 12),

          // Sender Number
          Text(_t('senderNumber'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          TextField(
            controller: _senderController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+92xxxxxxxxxx',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide:
                    const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // Address
          Text(_t('address'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          TextField(
            controller: _addressController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _t('addressPlaceholder'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide:
                    const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // Cash on Delivery
          Text(_t('cod'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(9),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _cod.isEmpty ? '' : _cod,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: [
                  DropdownMenuItem(
                      value: '', child: Text(_t('select'))),
                  DropdownMenuItem(
                      value: 'Yes', child: Text(_t('yes'))),
                  DropdownMenuItem(
                      value: 'No', child: Text(_t('no'))),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _cod = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionButton(
                label: _t('orderWhatsApp'),
                color: const Color(0xFF128c7e),
                onPressed: _orderWhatsApp,
              ),
              if (_treatmentUrl.isNotEmpty)
                _actionButton(
                  label: _t('openTreatment'),
                  color: const Color(0xFF047857),
                  onPressed: () => _openUrl(_treatmentUrl),
                ),
              _actionButton(
                label: _t('reset'),
                color: const Color(0xFFdc2626),
                onPressed: _resetPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────── ASK TREATMENT CARD ─────
  Widget _buildAskTreatmentCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('askHeading'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF075985),
            ),
          ),
          const SizedBox(height: 10),
          Text(_t('askQuestion'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(9),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _askTreatment.isEmpty ? '' : _askTreatment,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: [
                  DropdownMenuItem(
                      value: '', child: Text(_t('select'))),
                  DropdownMenuItem(
                      value: 'yes', child: Text(_t('yes'))),
                  DropdownMenuItem(
                      value: 'no', child: Text(_t('no'))),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _askTreatment = v;
                      _showMessageBox = v == 'yes';
                    });
                  }
                },
              ),
            ),
          ),
          if (_showMessageBox) ...[
            const SizedBox(height: 15),
            Text(_t('yourMessage'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: _t('messagePlaceholder'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide:
                      const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                label: _t('sendMessage'),
                color: const Color(0xFF128c7e),
                onPressed: _sendCustomWhatsApp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────── ALL RESET CARD ─────────
  Widget _buildAllResetCard() {
    return _card(
      child: SizedBox(
        width: double.infinity,
        child: _actionButton(
          label: _t('allReset'),
          color: const Color(0xFFdc2626),
          onPressed: _resetPage,
        ),
      ),
    );
  }

  // ═══════════════ REUSABLE WIDGETS ═══════

  Widget _card({required Widget child, Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
