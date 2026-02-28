import 'package:flutter/material.dart';
import 'package:scene_hub/pages/avatar_pick_page.dart';
import 'package:scene_hub/pages/friend_list_page.dart';
import 'package:scene_hub/pages/friend_requests_page.dart';
import 'package:scene_hub/pages/profile_edit_page.dart';
import 'package:scene_hub/sc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final me = sc.me;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // ── 第一项：头像 + 名字 ──
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: avatarColorFor(me.userInfo.avatarIndex),
              child: Text(
                me.userName.isNotEmpty
                    ? me.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              me.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('ID: ${me.userId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditPage()),
              );
              setState(() {});
            },
          ),

          const Divider(height: 1),

          // ── 好友列表 ──
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Friends'),
            subtitle: Text('${me.userInfo.friends.length} friends'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendListPage()),
              );
            },
          ),

          // ── 好友请求 ──
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Friend Requests'),
            subtitle: Text(
              '${me.userInfo.incomingFriendRequests.length} incoming',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendRequestsPage()),
              );
            },
          ),

          // ── 黑名单 ──
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Users'),
            subtitle: Text('${me.userInfo.blockedUsers.length} blocked'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 跳转到黑名单页
            },
          ),

          const Divider(height: 1),

          // ── 设置 ──
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 跳转到设置页
            },
          ),

          // ── 退出登录 ──
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ) ?? false;

              if (!ok || !context.mounted) return;
              await sc.lifecycleManager.quit();
            },
          ),
        ],
      ),
    );
  }
}