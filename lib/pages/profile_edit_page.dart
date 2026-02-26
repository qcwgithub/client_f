import 'package:flutter/material.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_set_name.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/pages/avatar_pick_page.dart';
import 'package:scene_hub/sc.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  Widget build(BuildContext context) {
    final me = sc.me;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        children: [
          // ── 头像 ──
          ListTile(
            title: const Text('Avatar'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColorFor(me.userInfo.avatarIndex),
                  child: Text(
                    me.userName.isNotEmpty
                        ? me.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvatarPickPage()),
              );
              setState(() {});
            },
          ),

          const Divider(height: 1),

          // ── 名字 ──
          ListTile(
            title: const Text('Name'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  me.userName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showEditNameDialog(context),
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: sc.me.userName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName == null || newName.isEmpty || !mounted) return;
    if (newName == sc.me.userName) return;

    final res = await sc.server.request(
      MsgType.setName,
      MsgSetName(userName: newName),
    );

    if (!mounted) return;

    if (res.e == ECode.success) {
      sc.me.userInfo.userName = newName;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.e}')),
      );
    }
  }
}
