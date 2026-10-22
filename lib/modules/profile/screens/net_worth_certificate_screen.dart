import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:provider/provider.dart';

class NetWorthCertificateScreen extends StatefulWidget {
  const NetWorthCertificateScreen({Key? key}) : super(key: key);

  @override
  State<NetWorthCertificateScreen> createState() =>
      _NetWorthCertificateScreenState();
}

class _NetWorthCertificateScreenState extends State<NetWorthCertificateScreen> {
  bool uploading = false;
  PlatformFile? selectedFile;
  String? savedName;
  String status = '';
  String reviewNotes = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await context.read<AppStateProvider>().getNetWorthCertificate();
    if (!mounted) return;
    setState(() {
      savedName = data?['fileName']?.toString();
      status = data?['status']?.toString() ?? '';
      reviewNotes = data?['reviewNotes']?.toString() ?? '';
    });
  }

  Future<void> _pick() async {
    final file = await Utils.pickFile();
    if (file == null || !mounted) return;
    setState(() => selectedFile = file);
  }

  Future<void> _upload() async {
    final file = selectedFile;
    if (file == null) {
      Utils.showToast(msg: 'Choose a certificate to upload.');
      return;
    }
    setState(() => uploading = true);
    final error =
        await context.read<AppStateProvider>().uploadNetWorthCertificate(file);
    if (!mounted) return;
    setState(() => uploading = false);
    if (error != null) {
      Utils.showToast(msg: error);
      return;
    }
    setState(() {
      savedName = file.name;
      status = 'PENDING';
      reviewNotes = '';
      selectedFile = null;
    });
    Utils.showToast(msg: 'Uploaded. Waiting for approval.');
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'PENDING':
        return 'Waiting for approval';
      default:
        return 'Waiting for approval';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chosen = selectedFile?.name;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: PbPageHeader(
          title: 'Net worth certificate',
          onBack: () => context.pop(),
        ),
        body: PeerBridgeLoader(
          isLoading: uploading,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Text(
                'Upload a PDF, JPG, or PNG of your net worth certificate. The file can be up to 2 MB. It is reviewed after upload.',
                style: AppTextStyles.regular(14, color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              if ((savedName ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DetailListCard(
                    title: 'Current certificate',
                    rows: [
                      MapEntry('File', savedName!),
                      MapEntry('Status', _statusLabel(status)),
                      if (status == 'REJECTED' && reviewNotes.isNotEmpty)
                        MapEntry('Note', reviewNotes),
                    ],
                  ),
                ),
              PbCard(
                onTap: _pick,
                child: Row(
                  children: [
                    const Icon(Icons.upload_file_rounded,
                        color: AppColors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chosen ?? 'Choose a file',
                        style: AppTextStyles.semiBold(14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PbPrimaryButton(
                label: savedName == null ? 'Upload' : 'Replace certificate',
                onPressed: selectedFile == null ? null : _upload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
