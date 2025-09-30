import 'package:bloc_clean_architecture/src/comman/enum.dart';
import 'package:bloc_clean_architecture/src/domain/entities/user_entity.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/user_list/user_list_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/widget/custom_elevated_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UserListBloc>().add(const GetUsersEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UserListBloc>().add(const LoadMoreUsers());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<UserListBloc>().add(const RefreshUsers());
            },
          ),
        ],
      ),
      body: BlocConsumer<UserListBloc, UserListState>(
        listener: (context, state) {
          if (state.state == RequestState.error && state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserListState state) {
    switch (state.state) {
      case RequestState.empty:
        return const Center(child: CircularProgressIndicator());

      case RequestState.loading:
        return _buildLoadingState(context, state);

      case RequestState.loaded:
        return _buildLoadedState(context, state);

      case RequestState.error:
        return _buildErrorState(context, state);
    }
  }

  Widget _buildLoadingState(BuildContext context, UserListState state) {
    // If we have cached users, show them while loading
    if (state.cachedUsers != null && state.cachedUsers!.isNotEmpty) {
      return _buildLoadedState(
        context,
        state.copyWith(users: state.cachedUsers!),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadedState(BuildContext context, UserListState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserListBloc>().add(const RefreshUsers());
      },
      child: Column(
        children: [
          if (state.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Offline mode - showing cached data',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.users.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildUserCard(context, state.users[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, UserListState state) {
    return Column(
      children: [
        Expanded(
          child: state.cachedUsers != null && state.cachedUsers!.isNotEmpty
              ? ListView.builder(
                  itemCount: state.cachedUsers!.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(context, state.cachedUsers![index]);
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load users',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: GoogleFonts.roboto(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomElevatedButton(
                        onTap: () {
                          context.read<UserListBloc>().add(
                            const RefreshUsers(),
                          );
                        },
                        label: 'Retry',
                      ),
                    ],
                  ),
                ),
        ),
        if (state.cachedUsers != null && state.cachedUsers!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing cached data. Pull to refresh when online.',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserEntity user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.avatar,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60,
                height: 60,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user.email,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.videocam, color: Theme.of(context).primaryColor),
          onPressed: () {
            _showCallDialog(context, user);
          },
        ),
        onTap: () {
          _showUserDetails(context, user);
        },
      ),
    );
  }

  void _showCallDialog(BuildContext context, UserEntity user) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${user.firstName} ${user.lastName}?'),
        content: Text('Start a video call with ${user.firstName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to video call screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting call with ${user.firstName}...'),
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserEntity user) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.avatar,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            Text('ID: ${user.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCallDialog(context, user);
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
