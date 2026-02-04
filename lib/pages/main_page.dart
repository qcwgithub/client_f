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

    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      RoomListState.instance?.getRecommendedRooms();
    });
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RoomListState state = context.watch<RoomListState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenes"),
        actions: [
          IconButton(
            onPressed: () {
              state.getRecommendedRooms();
            },
            icon: Icon(Icons.refresh),
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
                      state.getRecommendedRooms();
                    } else {
                      state.search(_searchQuery);
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: state.getRecommendedRooms,
              child: _buildList(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(RoomListState state) {
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
