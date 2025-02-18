import 'package:flutter/material.dart';
import '../api/chat_api.dart';
import '../entity/user.dart';

class UserIconWidget extends StatefulWidget {
  final int userId;
  final double size;
  final BoxShape shape;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const UserIconWidget({
    super.key,
    required this.userId,
    this.size = 40,
    this.shape = BoxShape.circle,
    this.backgroundColor,
    this.margin,
    this.onTap,
  });

  @override
  State<UserIconWidget> createState() => _UserIconWidgetState();
}

class _UserIconWidgetState extends State<UserIconWidget> {
  final _chatApi = ChatApi();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void didUpdateWidget(UserIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _chatApi.getUser(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Failed to load user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        margin: widget.margin,
        decoration: BoxDecoration(
          shape: widget.shape,
          color: widget.backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : _user?.avatarUrl != null
                ? ClipRRect(
                    borderRadius: widget.shape == BoxShape.circle
                        ? BorderRadius.circular(widget.size / 2)
                        : BorderRadius.zero,
                    child: Image.network(
                      _user!.avatarUrl!,
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      size: widget.size * 0.6,
      color: Theme.of(context).primaryColor,
    );
  }
}
