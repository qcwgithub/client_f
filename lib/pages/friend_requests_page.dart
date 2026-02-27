import 'package:flutter/material.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/friend_request_result.dart';
import 'package:scene_hub/gen/incoming_friend_request.dart';
import 'package:scene_hub/gen/msg_accept_friend_request.dart';
import 'package:scene_hub/gen/msg_get_user_brief_infos.dart';
import 'package:scene_hub/gen/msg_reject_friend_request.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_accept_friend_request.dart';
import 'package:scene_hub/gen/res_get_user_brief_infos.dart';
import 'package:scene_hub/gen/user_brief_info.dart';
import 'package:scene_hub/pages/avatar_pick_page.dart';
import 'package:scene_hub/sc.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  /// userId -> UserBriefInfo 缓存
  final Map<int, UserBriefInfo> _briefInfos = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBriefInfos();
  }

  Future<void> _loadBriefInfos() async {
    final requests = sc.me.userInfo.incomingFriendRequests;
    if (requests.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final userIds = requests.map((r) => r.fromUserId).toSet();
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
    final requests = sc.me.userInfo.incomingFriendRequests;

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text('No friend requests'))
          : ListView.separated(
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildRequestItem(context, requests[index]);
              },
            ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context,
    IncomingFriendRequest request,
  ) {
    final brief = _briefInfos[request.fromUserId];
    final name = brief?.userName ?? 'User ${request.fromUserId}';
    final avatarIndex = brief?.avatarIndex ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: request.say.isNotEmpty
          ? Text(request.say, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      trailing: _buildTrailing(context, request),
    );
  }

  Widget _buildTrailing(BuildContext context, IncomingFriendRequest request) {
    switch (request.result) {
      case FriendRequestResult.wait:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Accept',
              onPressed: () => _accept(context, request),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'Reject',
              onPressed: () => _reject(context, request),
            ),
          ],
        );

      case FriendRequestResult.accepted:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.green, size: 20),
            SizedBox(width: 4),
            Text('Accepted', style: TextStyle(color: Colors.green)),
          ],
        );

      case FriendRequestResult.rejected:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, color: Colors.grey, size: 20),
            SizedBox(width: 4),
            Text('Rejected', style: TextStyle(color: Colors.grey)),
          ],
        );
    }
  }

  void _accept(BuildContext context, IncomingFriendRequest request) async {
    final r = await sc.server.request(
      MsgType.acceptFriendRequest,
      MsgAcceptFriendRequest(fromUserId: request.fromUserId),
    );

    if (!mounted) return;

    if (r.e == ECode.success && r.res != null) {
      request.result = FriendRequestResult.accepted;

      // 解析返回的 FriendInfo 并加入好友列表
      final resData = ResAcceptFriendRequest.fromMsgPack(r.res!);
      sc.friendManager.addFriend(resData.friendInfo);

      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request accepted')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: ${r.e}')));
    }
  }

  void _reject(BuildContext context, IncomingFriendRequest request) async {
    final r = await sc.server.request(
      MsgType.rejectFriendRequest,
      MsgRejectFriendRequest(fromUserId: request.fromUserId),
    );

    if (!mounted) return;

    if (r.e == ECode.success) {
      request.result = FriendRequestResult.rejected;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request rejected')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: ${r.e}')));
    }
  }
}
