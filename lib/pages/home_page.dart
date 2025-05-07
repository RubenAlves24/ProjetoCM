import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Olá, Miguel!",
                    style: TextStyle(
                      fontSize: 38,
                      fontFamily: 'Poppins',
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "Estes são possíveis fornecedores que te poderão agradar!",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.tertiaryFixed,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    "Recomendado para si:",
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/background_logo.png",
                        width: 70,
                        height: 80,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Sistema de Irrigação",
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "Soluções modernas para irrigar as suas culturas",
                                    style: TextStyle(fontSize: 10),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
