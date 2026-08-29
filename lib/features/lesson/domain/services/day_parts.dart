/// Bagian hari yang menentukan sapaan di Home.
///
/// Batasnya mengikuti pembagian waktu dalam Bahasa Indonesia:
///
/// | Bagian  | Rentang         |
/// |---------|-----------------|
/// | Pagi    | 04.00 – 10.59   |
/// | Siang   | 11.00 – 14.59   |
/// | Sore    | 15.00 – 17.59   |
/// | Malam   | 18.00 – 03.59   |
enum DayPart { morning, midday, afternoon, evening }

/// Menentukan bagian hari dari sebuah waktu.
abstract final class DayParts {
  static const morningStart = 4;
  static const middayStart = 11;
  static const afternoonStart = 15;
  static const eveningStart = 18;

  static DayPart from(DateTime time) => fromHour(time.hour);

  /// Malam melewati tengah malam, jadi jam 0–3 tetap masuk malam.
  static DayPart fromHour(int hour) {
    if (hour >= eveningStart || hour < morningStart) return DayPart.evening;
    if (hour < middayStart) return DayPart.morning;
    if (hour < afternoonStart) return DayPart.midday;

    return DayPart.afternoon;
  }
}
