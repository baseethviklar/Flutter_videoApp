// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../providers/video_provider.dart';
import '../providers/likes_provider.dart';
import '../widgets/video_item.dart';
import '../widgets/video_grid_item.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _initData();
      _isInit = false;
    }
  }

  Future<void> _initData() async {
    await Provider.of<LikesProvider>(context, listen: false).initialize();
    await Provider.of<VideoProvider>(context, listen: false).fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video App'),
      ),
      body: RefreshIndicator(
        onRefresh: () => videoProvider.fetchVideos(),
        child: videoProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : videoProvider.error != null
                ? Center(child: Text(videoProvider.error!))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine if we should show grid or list based on screen width
                      final isWideScreen = constraints.maxWidth > 600;
                      
                      if (isWideScreen) {
                        // Grid view for tablets and web
                        return GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                            childAspectRatio: 16 / 9,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: videoProvider.videos.length,
                          itemBuilder: (ctx, i) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => VideoPlayerScreen(
                                    video: videoProvider.videos[i],
                                  ),
                                ),
                              );
                            },
                            child: VideoGridItem(video: videoProvider.videos[i]),
                          ),
                        );
                      } else {
                        // List view for mobile
                        return ListView.builder(
                          itemCount: videoProvider.videos.length,
                          itemBuilder: (ctx, i) => VideoItem(
                            video: videoProvider.videos[i],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => VideoPlayerScreen(
                                    video: videoProvider.videos[i],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
      ),
    );
  }
}
