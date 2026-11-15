import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/PrayerProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PrayerProvider()..getPrayerTimes(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? timer;
  DateTime now = DateTime.now();

  final Color gold = const Color(0xffD9B56D);
  final Color green = const Color(0xff103C32);

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String arabicName(String name) {
    switch (name) {
      case 'Fajr':
        return 'الفجر';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return name;
    }
  }

  IconData prayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.sunny;
      case 'Maghrib':
        return Icons.nights_stay;
      case 'Isha':
        return Icons.dark_mode;
      default:
        return Icons.access_time;
    }
  }

  DateTime? getPrayerDate(String value, DateTime date) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);

    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Map<String, dynamic>? getNextPrayer(Map timings) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in prayers) {
      if (!timings.containsKey(prayer)) continue;

      final prayerDate = getPrayerDate(timings[prayer].toString(), now);

      if (prayerDate != null && prayerDate.isAfter(now)) {
        return {'name': prayer, 'time': prayerDate};
      }
    }

    // Next day Fajr
    if (timings.containsKey('Fajr')) {
      final tomorrow = now.add(const Duration(days: 1));

      final fajr = getPrayerDate(timings['Fajr'].toString(), tomorrow);

      if (fajr != null) {
        return {'name': 'Fajr', 'time': fajr};
      }
    }

    return null;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '${twoDigits(duration.inHours)}:'
        '${twoDigits(duration.inMinutes.remainder(60))}:'
        '${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: green,

      body: Stack(
        children: [
          // Islamic Background
          Positioned.fill(child: CustomPaint(painter: IslamicPatternPainter())),

          SafeArea(
            child: Consumer<PrayerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: gold));
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 45,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () => provider.getPrayerTimes(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.prayer == null) {
                  return const Center(
                    child: Text(
                      'لا توجد بيانات',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final timings = provider.prayer!.timings;
                final nextPrayer = getNextPrayer(timings);

                final List<String> prayers = [
                  'Fajr',
                  'Dhuhr',
                  'Asr',
                  'Maghrib',
                  'Isha',
                ];

                Duration remaining = Duration.zero;

                if (nextPrayer != null) {
                  remaining = nextPrayer['time'].difference(now);
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),

                  children: [
                    // Header
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.mosque,
                            size: 48,
                            color: Color(0xffD9B56D),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: TextStyle(
                              color: Color(0xffE8D5AC),
                              fontSize: 17,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'مواقيت الصلاة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'حافظ على صلاتك',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Next Prayer Card
                    Container(
                      padding: const EdgeInsets.all(25),

                      decoration: BoxDecoration(
                        color: const Color(0xffF4EBD8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: gold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          const Text(
                            'الصلاة القادمة',
                            style: TextStyle(
                              color: Color(0xff567166),
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            nextPrayer == null
                                ? '--'
                                : arabicName(nextPrayer['name']),
                            style: const TextStyle(
                              color: Color(0xff103C32),
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            nextPrayer == null
                                ? '--:--'
                                : timings[nextPrayer['name']].toString(),
                            style: const TextStyle(
                              color: Color(0xff8B7040),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Divider(color: Color(0xffD5C7A9)),

                          const SizedBox(height: 12),

                          const Text(
                            'الوقت المتبقي',
                            style: TextStyle(
                              color: Color(0xff567166),
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            nextPrayer == null
                                ? '--:--:--'
                                : formatDuration(remaining),
                            style: const TextStyle(
                              color: Color(0xff103C32),
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'ساعة : دقيقة : ثانية',
                            style: TextStyle(
                              color: Color(0xff8B7040),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Prayer List Header
                    const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Color(0xffD9B56D)),

                        SizedBox(width: 10),

                        Text(
                          'صلوات اليوم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Prayer List
                    ...prayers.map((prayer) {
                      final isNext =
                          nextPrayer != null && nextPrayer['name'] == prayer;

                      if (!timings.containsKey(prayer)) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),

                        decoration: BoxDecoration(
                          color: isNext
                              ? const Color(0xffD9B56D)
                              : Colors.white.withOpacity(0.08),

                          borderRadius: BorderRadius.circular(16),

                          border: Border.all(
                            color: isNext ? Colors.white : Colors.white24,
                          ),
                        ),

                        child: ListTile(
                          leading: Icon(
                            prayerIcon(prayer),
                            color: isNext ? green : gold,
                            size: 27,
                          ),

                          title: Text(
                            arabicName(prayer),
                            style: TextStyle(
                              color: isNext ? green : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isNext)
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'القادمة',
                                    style: TextStyle(
                                      color: Color(0xff103C32),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              Text(
                                timings[prayer].toString(),
                                style: TextStyle(
                                  color: isNext ? green : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        '﴿ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا ﴾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xffD9B56D),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Islamic Geometric Background
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffD9B56D).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double x = 0; x < size.width + 50; x += 55) {
      for (double y = 0; y < size.height + 50; y += 55) {
        final path = Path();

        path.moveTo(x, y - 20);
        path.lineTo(x + 20, y);
        path.lineTo(x, y + 20);
        path.lineTo(x - 20, y);
        path.close();

        canvas.drawPath(path, paint);

        canvas.drawCircle(Offset(x, y), 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
