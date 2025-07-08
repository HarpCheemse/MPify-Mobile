import 'package:flutter/material.dart';
import 'package:mpify/widgets/playlist.dart';
import 'package:mpify/widgets/settings.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/song.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final List<Widget> _pages = [Playlist(), Songs(), Settings()];
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorSchemeSurface = Theme.of(context).colorScheme.surface;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorSchemeSurface,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChange,
                children: _pages,
              ),
            ),
            bottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  Widget bottomNavigationBar(BuildContext context) {
    final TextStyle textStyle = montserratStyle(context: context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(
          icon: Icons.my_library_music_outlined,
          label: 'Library',
          index: 0,
          textStyle: textStyle,
          iconSize: 32,
          context: context,
        ),
        _buildNavItem(
          icon: Icons.queue_music,
          label: 'Playlist',
          index: 1,
          textStyle: textStyle,
          iconSize: 32,
          context: context,
        ),
        _buildNavItem(
          icon: Icons.settings,
          label: 'Settings',
          index: 2,
          textStyle: textStyle,
          iconSize: 32,
          context: context,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required TextStyle textStyle,
    required double iconSize,
    required BuildContext context,
  }) {
    final isSelected = _selectedIndex == index;
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: iconSize,
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
          onPressed: () => _onTap(index),
        ),
        Text(
          label,
          style: textStyle.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}



