part of 'contact.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentUserId;
  String? _selectedUserId;
  final AuthService _auth = AuthService();

  final List<String> _searchResults = ["User 1", "User 2", "User 3"];
  final List<String> _addedUsers = [];
  LocalStorage? localStorage;
  bool isStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
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

  Future<void> _initializeStorage() async {
    try {
      final storage = LocalStorage('group_add');
      final isReady = await storage.ready;
      if (isReady) {
        setState(() {
          localStorage = storage;
          isStorageInitialized = true;
        });
      } else {
        print("Failed to initialize LocalStorage");
      }
    } catch (e) {
      print("Error initializing storage: $e");
    }
  }

  void _onPressed() {
    try {
      final user = _auth.getUserById(_currentUserId as String);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySearchBar(
                controller: _searchController,
                hintText: "Search for users by email...",
                onPressed: _onPressed,
                onSubmitted: (value) {
                  _searchController.text = value;
                  _onPressed();
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 1,
                child: _buildSearchResults(context),
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

  Widget _buildSearchResults(BuildContext context) {
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
            "Search Results",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // List of search results
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      "No results found.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            user[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user,
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.green,
                          onPressed: () => _addUser(user),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
            "Added Participants",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // List of added users
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
                      final user = _addedUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            user[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user,
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: () => _removeUser(user),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
