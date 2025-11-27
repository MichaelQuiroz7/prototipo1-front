import 'package:go_router/go_router.dart';
import 'package:prototipo1_app/presentation/client/screens/Home/home_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/basic_prompt/basic_prompt_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/chat_context/chat_context_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/client/login/login_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/client/login/register_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/client/profile_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/odontograma/odontograma_cliente_screen.dart';
import 'package:prototipo1_app/presentation/employee/screens/Seleccionar_Cliente_Screen.dart';
import 'package:prototipo1_app/presentation/employee/screens/especialidades_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/basic-prompt',
      builder: (context, state) => BasicPromptScreen(),
    ),
    GoRoute(
      path: '/history-chat',
      builder: (context, state) => ChatContextScreen(),
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/especialidades',
      builder: (context, state) => const EspecialidadesScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/odontograma', builder: (context, state) => SeleccionarClienteScreen()),
    GoRoute(path: '/odontogramaCliente', builder: (context, state) => OdontogramaClienteScreen()),
    


    // GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    // GoRoute(path: '/promotions', builder: (context, state) => const PromotionsScreen()),
    // GoRoute(path: '/social', builder: (context, state) => const SocialScreen()),
    // GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    // GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
    // GoRoute(path: '/logout', builder: (context, state) => const LogoutScreen()),
  ],
);
