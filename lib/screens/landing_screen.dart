import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_bloc.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_event.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_state.dart';
import 'package:youtube_comment_picker/constants.dart';
import 'package:youtube_comment_picker/screens/landing_tab_controllers.dart';
import 'package:youtube_comment_picker/screens/widgets/landing_history_view.dart';
import 'package:youtube_comment_picker/screens/widgets/landing_search_tab_view.dart';
import 'package:youtube_comment_picker/screens/widgets/landing_tabs_header.dart';
import 'package:youtube_comment_picker/screens/widgets/landing_video_tab_view.dart';
import 'package:youtube_comment_picker/service_locator/service_locator.dart';

/// Entry point for the landing experience.
class LandingScreen extends StatelessWidget {
  /// Creates the landing screen with app title and version.
  const LandingScreen({
    super.key,
    required this.title,
    required this.appVersion,
  });

  final String title;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<LandingBloc>(),
      child: _LandingScreenView(
        title: title,
        appVersion: appVersion,
      ),
    );
  }
}

class _LandingScreenView extends StatefulWidget {
  const _LandingScreenView({
    required this.title,
    required this.appVersion,
  });

  final String title;
  final String appVersion;

  @override
  State<_LandingScreenView> createState() => _LandingScreenViewState();
}

class _LandingScreenViewState extends State<_LandingScreenView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final LandingTabControllers _tabControllers = LandingTabControllers();

  @override
  void initState() {
    super.initState();
    context.read<LandingBloc>().add(const LandingStarted());
  }

  @override
  void dispose() {
    _disposeTabController();
    _tabControllers.dispose();
    super.dispose();
  }

  void _disposeTabController() {
    _tabController?.removeListener(_handleTabIndexChange);
    _tabController?.dispose();
    _tabController = null;
  }

  void _handleTabIndexChange() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) {
      return;
    }

    context
        .read<LandingBloc>()
        .add(LandingTabIndexChanged(index: controller.index));
  }

  void _syncTabController(LandingState state) {
    if (state.tabs.isEmpty) {
      _disposeTabController();
      return;
    }

    final desiredIndex = state.activeTabIndex.clamp(0, state.tabs.length - 1);

    if (_tabController == null || _tabController!.length != state.tabs.length) {
      _disposeTabController();
      _tabController = TabController(
        length: state.tabs.length,
        vsync: this,
        initialIndex: desiredIndex,
      )..addListener(_handleTabIndexChange);
      return;
    }

    if (_tabController!.index != desiredIndex &&
        !_tabController!.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _tabController?.animateTo(desiredIndex);
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        shape: const RoundedRectangleBorder(),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LandingBloc, LandingState>(
      listenWhen: (previous, current) {
        return previous.messageId != current.messageId &&
            current.message != null;
      },
      listener: (context, state) {
        final message = state.message;
        if (message == null) {
          return;
        }
        _showError(message);
        context.read<LandingBloc>().add(const LandingMessageConsumed());
      },
      builder: (context, state) {
        _tabControllers.sync(state);
        _syncTabController(state);

        return Scaffold(
          backgroundColor: kColorBackground,
          appBar: AppBar(
            title: Text.rich(
              TextSpan(
                text: widget.title,
                style: const TextStyle(
                  color: kColorText,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '  v${widget.appVersion}',
                    style: const TextStyle(
                      color: kColorTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: false,
            backgroundColor: kColorBackground,
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kColorBackground,
                  kColorSurface,
                  kColorBackground,
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                if (state.tabs.isEmpty)
                  LandingHistoryView(
                    history: state.history,
                    onAddSearchTab: () {
                      context
                          .read<LandingBloc>()
                          .add(const LandingAddSearchTabRequested());
                    },
                    onClearHistory: () {
                      context
                          .read<LandingBloc>()
                          .add(const LandingClearHistoryRequested());
                    },
                    onRemoveHistoryItem: (item) {
                      context.read<LandingBloc>().add(
                            LandingRemoveHistoryItemRequested(item: item),
                          );
                    },
                    onOpenHistoryItem: (item) {
                      context
                          .read<LandingBloc>()
                          .add(LandingHistoryOpened(item: item));
                    },
                  )
                else ...[
                  LandingTabsHeader(
                    tabController: _tabController!,
                    titles: state.tabs.map((tab) => tab.title).toList(),
                    onAddSearchTab: () {
                      context
                          .read<LandingBloc>()
                          .add(const LandingAddSearchTabRequested());
                    },
                    onCloseTab: (index) {
                      final tabId = state.tabs[index].id;
                      context
                          .read<LandingBloc>()
                          .add(LandingCloseTabRequested(tabId: tabId));
                    },
                    onTabSelected: (index) {
                      context
                          .read<LandingBloc>()
                          .add(LandingTabIndexChanged(index: index));
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: state.tabs.map((tab) {
                        if (tab is LandingSearchTab) {
                          final controller =
                              _tabControllers.searchControllerFor(tab.id)!;
                          return KeyedSubtree(
                            key: ValueKey('search-${tab.id}'),
                            child: LandingSearchTabView(
                              controller: controller,
                              onSearch: () {
                                context.read<LandingBloc>().add(
                                      LandingSearchSubmitted(
                                        tabId: tab.id,
                                        query: controller.text,
                                      ),
                                    );
                              },
                            ),
                          );
                        }

                        final videoTab = tab as LandingVideoTab;
                        final controller =
                            _tabControllers.playerControllerFor(videoTab.id);
                        final filterController =
                            _tabControllers.filterControllerFor(videoTab.id)!;

                        return KeyedSubtree(
                          key: ValueKey('video-${videoTab.id}'),
                          child: LandingVideoTabView(
                            videoId: videoTab.videoId,
                            videoInfo: videoTab.videoInfo,
                            controller: controller,
                            filterController: filterController,
                            allComments: videoTab.allComments,
                            filteredComments: videoTab.filteredComments,
                            isLoading: videoTab.isLoading,
                            onFilterChanged: (term) {
                              context.read<LandingBloc>().add(
                                    LandingFilterChanged(
                                      tabId: videoTab.id,
                                      term: term,
                                    ),
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
