import 'package:provider/provider.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/providers/room_list_state.dart';
import 'package:scene_hub/widgets/scene_card.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoomListState.instance?.getRecommendedRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    RoomListState state = context.watch<RoomListState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Scenes")),
      body: RefreshIndicator(
        onRefresh: state.getRecommendedRooms,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RoomListState state) {
    if (state.status == RoomListStatus.refreshing && state.roomInfos.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text("刷新中...")),
        ],
      );
    }

    if (state.status == RoomListStatus.empty ||
        state.status == RoomListStatus.error) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text("下拉刷新")),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount:
          state.roomInfos.length +
          (state.status == RoomListStatus.refreshing ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (state.status == RoomListStatus.refreshing && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: Text("刷新中...")),
          );
        }

        RoomInfo roomInfo =
            state.roomInfos[index -
                (state.status == RoomListStatus.refreshing ? 1 : 0)];

        return SceneCard(title: roomInfo.title, subtitle: roomInfo.desc);
      },
    );
  }
}
