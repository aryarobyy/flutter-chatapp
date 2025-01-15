part of 'contact.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String? _currentUserId;
  final AuthService _auth = AuthService();
  final ChatService _chat = ChatService();
  String _searchQuery = '';
  bool _isSearching = false;
  String _groupName = '';

  final List<String> _addedUsers = [];
  LocalStorage? localStorage;
  bool isStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    try {
      final userId = await _auth.getCurrentUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error getting current user ID: $e');
    }
  }

  void _onPressed() async {
    try {
      final user = _auth.getUserById(_currentUserId as String);
      final userData = await user.first;
      final _currentEmail = userData.email;

      if (_searchController.text.toLowerCase() == _currentEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot add yourself')),
        );
        return;
      }
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _isSearching = true;
      });
    } catch (e) {
      print("Error $e");
    }
  }

  void _addUser(String user) {
    if (!_addedUsers.contains(user)) {
      setState(() {
        _addedUsers.add(user);
      });
    }
  }

  void _removeUser(String user) {
    setState(() {
      _addedUsers.remove(user);
    });
  }

  Future<void> handleCreateRoom({required List<String> userIds, bool isGroup = false}) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not initialized')),
      );
      return;
    }

    try {
      final currentUserId = await _auth.getCurrentUserId();

      List<String> members = [currentUserId, ...userIds];

      if (members.length <= 2) {
        showSnackBar(context, "Minimal 2 user");
        return;
      }

      final isGroup = members.length > 2;
      final groupName = await _buildGroupName(context);

      await _chat.createRoom(
        roomName: groupName,
        member: members,
        isGroup: isGroup ?? false,
      );
      if (!mounted) return;

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chat room: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MySearchBar(
                      controller: _searchController,
                      hintText: "Search for users by email...",
                      onPressed: _onPressed,
                      onSubmitted: (value) {
                        _searchController.text = value;
                        _onPressed();
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchContact()),
                      );
                    },
                    icon: Icon(Icons.cancel_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: _build(context),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 1,
                child: _buildAddedUsers(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build(BuildContext context){
    return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
            ),
        ],
      ),
      child: _buildSearchResults(context),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchQuery.isEmpty) {
      return Center(child: Text("No user searched"));
    }
    return StreamBuilder<UserModel?>(
      stream: _auth.getUserByEmail(_searchQuery.toLowerCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No user found."));
        }

        final UserModel user = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Search Results",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.green,
                onPressed: () => _addUser(user.uid),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddedUsers(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Added Members",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _addedUsers.isEmpty
                ? Center(
              child: Text(
                "No participants added.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: _addedUsers.length,
              itemBuilder: (context, index) {
                final userId = _addedUsers[index];
                return FutureBuilder<UserModel?>(
                  future: _auth.getUserById(userId).first,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text("Loading..."),
                      );
                    }
                    if (snapshot.hasError) {
                      return const ListTile(
                        title: Text("Error loading user."),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const ListTile(
                        title: Text("User not found."),
                      );
                    }

                    final user = snapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        onPressed: () => _removeUser(userId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: MyButton2(
              text: "Create Group",
              onPressed: () => handleCreateRoom(
                userIds: _addedUsers,
                isGroup: true, // Indicates a group creation
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _buildGroupName(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {

        return MyAlert(
          controller: _textController,
          onCancel: () {
            Navigator.of(context).pop(null);
          },
          onSave: () {
            final groupName = _textController.text.trim();
            if (groupName.isNotEmpty) {
              setState(() {
                _groupName = groupName;
              });
              Navigator.of(context).pop(groupName);
              _textController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Group name cannot be empty")),
              );
            }
          },
        );
      },
    );
  }

}