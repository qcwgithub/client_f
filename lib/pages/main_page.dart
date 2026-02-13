import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/providers/enter_room_provider.dart';
import 'package:scene_hub/providers/room_list_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/room_card.dart';
import 'package:flutter/material.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      ref.read(roomListProvider.notifier).getRecommendedRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(roomListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenes"),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(roomListProvider.notifier).getRecommendedRooms();
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              sc.server.close();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search scenes",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_searchQuery.isEmpty) {
                      ref.read(roomListProvider.notifier).getRecommendedRooms();
                    } else {
                      ref.read(roomListProvider.notifier).search(_searchQuery);
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: ref
                  .read(roomListProvider.notifier)
                  .getRecommendedRooms,
              child: _buildList(model),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(RoomListModel model) {
    if (model.status == RoomListStatus.refreshing && model.roomInfos.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text("刷新中...")),
        ],
      );
    }

    if (model.status == RoomListStatus.empty ||
        model.status == RoomListStatus.error) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text("下拉刷新")),
        ],
      );
    }

    final EnterRoomModel enterRoomModel = ref.watch(enterRoomProvider);

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount:
              model.roomInfos.length +
              (model.status == RoomListStatus.refreshing ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (model.status == RoomListStatus.refreshing && index == 0) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: Text("刷新中...")),
              );
            }

            RoomInfo roomInfo =
                model.roomInfos[index -
                    (model.status == RoomListStatus.refreshing ? 1 : 0)];

            return RoomCard(roomInfo: roomInfo);
          },
        ),

        if (enterRoomModel.status == EnterRoomStatus.loading)
          Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
      ],
    );
  }
}
