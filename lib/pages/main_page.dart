import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/scene_room_info.dart';
import 'package:scene_hub/providers/enter_scene_provider.dart';
import 'package:scene_hub/providers/scene_list_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/scene_card.dart';
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

    sc.postFrameCallbackManager.register(() {
      ref.read(sceneListProvider.notifier).getRecommendedScenes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(sceneListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenes"),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(sceneListProvider.notifier).getRecommendedScenes();
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await sc.lifecycleManager.quit(context, ref);
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
                      ref
                          .read(sceneListProvider.notifier)
                          .getRecommendedScenes();
                    } else {
                      ref.read(sceneListProvider.notifier).search(_searchQuery);
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
                  .read(sceneListProvider.notifier)
                  .getRecommendedScenes,
              child: _buildList(model),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(SceneListModel model) {
    if (model.status == SceneListStatus.refreshing && model.roomInfos.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text("刷新中...")),
        ],
      );
    }

    if (model.status == SceneListStatus.empty ||
        model.status == SceneListStatus.error) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text("下拉刷新")),
        ],
      );
    }

    final EnterSceneModel enterSceneModel = ref.watch(enterSceneProvider);

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount:
              model.roomInfos.length +
              (model.status == SceneListStatus.refreshing ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (model.status == SceneListStatus.refreshing && index == 0) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: Text("刷新中...")),
              );
            }

            SceneRoomInfo roomInfo =
                model.roomInfos[index -
                    (model.status == SceneListStatus.refreshing ? 1 : 0)];

            return SceneCard(roomInfo: roomInfo);
          },
        ),

        if (enterSceneModel.status == EnterSceneStatus.loading)
          Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
      ],
    );
  }
}
