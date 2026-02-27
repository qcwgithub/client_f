import 'package:flutter/material.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/gen/msg_get_user_brief_infos.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_user_brief_infos.dart';
import 'package:scene_hub/gen/user_brief_info.dart';
import 'package:scene_hub/pages/avatar_pick_page.dart';
import 'package:scene_hub/pages/user_info_page.dart';
import 'package:scene_hub/sc.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final Map<int, UserBriefInfo> _briefInfos = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBriefInfos();
  }

  Future<void> _loadBriefInfos() async {
    final friends = sc.me.userInfo.friends;
    if (friends.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final userIds = friends.map((f) => f.userId).toSet();
    final r = await sc.server.request(
      MsgType.getUserBriefInfos,
      MsgGetUserBriefInfos(userIds: userIds),
    );

    if (!mounted) return;

    if (r.e == ECode.success && r.res != null) {
      final brief = ResGetUserBriefInfos.fromMsgPack(r.res!);
      for (final info in brief.userBriefInfos) {
        _briefInfos[info.userId] = info;
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final friends = sc.me.userInfo.friends;

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
              ? const Center(child: Text('No friends yet'))
              : ListView.separated(
                  itemCount: friends.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildFriendItem(context, friends[index]);
                  },
                ),
    );
  }

  Widget _buildFriendItem(BuildContext context, FriendInfo friend) {
    final brief = _briefInfos[friend.userId];
    final name = brief?.userName ?? 'User ${friend.userId}';
    final avatarIndex = brief?.avatarIndex ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: avatarColorFor(avatarIndex),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserInfoPage(
              userId: friend.userId,
              userName: name,
              senderAvatarIndex: avatarIndex,
            ),
          ),
        );
      },
    );
  }
}
