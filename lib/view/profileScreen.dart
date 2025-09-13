import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
import 'auth_screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();

  bool _didSetInitialValues = false;
  bool _isEditingProfile = false;
  bool _isAddingAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final uid = authProvider.user?.uid;
      if (uid != null) {
        userProvider.loadUser(uid);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didSetInitialValues) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _didSetInitialValues = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Profile", style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: colorScheme.error,
            onPressed: () async {
              final shouldSignOut = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm Sign Out"),
                  content: const Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: const Text("Sign Out"),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (shouldSignOut == true) {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
          )
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text("User not found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Info", style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              label: "Name",
              icon: Icons.person,
              enabled: _isEditingProfile,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _phoneController,
              label: "Phone",
              icon: Icons.phone,
              enabled: _isEditingProfile,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.email),
              title: Text(user.email, style: theme.textTheme.bodyLarge),
              subtitle: const Text("Email (not editable)"),
              tileColor: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),

            const SizedBox(height: 16),

            _isEditingProfile
                ? ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Profile"),
              onPressed: () async {
                final updatedUser = user.copyWith(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                );
                await userProvider.updateUserDetails(updatedUser);
                setState(() => _isEditingProfile = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Profile updated successfully!"),
                    backgroundColor: colorScheme.onSurface,
                  ),
                );
              },
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              onPressed: () => setState(() => _isEditingProfile = true),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            Text("Addresses", style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: user.addresses.length,
              itemBuilder: (context, index) {
                final address = user.addresses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address.label, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(address.address, style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (address.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Current",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                child: const Text("Set Current"),
                                onPressed: () => _setCurrentAddress(index),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: colorScheme.error,
                                tooltip: 'Delete Address',
                                onPressed: () => _confirmDeleteAddress(index),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _isAddingAddress
                ? Column(
              children: [
                _buildTextField(
                  controller: _labelController,
                  label: "Label (e.g. Home, Work)",
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _addressController,
                  label: "Address",
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Address"),
                  onPressed: _addAddress,
                )
              ],
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add New Address"),
              onPressed: () => setState(() => _isAddingAddress = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _addAddress() async {
    final label = _labelController.text.trim();
    final address = _addressController.text.trim();
    if (label.isEmpty || address.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;

    final updated = [
      ...user.addresses,
      AddressModel(address: address, label: label),
    ];

    await userProvider.updateAddresses(updated);
    _labelController.clear();
    _addressController.clear();

    setState(() => _isAddingAddress = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Address added successfully!"),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Future<void> _setCurrentAddress(int index) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;

    final updated = user.addresses.asMap().entries.map((entry) {
      final i = entry.key;
      final addr = entry.value;
      return AddressModel(
        address: addr.address,
        label: addr.label,
        isCurrent: i == index,
      );
    }).toList();

    await userProvider.updateAddresses(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Default address updated!"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Future<void> _confirmDeleteAddress(int index) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user!;
      final updated = [...user.addresses]..removeAt(index);
      await userProvider.updateAddresses(updated);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}