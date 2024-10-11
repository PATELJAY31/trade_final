   // lib/utils/gradients.dart
   import 'package:flutter/material.dart';

   class AppGradients {
     static const LinearGradient backgroundGradient = LinearGradient(
       colors: [
         Color(0xFF8E2DE2), // Purple
         Color(0xFF4A00E0), // Dark Purple
       ],
       begin: Alignment.topLeft,
       end: Alignment.bottomRight,
     );
   }