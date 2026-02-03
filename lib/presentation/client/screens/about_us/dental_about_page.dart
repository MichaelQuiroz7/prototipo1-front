import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DentalAboutPage extends StatelessWidget {
  const DentalAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuestra Clínica"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Imagen principal
            CircleAvatar(
              radius: isTablet ? 120 : 80,
              backgroundImage: const AssetImage("assets/odontologo.jpg"),
            ),

            const SizedBox(height: 20),

            /// Texto descriptivo
            Text(
              "Somos una clínica odontológica comprometida con tu salud bucal. "
              "Ofrecemos atención profesional, tecnología moderna y un trato humano.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
              ),
            ),

            const SizedBox(height: 40),

            /// Círculos con cualidades
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                buildQualityCircle("Servicio"),
                buildQualityCircle("Responsabilidad"),
                buildQualityCircle("Profesionalismo"),
                buildQualityCircle("Tecnología"),
                buildQualityCircle("Confianza"),
              ],
            ),

            const SizedBox(height: 50),

            /// Redes Sociales
            const Text(
              "Síguenos en redes sociales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                socialIcon(Icons.facebook, "https://facebook.com"),
                const SizedBox(width: 20),
                socialIcon(Icons.camera_alt, "https://instagram.com"),
                const SizedBox(width: 20),
                socialIcon(Icons.phone, "https://wa.me/123456789"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQualityCircle(String text) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal.shade100,
          ),
          child: const Icon(
            Icons.medical_services,
            size: 40,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  Widget socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.teal,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
