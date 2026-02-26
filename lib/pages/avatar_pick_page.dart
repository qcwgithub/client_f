import 'package:flutter/material.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_set_avatar_index.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/sc.dart';

/// 20 种预设头像颜色，通过 index 取色
const List<Color> avatarColors = [
  Color(0xFFE57373), // 0  红
  Color(0xFFF06292), // 1  粉
  Color(0xFFBA68C8), // 2  紫
  Color(0xFF9575CD), // 3  深紫
  Color(0xFF7986CB), // 4  靛蓝
  Color(0xFF64B5F6), // 5  蓝
  Color(0xFF4FC3F7), // 6  浅蓝
  Color(0xFF4DD0E1), // 7  青
  Color(0xFF4DB6AC), // 8  蓝绿
  Color(0xFF81C784), // 9  绿
  Color(0xFFAED581), // 10 浅绿
  Color(0xFFDCE775), // 11 酸橙
  Color(0xFFFFF176), // 12 黄
  Color(0xFFFFD54F), // 13 琥珀
  Color(0xFFFFB74D), // 14 橙
  Color(0xFFFF8A65), // 15 深橙
  Color(0xFFA1887F), // 16 棕
  Color(0xFF90A4AE), // 17 蓝灰
  Color(0xFFE0E0E0), // 18 灰
  Color(0xFF78909C), // 19 深蓝灰
];

/// 根据 avatarIndex 获取颜色（越界则取第一个）
Color avatarColorFor(int index) {
  if (index < 0 || index >= avatarColors.length) return avatarColors[0];
  return avatarColors[index];
}

class AvatarPickPage extends StatefulWidget {
  const AvatarPickPage({super.key});

  @override
  State<AvatarPickPage> createState() => _AvatarPickPageState();
}

class _AvatarPickPageState extends State<AvatarPickPage> {
  late int _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = sc.me.userInfo.avatarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Avatar'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _onSave,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: avatarColors.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final isSelected = index == _selected;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = index);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: avatarColors[index],
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.indigo, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSave() async {
    if (_selected == sc.me.userInfo.avatarIndex) {
      Navigator.pop(context);
      return;
    }

    setState(() => _saving = true);

    final res = await sc.server.request(
      MsgType.setAvatarIndex,
      MsgSetAvatarIndex(avatarIndex: _selected),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (res.e == ECode.success) {
      sc.me.userInfo.avatarIndex = _selected;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.e}')),
      );
    }
  }
}
