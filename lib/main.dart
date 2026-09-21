import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:varus/page/about_page.dart';
import 'package:varus/page/filling_page.dart';
import 'package:varus/page/home_page.dart';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:varus/page/scanning_page.dart';
import 'package:varus/page/settings_page.dart';

Future<void> main() async {
  await SentryFlutter.init(
        (options) {
      options.dsn =
      'https://ef68d0f454ce4fe4a0b92e00e349224b@o4504851599720448.ingest.sentry.io/4504851603849216';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const VarusApp()),
  );
}

class VarusApp extends StatelessWidget {
  const VarusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LockGate(
      child: MyApp(),
    );
  }
}

class LockGate extends StatefulWidget {
  const LockGate({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  static const _lockKey = 'app_lock_enabled';
  static const _relockAfterSeconds = 60;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _locked = true;
  bool _lockEnabled = true;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSetting();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_lockKey) ?? true;
    if (!mounted) {
      return;
    }
    setState(() {
      _lockEnabled = enabled;
    });
    if (enabled) {
      _tryAuthenticate();
    } else {
      setState(() {
        _locked = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_lockEnabled) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      final away = pausedAt == null
          ? 0
          : DateTime.now().difference(pausedAt).inSeconds;
      if (away >= _relockAfterSeconds && !_locked) {
        setState(() {
          _locked = true;
        });
        _tryAuthenticate();
      }
    }
  }

  Future<void> _tryAuthenticate() async {
    var canAuth = false;
    try {
      canAuth = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('local_auth check error: $e');
    }
    if (!canAuth) {
      // 设备无任何可用认证方式，放行避免死锁（可在设置中关闭应用锁）
      if (mounted) {
        setState(() {
          _locked = false;
        });
      }
      return;
    }
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁二步验证',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (ok && mounted) {
        setState(() {
          _locked = false;
        });
      }
    } catch (e) {
      debugPrint('local_auth error: $e');
      if (mounted) {
        setState(() {
          _locked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locked) {
      return widget.child;
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.teal,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                '二步验证已锁定',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _tryAuthenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('点击解锁'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = FlexThemeData.light(
        fontFamily: "Montserrat",
        useMaterial3: false,
        scheme: FlexScheme.materialBaseline);

    return MaterialApp(
      theme: theme,
      title: '二步验证',
      initialRoute: "/",
      routes: {
        "/": (_) => HomePage(),
        "/settings": (_) => SettingsPage(),
        "/about": (_) => AboutPage(),
        "/scanning": (_) => ScanningPage(),
        "/filling": (_) => FillingPage(),
      },
    );
  }
}
