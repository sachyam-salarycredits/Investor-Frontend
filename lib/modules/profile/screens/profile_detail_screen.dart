import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/image_picker.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:provider/provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().getCustomerDetails();
    });
  }

  bool get _kycDone {
    try {
      return (context.read<AppStateProvider>().stepsData?.kyc ?? '0') == '1';
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveProfile({
    String? email,
    String? phone,
    String? aadhar,
  }) async {
    final provider = context.read<AppStateProvider>();
    final profile = provider.userDetails?.profileDetails;
    setState(() => _saving = true);
    final ok = await provider.updateProfile({
      ApiParams.customerId: provider.customerId,
      ApiParams.email: (email ?? profile?.email ?? '').trimLeft(),
      ApiParams.phoneNumber: phone ?? profile?.phoneNumber ?? '',
      ApiParams.aadharNumber: aadhar ?? profile?.aadharNumber ?? '',
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Utils.showToast(msg: LanguageHelper.textProfileDetailsUpdated);
  }

  Future<void> _afterOtp(Future<void> Function() save) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationWidget(
        onFailed: () {},
        onVerified: () {
          save();
        },
      ),
    );
  }

  Future<void> _editEmail(String current) async {
    final next = await _askText(
      title: 'Email address',
      initial: current,
      keyboardType: TextInputType.emailAddress,
    );
    if (next == null || next.trim() == current.trim()) return;
    if (!next.trim().isEmailValid) {
      Utils.showToast(msg: LanguageHelper.textValidEmail);
      return;
    }
    await _afterOtp(() => _saveProfile(email: next.trim()));
  }

  Future<void> _editPhone(String current) async {
    final next = await _askText(
      title: 'Mobile number',
      initial: current.replaceAll(RegExp(r'\D'), ''),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      digitsOnly: true,
    );
    if (next == null || next.trim() == current.trim()) return;
    if (!next.trim().isMobileNumberValid) {
      Utils.showToast(msg: LanguageHelper.textValidPhone);
      return;
    }
    await _afterOtp(() => _saveProfile(phone: next.trim()));
  }

  Future<void> _editAadhar(String current) async {
    final next = await _askText(
      title: 'Aadhaar number',
      initial: current,
      keyboardType: TextInputType.number,
      maxLength: 12,
      digitsOnly: true,
    );
    if (next == null || next.trim() == current.trim()) return;
    if (!next.trim().isAdharCardValid) {
      Utils.showToast(msg: LanguageHelper.textValidAadharNo);
      return;
    }
    await _afterOtp(() => _saveProfile(aadhar: next.trim()));
  }

  Future<String?> _askText({
    required String title,
    required String initial,
    TextInputType? keyboardType,
    int? maxLength,
    bool digitsOnly = false,
  }) {
    return showPbBottomSheet<String>(
      context: context,
      builder: (sheetContext) => _TextEditSheet(
        title: title,
        initial: initial,
        keyboardType: keyboardType,
        maxLength: maxLength,
        digitsOnly: digitsOnly,
      ),
    );
  }

  Future<void> _editResidence(ResidenceAddress? home) async {
    final values = await _askAddress(
      title: 'Residence address',
      fields: [
        _AddressField('flat', 'Flat / room / floor', home?.flatNo ?? ''),
        _AddressField('door', 'Door / street / building', home?.doorNo ?? ''),
        _AddressField('pin', 'Pincode', home?.pincode ?? '',
            keyboardType: TextInputType.number, maxLength: 6),
        _AddressField('city', 'City', home?.city ?? ''),
        _AddressField('state', 'State', home?.state ?? ''),
      ],
    );
    if (values == null) return;
    if (!_addressOk(values, pinKey: 'pin')) return;
    await _afterOtp(() async {
      final provider = context.read<AppStateProvider>();
      setState(() => _saving = true);
      final ok = await provider.updateResidenceAddress({
        ApiParams.customerId: provider.customerId,
        ApiParams.flatNo: values['flat']!.trimLeft(),
        ApiParams.doorNo: values['door']!.trimLeft(),
        ApiParams.pincode: values['pin']!.trimLeft(),
        ApiParams.city: values['city']!.trimLeft(),
        ApiParams.state: values['state']!.trimLeft(),
      });
      if (!mounted) return;
      setState(() => _saving = false);
      if (ok) Utils.showToast(msg: LanguageHelper.textResidenceAddressUpdated);
    });
  }

  Future<void> _editOffice(OfficeAddress? office) async {
    final values = await _askAddress(
      title: 'Office address',
      fields: [
        _AddressField('dept', 'Department', office?.department ?? ''),
        _AddressField('desig', 'Designation', office?.designation ?? ''),
        _AddressField('flat', 'Flat / room / floor', office?.flatNo ?? ''),
        _AddressField('door', 'Door / street / building', office?.doorNo ?? ''),
        _AddressField('pin', 'Pincode', office?.pincode ?? '',
            keyboardType: TextInputType.number, maxLength: 6),
        _AddressField('city', 'City', office?.city ?? ''),
        _AddressField('state', 'State', office?.state ?? ''),
      ],
    );
    if (values == null) return;
    if (!_addressOk(values, pinKey: 'pin', requiredKeys: [
      'dept',
      'desig',
      'flat',
      'door',
      'pin',
      'city',
      'state',
    ])) {
      return;
    }
    await _afterOtp(() async {
      final provider = context.read<AppStateProvider>();
      setState(() => _saving = true);
      final ok = await provider.updateOfficeAddress({
        ApiParams.customerId: provider.customerId,
        ApiParams.department: values['dept']!.trimLeft(),
        ApiParams.designation: values['desig']!.trimLeft(),
        ApiParams.flatNo: values['flat']!.trimLeft(),
        ApiParams.doorNo: values['door']!.trimLeft(),
        ApiParams.pincode: values['pin']!.trimLeft(),
        ApiParams.city: values['city']!.trimLeft(),
        ApiParams.state: values['state']!.trimLeft(),
      });
      if (!mounted) return;
      setState(() => _saving = false);
      if (ok) Utils.showToast(msg: LanguageHelper.textOfficeAddressUpdated);
    });
  }

  bool _addressOk(
    Map<String, String> values, {
    required String pinKey,
    List<String>? requiredKeys,
  }) {
    final keys = requiredKeys ?? ['door', 'pin', 'city', 'state'];
    final texts = keys.map((key) => values[key] ?? '').toList();
    if (texts.any((value) => value.trim().isEmpty)) {
      Utils.showToast(msg: LanguageHelper.textFillFields);
      return false;
    }
    if (texts.any((value) => value.isFollowedBySpace())) {
      Utils.showToast(msg: LanguageHelper.removeSpace);
      return false;
    }
    if (!(values[pinKey] ?? '').trim().isPincodeValid) {
      Utils.showToast(msg: LanguageHelper.textEnterPinCode);
      return false;
    }
    return true;
  }

  Future<void> _changePhoto() async {
    final useCamera = await showPbBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => const _PhotoSourceSheet(),
    );
    if (useCamera == null || !mounted) return;
    var file;
    try {
      file = useCamera
          ? await ImgPicker.pickAndCropFromCamera()
          : await ImgPicker.pickAndCropFromGallery();
    } catch (_) {
      if (mounted) {
        Utils.showToast(msg: 'Unable to open the camera or gallery.');
      }
      return;
    }
    if (file == null || !mounted) return;
    setState(() => _saving = true);
    final ok = await context.read<AppStateProvider>().uploadProfilePhoto(file.path);
    if (!mounted) return;
    setState(() => _saving = false);
    Utils.showToast(
      msg: ok ? 'Profile photo updated' : 'Could not upload the photo. Please try again.',
    );
  }

  Future<Map<String, String>?> _askAddress({
    required String title,
    required List<_AddressField> fields,
  }) {
    return showPbBottomSheet<Map<String, String>>(
      context: context,
      builder: (sheetContext) => _AddressEditSheet(title: title, fields: fields),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppStateProvider>().userDetails;
    final profile = user?.profileDetails;
    final pan = user?.panDetails;
    final bank = user?.bankAccountDetails;
    final home = user?.residenceAddress;
    final office = user?.officeAddress;
    final email = profile?.email ?? '';
    final phone = profile?.phoneNumber ?? '';
    final hasBank = _hasBank(bank);

    return Scaffold(
      backgroundColor: const Color(0xffF3F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
        titleSpacing: 0,
        title: Text('Profile Details', style: AppTextStyles.semiBold(18)),
      ),
      body: PeerBridgeLoader(
        isLoading: _saving,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _ProfileHeader(
              name: profile?.fullName ?? '',
              photoUrl: profile?.profileUrl ?? '',
              userId: context.read<AppStateProvider>().customerId,
              kycDone: _kycDone,
              percent: context.read<AppStateProvider>().getProfilePercentage(),
              onKyc: () => context.pushNamed(RoutesName.AadharVerification),
              onPhoto: _changePhoto,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            _SectionTitle('Basic information'),
            _Card(children: [
              _InfoRow(label: 'Full name', value: _orDash(profile?.fullName)),
              _InfoRow(label: 'Gender', value: _genderLabel(pan?.gender)),
              _InfoRow(label: 'Date of birth', value: _formatDob(pan?.dob)),
              _InfoRow(label: 'PAN', value: _orDash(pan?.pan.toUpperCase())),
              _InfoRow(
                label: 'Aadhaar number',
                value: _orDash(profile?.aadharNumber),
                onEdit: _kycDone
                    ? null
                    : () => _editAadhar(profile?.aadharNumber ?? ''),
              ),
            ]),
            _SectionTitle('Contact details'),
            _Card(children: [
              _InfoRow(
                label: 'Email address',
                value: _orDash(email),
                trailing: email.trim().isEmpty ? null : const _VerifiedPill(),
                onEdit: () => _editEmail(email),
              ),
              _InfoRow(
                label: 'Mobile number',
                value: _phoneLabel(phone),
                onEdit: () => _editPhone(phone),
              ),
            ]),
            _SectionTitle(
              'Bank account',
              action: '+ Add / Update Bank',
              onAction: () => context.pushNamed(RoutesName.BankDetail),
            ),
            if (!hasBank)
              const _Card(children: [
                _InfoRow(label: 'Bank account', value: 'Not added yet'),
              ])
            else
              _Card(children: [
                _InfoRow(label: 'Bank name', value: _orDash(bank?.bankName)),
                _InfoRow(label: 'Account type', value: _orDash(bank?.accountType)),
                _InfoRow(
                  label: 'Account number',
                  value: _maskAccount(bank?.accountNumber ?? ''),
                  trailing: const _PrimaryPill(),
                ),
                _InfoRow(label: 'IFSC code', value: _orDash(bank?.ifscCode)),
              ]),
            _SectionTitle(
              'Residence address',
              action: 'Update',
              onAction: () => _editResidence(home),
            ),
            _Card(children: [
              _InfoRow(label: 'Flat / room / floor', value: _orDash(home?.flatNo)),
              _InfoRow(label: 'Door / street', value: _orDash(home?.doorNo)),
              _InfoRow(label: 'Pincode', value: _orDash(home?.pincode)),
              _InfoRow(label: 'City', value: _orDash(home?.city)),
              _InfoRow(label: 'State', value: _orDash(home?.state)),
            ]),
            _SectionTitle(
              'Office address',
              action: 'Update',
              onAction: () => _editOffice(office),
            ),
            _Card(children: [
              _InfoRow(label: 'Department', value: _orDash(office?.department)),
              _InfoRow(label: 'Designation', value: _orDash(office?.designation)),
              _InfoRow(label: 'Flat / room / floor', value: _orDash(office?.flatNo)),
              _InfoRow(label: 'Door / street', value: _orDash(office?.doorNo)),
              _InfoRow(label: 'Pincode', value: _orDash(office?.pincode)),
              _InfoRow(label: 'City', value: _orDash(office?.city)),
              _InfoRow(label: 'State', value: _orDash(office?.state)),
            ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasBank(BankAccountDetails? bank) {
    if (bank == null) return false;
    final account = bank.accountNumber.trim();
    if (account.isEmpty) return false;
    if (account == '12989898989980' && bank.ifscCode.trim().isEmpty) return false;
    return true;
  }

  String _genderLabel(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.isEmpty) return '—';
    if (value.startsWith('m')) return 'Male';
    if (value.startsWith('f')) return 'Female';
    return raw!.trim();
  }

  String _orDash(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? '—' : text;
  }

  String _formatDob(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return '—';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(text));
    } catch (_) {}
    try {
      return DateFormat('dd/MM/yyyy').format(DateFormat('dd-MM-yyyy').parse(text));
    } catch (_) {}
    return text;
  }

  String _phoneLabel(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91 $digits';
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+91 ${digits.substring(2)}';
    }
    return _orDash(raw);
  }

  String _maskAccount(String raw) {
    final digits = raw.replaceAll(RegExp(r'\s'), '');
    if (digits.length <= 4) return _orDash(digits);
    return '•••• •••• ${digits.substring(digits.length - 4)}';
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String userId;
  final bool kycDone;
  final int percent;
  final VoidCallback onKyc;
  final VoidCallback onPhoto;

  const _ProfileHeader({
    required this.name,
    required this.photoUrl,
    required this.userId,
    required this.kycDone,
    required this.percent,
    required this.onKyc,
    required this.onPhoto,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final last = parts.length > 1 ? parts.last[0] : '';
    return (parts.first[0] + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final shown = percent.clamp(0, 100);
    final hasPhoto =
        photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HeaderAvatar(
                initials: _initials,
                photoUrl: hasPhoto ? photoUrl : '',
                onTap: onPhoto,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim().isEmpty ? '—' : name.trim().toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(16).copyWith(letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'USER ID · ${userId.trim().isEmpty ? '—' : userId.trim()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(11, color: AppColors.muted)
                                .copyWith(letterSpacing: 0.3),
                          ),
                        ),
                        IconButton(
                          onPressed: userId.trim().isEmpty
                              ? null
                              : () {
                                  Clipboard.setData(ClipboardData(text: userId.trim()));
                                  Utils.showToast(msg: 'User ID copied');
                                },
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: const Icon(Icons.copy_outlined,
                              size: 15, color: Color(0xff8B949E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: kycDone ? null : onKyc,
                      child: _KycPill(verified: kycDone),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile completion',
                  style: AppTextStyles.medium(13, color: AppColors.muted),
                ),
              ),
              Text('$shown%', style: AppTextStyles.semiBold(13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: shown / 100,
              minHeight: 6,
              backgroundColor: const Color(0xffE6E8EC),
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String initials;
  final String photoUrl;
  final VoidCallback onTap;

  const _HeaderAvatar({
    required this.initials,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(initials, style: AppTextStyles.semiBold(22, color: AppColors.ink)),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffF4F5F7),
              border: Border.all(color: const Color(0xffD9DDE3), width: 1.4),
            ),
            child: ClipOval(
              child: photoUrl.isEmpty
                  ? fallback
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => fallback,
                    ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xffE4E4E4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.edit_outlined, size: 13, color: AppColors.ink),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _KycPill extends StatelessWidget {
  final bool verified;

  const _KycPill({required this.verified});

  @override
  Widget build(BuildContext context) {
    final color = verified ? const Color(0xff1F8A4C) : AppColors.goldDark;
    final background = verified ? const Color(0xffE7F6EC) : AppColors.goldSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'KYC VERIFIED' : 'COMPLETE KYC',
            style: AppTextStyles.semiBold(10.5, color: color).copyWith(letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PbSheetTitle(title: 'Profile photo'),
          const SizedBox(height: 8),
          _PhotoChoice(
            icon: Icons.photo_camera_outlined,
            label: 'Open camera',
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 10),
          _PhotoChoice(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

class _PhotoChoice extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoChoice({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffF7F7F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.greenDeep),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.medium(15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.medium(12, color: AppColors.muted)
                  .copyWith(letterSpacing: 0.6),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                action!,
                style: AppTextStyles.semiBold(13, color: AppColors.green),
              ),
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffECEEF2)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xffEEF0F3)),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onEdit;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.medium(11, color: const Color(0xff9AA3AB))
                .copyWith(letterSpacing: 0.4),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(value, style: AppTextStyles.medium(15)),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xff8B949E)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green),
      ),
      child: Text('Verified', style: AppTextStyles.medium(12, color: AppColors.green)),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffE7F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Primary', style: AppTextStyles.medium(12, color: const Color(0xff3D7EFF))),
    );
  }
}

class _TextEditSheet extends StatefulWidget {
  final String title;
  final String initial;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool digitsOnly;

  const _TextEditSheet({
    required this.title,
    required this.initial,
    this.keyboardType,
    this.maxLength,
    this.digitsOnly = false,
  });

  @override
  State<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends State<_TextEditSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PbSheetTitle(title: widget.title),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            inputFormatters: widget.digitsOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            style: AppTextStyles.medium(16),
            decoration: InputDecoration(
              counterText: '',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffE4E4E4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PbPrimaryButton(
            label: 'Continue',
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
      ),
    );
  }
}

class _AddressField {
  final String key;
  final String label;
  final String initial;
  final TextInputType keyboardType;
  final int? maxLength;

  _AddressField(
    this.key,
    this.label,
    this.initial, {
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });
}

class _AddressEditSheet extends StatefulWidget {
  final String title;
  final List<_AddressField> fields;

  const _AddressEditSheet({required this.title, required this.fields});

  @override
  State<_AddressEditSheet> createState() => _AddressEditSheetState();
}

class _AddressEditSheetState extends State<_AddressEditSheet> {
  late final List<TextEditingController> _controllers = widget.fields
      .map((field) => TextEditingController(text: field.initial))
      .toList();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PbSheetTitle(title: widget.title),
          const SizedBox(height: 8),
          for (var i = 0; i < widget.fields.length; i++) ...[
            TextField(
              controller: _controllers[i],
              keyboardType: widget.fields[i].keyboardType,
              maxLength: widget.fields[i].maxLength,
              inputFormatters: widget.fields[i].keyboardType == TextInputType.number
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: AppTextStyles.medium(15),
              decoration: InputDecoration(
                counterText: '',
                hintText: widget.fields[i].label,
                hintStyle: AppTextStyles.regular(15, color: const Color(0xffB0B0B0)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffE4E4E4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.green),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          PbPrimaryButton(
            label: 'Continue',
            onPressed: () {
              final values = <String, String>{};
              for (var i = 0; i < widget.fields.length; i++) {
                values[widget.fields[i].key] = _controllers[i].text;
              }
              Navigator.of(context).pop(values);
            },
          ),
        ],
      ),
    );
  }
}

const rowSpacer = TableRow(children: [
  SizedBox(height: 8),
  SizedBox(height: 8),
]);
