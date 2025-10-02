import 'package:bloc_clean_architecture/src/comman/enum.dart';
import 'package:bloc_clean_architecture/src/domain/entities/user_entity.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/user_list/user_list_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/page/user_details/user_details_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/widget/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserListBloc>().add(const GetUsersEvent());
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
                duration: const Duration(seconds: 3),
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
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadedState(BuildContext context, UserListState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserListBloc>().add(const RefreshUsers());
      },
      child: ListView.builder(
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(context, state.users[index]);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, UserListState state) {
    return Center(
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
    );
  }

  Widget _buildUserCard(BuildContext context, UserEntity user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        title: Text(
          user.name,
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
          _navigateToUserDetails(context, user);
        },
      ),
    );
  }

  void _showCallDialog(BuildContext context, UserEntity user) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${user.name}?'),
        content: Text('Start a video call with ${user.name}?'),
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
                  content: Text('Starting call with ${user.name}...'),
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetails(BuildContext context, UserEntity user) {
    Navigator.of(context).push(
      MaterialPageRoute<UserDetailsScreen>(
        builder: (context) => UserDetailsScreen(user: user),
      ),
    );
  }
}
