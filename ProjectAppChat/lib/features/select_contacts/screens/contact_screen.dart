import 'package:appchat/colors.dart';
import 'package:appchat/features/select_contacts/screens/search_contacts.dart';
import 'package:appchat/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:flutter/material.dart';

class ContactSelectScreen extends StatefulWidget {
  static const String routeName = '/select-contact-screen';
  const ContactSelectScreen({Key? key}) : super(key: key);
  

  @override
  State<ContactSelectScreen> createState() => _ContactSelectScreenState();
}

class _ContactSelectScreenState extends State<ContactSelectScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
    final TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
      ),
      body: _currentIndex == 0
          ? _buildFirstScreen() // Màn hình thứ nhất
          : _buildSecondScreen(), // Màn hình thứ hai
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildFirstScreen() {
    return Center(
      child: SelectContactsScreen(),
    );
  }

  Widget _buildSecondScreen() {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size.width * 0.9,
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
            SizedBox(height: 10,),
            const Divider(color: dividerColor),
            Flexible(
              child: SearchContactsScreen(search: searchController.text.trim()),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }


}
