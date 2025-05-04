import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

import '../utils/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem vindo!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Ajude-nos a conhecê-lo melhor, como pretende juntar-se a nós?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    AuthService().setLoggingInState(false);
                    AuthService().setProducerState(true);
                    Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
                  },
                  child: Card(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surface,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              'assets/images/produtor.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Produtor",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    AuthService().setLoggingInState(false);
                    AuthService().setProducerState(false);
                    Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
                  },
                  child: Card(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surface,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              'assets/images/consumidor.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Consumidor",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  thickness: 2,
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Image.asset(
                      'assets/images/simpleLogo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Já tem conta?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AuthService().setLoggingInState(true);
                    Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
                  },
                  child: Text(
                    "Entre aqui.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
