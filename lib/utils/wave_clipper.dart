import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);

    // Primeira onda
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndpoint = Offset(
      size.width / 2,
      size.height - 50,
    ); // Começa na parte inferior, 50px acima do final
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndpoint.dx,
      firstEndpoint.dy,
    );

    // Segunda onda
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 100);
    var secondEndpoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndpoint.dx,
      secondEndpoint.dy,
    );

    path.lineTo(size.width, 0); // Desenha a linha
    path.close(); // Fecha o caminho

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // Não precisa redesenhar a onda, a menos que o tamanho mude
}
