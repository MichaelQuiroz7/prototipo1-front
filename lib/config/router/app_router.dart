import 'package:go_router/go_router.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/presentation/client/screens/Home/home_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/basic_prompt/basic_prompt_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/chat_context/chat_context_screen.dart';
//import 'package:prototipo1_app/presentation/client/screens/citas/appointment_schedule_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/client/login/login_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/client/login/register_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/client/profile_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/odontograma/odontograma_cliente_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/promociones/categories_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/statistics/statistics_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/suggestion%20box/suggestion_box_screen.dart';
import 'package:prototipo1_app/presentation/employee/screens/Seleccionar_Cliente_Screen.dart';
import 'package:prototipo1_app/presentation/employee/screens/especialidades_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final usuario = SessionApp.usuarioActual;
    final isLoggingIn = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // No hay sesión → forzar login
    if (usuario == null && !isLoggingIn) {
      return '/login';
    }

    // // Hay sesión → no permitir volver al login
    // if (usuario != null && isLoggingIn) {
    //   return '/home';
    // }

     return null; // no redirección
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

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
    GoRoute(
  path: '/clientes',
  builder: (context, state) {
    final idRol = state.extra as int?;
    return SeleccionarClienteScreen(idRol: idRol);
  },
),

    GoRoute(
      path: '/odontogramaCliente',
      builder: (context, state) => OdontogramaClienteScreen(),
    ),
    GoRoute(
      path: '/suggestionBox',
      builder: (context, state) => SuggestionBoxScreen(),
    ),
    GoRoute(
      path: '/estadisticas',
      builder: (context, state) => StatisticsScreen(),
    ),
    GoRoute(
      path: '/categorias',
      builder: (context, state) => CategoriesScreen(),
    ),
  ],
);
