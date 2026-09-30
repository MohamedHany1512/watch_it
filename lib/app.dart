import 'package:flutter/material.dart';
import 'package:watch_it/core/routing/app_router.dart';
import 'package:watch_it/core/routing/routes.dart';
import 'package:watch_it/core/themes/app_theme.dart';


class WatchItApp extends StatelessWidget {
  const WatchItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WatchIt',

      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (BuildContext context, Widget? child) {
   
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

