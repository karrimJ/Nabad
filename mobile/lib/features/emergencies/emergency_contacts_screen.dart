import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import 'data/emergency_contact_model.dart';
import 'data/emergency_contact_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final EmergencyContactService _contactService = EmergencyContactService();

  bool _isCreatingSettings = false;

  Future<void> _callContact(String phoneNumber) async {
    final uri = Uri.parse('tel:${phoneNumber.trim()}');

    if (!await canLaunchUrl(uri)) {
      _showMessage('Could not open phone app');
      return;
    }

    await launchUrl(uri);
  }

  Future<void> _deleteContact(EmergencyContactModel contact) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Neutral.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Contact',
            style: AppTypography.headingSmall.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${contact.name}?',
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VitalRed.vitalRed500,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _contactService.deleteEmergencyContact(contact.id);

      if (!mounted) return;

      _showMessage('Contact deleted', isSuccess: true);
    } catch (error) {
      _showMessage(_cleanError(error));
    }
  }

  Future<void> _saveDefaultSettings() async {
    if (_isCreatingSettings) return;

    setState(() {
      _isCreatingSettings = true;
    });

    try {
      await _contactService.saveDefaultEmergencySettings();

      if (!mounted) return;

      setState(() {
        _isCreatingSettings = false;
      });

      _showMessage('Emergency settings saved', isSuccess: true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isCreatingSettings = false;
      });

      _showMessage(_cleanError(error));
    }
  }

  void _showContactDialog({EmergencyContactModel? contact}) {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController =
        TextEditingController(text: contact?.phoneNumber ?? '');
    final relationshipController =
        TextEditingController(text: contact?.relationship ?? '');
    final emailController = TextEditingController(text: contact?.email ?? '');
    final linkedUserIdController =
        TextEditingController(text: contact?.linkedUserId ?? '');
    final fcmTokenController =
        TextEditingController(text: contact?.fcmToken ?? '');

    bool isPrimary = contact?.isPrimary ?? false;
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Neutral.neutral100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> saveContact() async {
              if (!formKey.currentState!.validate()) return;

              setSheetState(() {
                isSaving = true;
              });

              final newContact = EmergencyContactModel(
                id: contact?.id ?? '',
                name: nameController.text,
                phoneNumber: phoneController.text,
                relationship: relationshipController.text,
                email: emailController.text,
                linkedUserId: linkedUserIdController.text,
                fcmToken: fcmTokenController.text,
                isPrimary: isPrimary,
              );

              try {
                if (contact == null) {
                  await _contactService.addEmergencyContact(newContact);
                } else {
                  await _contactService.updateEmergencyContact(newContact);
                }

                if (!mounted) return;

                Navigator.pop(sheetContext);
                _showMessage(
                  contact == null ? 'Contact added' : 'Contact updated',
                  isSuccess: true,
                );
              } catch (error) {
                setSheetState(() {
                  isSaving = false;
                });

                _showMessage(_cleanError(error));
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Neutral.neutral400,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        contact == null
                            ? 'Add Emergency Contact'
                            : 'Edit Emergency Contact',
                        style: AppTypography.headingSmall.copyWith(
                          color: Neutral.neutral900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: relationshipController,
                        label: 'Relationship',
                        icon: Icons.family_restroom,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Relationship is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: emailController,
                        label: 'Email Optional',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: linkedUserIdController,
                        label: 'Contact User UID Optional',
                        icon: Icons.link,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use this only if the emergency contact also has a Nabad account.',
                        style: AppTypography.bodySmall.copyWith(
                          color: Neutral.neutral600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: fcmTokenController,
                        label: 'FCM Token Optional',
                        icon: Icons.notifications,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isPrimary,
                        activeColor: VitalRed.vitalRed500,
                        title: Text(
                          'Primary Contact',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Neutral.neutral900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            isPrimary = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VitalRed.vitalRed500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isSaving ? null : saveContact,
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  contact == null
                                      ? 'Add Contact'
                                      : 'Save Changes',
                                  style: AppTypography.buttonText,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.bodyMedium.copyWith(
        color: Neutral.neutral900,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: VitalRed.vitalRed500,
        ),
        labelStyle: AppTypography.bodySmall.copyWith(
          color: Neutral.neutral600,
        ),
        filled: true,
        fillColor: Neutral.neutral300,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: VitalRed.vitalRed500,
          ),
        ),
      ),
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showMessage(String msg, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Success.success500 : VitalRed.vitalRed500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral300,
      appBar: AppBar(
        backgroundColor: Neutral.neutral300,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Neutral.neutral900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Emergency Contacts',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: VitalRed.vitalRed500,
        foregroundColor: Colors.white,
        onPressed: () => _showContactDialog(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Contact',
          style: AppTypography.buttonText,
        ),
      ),
      body: StreamBuilder<List<EmergencyContactModel>>(
        stream: _contactService.watchEmergencyContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: VitalRed.vitalRed500,
              ),
            );
          }

          if (snapshot.hasError) {
            return _errorState(snapshot.error.toString());
          }

          final contacts = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              _settingsCard(),
              const SizedBox(height: 16),
              if (contacts.isEmpty)
                _emptyState()
              else
                ...contacts.map(_contactCard),
            ],
          );
        },
      ),
    );
  }

  Widget _settingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: VitalRed.vitalRed100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: VitalRed.vitalRed500,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Enable SOS contact notifications',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _isCreatingSettings ? null : _saveDefaultSettings,
            child: _isCreatingSettings
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VitalRed.vitalRed500,
                    ),
                  )
                : Text(
                    'Enable',
                    style: AppTypography.bodyMedium.copyWith(
                      color: VitalRed.vitalRed500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(EmergencyContactModel contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: VitalRed.vitalRed100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.contact_emergency,
              color: VitalRed.vitalRed500,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Neutral.neutral900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: VitalRed.vitalRed100,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Primary',
                          style: AppTypography.label.copyWith(
                            color: VitalRed.vitalRed500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contact.relationship,
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phoneNumber,
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: Neutral.neutral100,
            icon: const Icon(
              Icons.more_vert,
              color: Neutral.neutral700,
            ),
            onSelected: (value) {
              if (value == 'call') {
                _callContact(contact.phoneNumber);
              }

              if (value == 'edit') {
                _showContactDialog(contact: contact);
              }

              if (value == 'delete') {
                _deleteContact(contact);
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'call',
                  child: Text('Call'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.contact_emergency,
            color: VitalRed.vitalRed500,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'No emergency contacts yet',
            style: AppTypography.bodyLarge.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add at least one contact so SOS can notify someone during emergencies.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: Neutral.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}