import 'package:appchat/features/account/screens/edit_user_information_screen.dart';
import 'package:appchat/features/auth/controller/auth_controller.dart';
import 'package:appchat/features/call/screens/call_pickup_screen.dart';
import 'package:appchat/features/group/screens/create_group_screen.dart';
import 'package:appchat/features/select_contacts/screens/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:appchat/colors.dart';
import 'package:appchat/features/chat/widgets/contacts_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  static const String routeName = '/mobile-layout-screen';
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen> 
  with WidgetsBindingObserver, TickerProviderStateMixin {
    late TabController tabBarController;
    final TextEditingController searchController = TextEditingController();

    @override
  void initState() {    
    super.initState();
    tabBarController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

   void toggleSearchVisibility() {  
    setState(() {
      isSearchVisible = !isSearchVisible;
    });    
  }

  bool isSearchVisible = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MobileLayoutScreen(),
              ),
            );
          },
          child: Text(
            isSearchVisible ? '' : 'AppChat',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: toggleSearchVisibility,
            ),
            if (isSearchVisible) ...[
              SizedBox(                
                width: size.width * 0.7, // Set the desired width
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    hintText: 'Search...',                    
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
            PopupMenuButton(itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text(
                  'Create Group'
                ),
                onTap: () => Future(
                  () => Navigator.pushNamed(
                    context, 
                    CreateGroupScreen.routeName
                  ),                  
                ),               
              ),
              PopupMenuItem(
                child: const Text(
                  'Account'
                ),
                onTap: () => Future(
                  () => Navigator.pushNamed(
                    context, 
                    EditUserInformation.routeName
                  ),                  
                ),               
              )
            ])
          ],
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(
                text: 'CHATS',
              ),              
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: [
            ContactsList(search: searchController.text.trim()), 
            ContactsList(search: searchController.text.trim()),          
          ] 
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){ 
              Navigator.pushNamed(context, ContactSelectScreen.routeName);  
          },
          backgroundColor: tabColor,
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
      ),
    ));
  }
}
