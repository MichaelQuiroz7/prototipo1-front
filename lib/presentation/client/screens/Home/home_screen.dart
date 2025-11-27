import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/theme/dark_mode_notifier.dart';
import 'package:prototipo1_app/presentation/client/Components/my_bottom_nav_bar.dart';
import 'package:prototipo1_app/presentation/client/screens/body/body_screen.dart';
import 'package:prototipo1_app/presentation/client/widgets/menu/side_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: BodyScreen(),
      drawer: SideMenu(),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }

  AppBar buildAppBar(context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      //leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      title: const Text('Perfect Teeth'),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, _) {
            return IconButton(
              icon: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
              tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
              onPressed: () {
                isDarkModeNotifier.value = !isDarkModeNotifier.value;
              },
            );
          },
        ),
      ],
    );
  }





























































  

  //  @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Home Screen'),
  //         actions: [
  //           ValueListenableBuilder<bool>(
  //             valueListenable: isDarkModeNotifier,
  //             builder: (context, isDarkMode, _) {
  //               return IconButton(
  //                 icon: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
  //                 tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
  //                 onPressed: () {
  //                   isDarkModeNotifier.value = !isDarkModeNotifier.value;
  //                 },
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //       body: ListView(
  //         children: [
  //           ListTile(
  //             leading: const CircleAvatar(
  //               backgroundColor: Colors.pink,
  //               child: Icon(Icons.person_2_outlined),
  //             ),
  //             title: const Text('Perfect Teeth'),
  //             subtitle: const Text('Para consultas dentales'),
  //             onTap: ()=> context.push('/history-chat'),
  //             //onTap: ()=> context.push('/basic-prompt'),

  //           )
  //         ],
  //       ),
  //     );
  //   }
}

