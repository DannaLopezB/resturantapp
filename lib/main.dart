import 'package:flutter/material.dart';
import './components/screeemcustomer.dart';
import './components/screeemdish.dart';
import './components/screeemdrink.dart';
import './components/screeememployee.dart';
import './components/screeemorders.dart';
import './components/screeempayment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Restaurante',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Pantalla de Bienvenida
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono del restaurante
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 30),

              // Título
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Subtítulo
              const Text(
                'Sistema de Gestión de Restaurante',
                style: TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Botón para continuar
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainMenuScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla del Menú Principal
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú Principal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF8A50), Color(0xFFFFF3E0)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildMenuCard(
                context,
                'Clientes',
                Icons.people,
                Colors.blue,
                () => _navigateToScreen(context, 'customer'),
              ),
              _buildMenuCard(
                context,
                'Platos',
                Icons.restaurant_menu,
                Colors.green,
                () => _navigateToScreen(context, 'dish'),
              ),
              _buildMenuCard(
                context,
                'Bebidas',
                Icons.local_drink,
                Colors.purple,
                () => _navigateToScreen(context, 'drink'),
              ),
              _buildMenuCard(
                context,
                'Empleados',
                Icons.badge,
                Colors.orange,
                () => _navigateToScreen(context, 'employee'),
              ),
              _buildMenuCard(
                context,
                'Órdenes',
                Icons.receipt_long,
                Colors.red,
                () => _navigateToScreen(context, 'order'),
              ),
              _buildMenuCard(
                context,
                'Pagos',
                Icons.payment,
                Colors.teal,
                () => _navigateToScreen(context, 'payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String screenType) {
    Widget screen;

    switch (screenType) {
      case 'customer':
        screen = const CustomerScreen();
        break;
      case 'dish':
        screen = const DishScreen();
        break;
      case 'drink':
        screen = const DrinkScreen();
        break;
      case 'employee':
        screen = const EmployeeScreen();
        break;
      case 'order':
        screen = const OrderScreen();
        break;
      case 'payment':
        screen = const PaymentScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}