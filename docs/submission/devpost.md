# Devpost submission

Semua materi submission wajib berbahasa Inggris. Teks di bawah siap disalin.
Bagian bertanda `[ISI]` menunggu data darimu.

**Kategori utama: RevenueCat Peace Prize.** Kategori inilah yang paling cocok
dengan alasan app ini dibuat, dan kriterianya hanya dua — Impact dan Feasibility.
HAMM, Design, dan #BuildInPublic tetap diikuti sebagai kategori sekunder.

> **Aturan yang tidak boleh dilanggar dalam seluruh materi ini:** Training Record
> **bukan** kualifikasi bahasa dan **tidak** boleh disebut sebagai syarat, standar
> kelulusan, atau patokan rekrutmen. Gerbang resmi untuk Specified Skilled Worker
> (Tokutei Ginou) adalah lulus ujian bahasa — JFT-Basic level A2 atau JLPT N4 —
> ditambah ujian keterampilan. Posisi DilSensei adalah **persiapan menuju ujian
> itu**, bukan penggantinya. Klaim berlebihan di sini berisiko menyesatkan calon
> pekerja migran dan melanggar kebijakan Google Play.

---

## Text description

```
Knowing a grammar rule is not the same as producing it in three seconds. Every Japanese app I tried taught me knowledge; none of them trained the gap between knowing and saying. DilSensei is built around that gap — and it is built first for Indonesians preparing to work in Japan, where that gap has a price.

WHO THIS IS FOR

Indonesia sends a large number of workers to Japan every year through the Specified Skilled Worker (Tokutei Ginou) and technical intern routes. For most of them the Japanese language test is the gate, and the fee for placement is paid long before the test is passed. Failing is not an inconvenience; it is a debt.

Those learners are not short of grammar explanations. They are short of production speed under pressure, and they are short of study material that explains Japanese in Indonesian rather than in English. DilSensei is aimed squarely at that.

HOW IT WORKS

A session is 6 to 12 short items, five to fifteen minutes depending on the daily target you pick during onboarding. Three drill types rotate so the session never becomes positional memorisation:

1. Build the sentence — arrange word chips into a full Japanese sentence
2. Complete the particle — pick the particle that fills the gap, and watch it drop into the sentence as you choose
3. Change the form — convert a verb or adjective into the polite, past, negative, or request form

Two things are measured on every item: whether you were right, and how long you hesitated. That second number is the point. A correct answer in two seconds and a correct answer in nine seconds are not the same skill, and DilSensei does not treat them as the same.

A wrong answer is never skipped. The item returns later in the same session until you get it right, so you cannot leave a session having only failed.

THE WEAK-SPOT MAP

Mistakes are not stored as "wrong". They are stored as grammar patterns: place particles, time-word order, past forms, counters, polite forms. Every attempt becomes a dated event, and the map is recomputed from those events with three rules:

- Recent mistakes weigh more. Weight halves every seven days, so the map reflects where you are now, not where you were three weeks ago.
- Correct but slow still counts. Answers past seven seconds carry a partial penalty, because reflex means fast.
- Thin evidence does not jump the queue. One miss on a pattern tried once does not outrank eight misses out of twenty attempts.

From the map, one tap generates a session containing only the patterns you are still weak at. That loop — measure, diagnose, regenerate — is the product.

THE TRAINING RECORD

Finish a session in every module and the app issues a Training Record: your reflex score, your first-try accuracy, your median response time, and the share of patterns that already count as automatic. It is written in English regardless of app language, so it can be shown to an instructor or a training centre.

It says plainly on its own face what it is: a record of practice completed inside DilSensei, and not an official language qualification. It is designed to be evidence of consistent training on the way to JFT-Basic or JLPT N4 — never a substitute for them.

WHAT IS FREE

Both kana charts are free and need no session: 104 letters per script with romaji, plus a plain explanation of when hiragana and katakana are actually used. The free tier also includes two modules, one session a day, and a preview of the weak-spot map.

BUILT DELIBERATELY SMALL

No account, no sign-in, no backend. Lessons and fonts ship inside the app, so drills work offline and nothing about your practice leaves your device. That is not minimalism for its own sake: mobile data is a real cost for the people this app is for, and a drill that needs the network is a drill they will skip.

Subscription state is the only thing verified over the network, through RevenueCat.

The interface and the lesson prompts are both fully localised in English and Bahasa Indonesia — 58 drill items and 8 modules translated, not just the buttons.

TECH

Flutter, Riverpod, GoRouter, RevenueCat for subscriptions, Firebase Analytics for anonymous usage events, local notifications for reminders, SharedPreferences for progress. The drill engine, the weak-spot scoring, the streak rules, and the reminder rules are all pure Dart with no I/O, which is why they are covered by 181 automated tests.
```

---

## RevenueCat Peace Prize blurb

```
IMPACT

Indonesia is one of the largest senders of workers to Japan, through the Specified Skilled Worker (Tokutei Ginou) programme and the technical intern route. For most candidates the Japanese language test is the gate: JFT-Basic at A2, or JLPT N4, alongside a skills test. Placement costs are typically paid before that gate is cleared, so a failed test is not a delay — it is money already spent.

The people in that position share three constraints that ordinary language apps ignore:

1. They need production speed, not recognition. On a factory floor or in a care home, a phrase you can only assemble in nine seconds is a phrase you do not have. Recognition-based apps score that as a pass.
2. They need Japanese explained in Indonesian. Most quality material explains Japanese in English, which adds a second language barrier on top of the first.
3. They cannot rely on data. Practice happens in transit, in dormitories, in villages with thin coverage. Anything that needs the network gets skipped.

DilSensei answers those three directly. Every item is timed, and slow-but-correct answers are treated as an unfinished skill rather than a success. The entire interface and every drill prompt exist in Bahasa Indonesia as a first-class language, not a partial translation — 58 drill items and 8 modules, prompts and grammar notes included. And the app has no backend at all: lessons and fonts are bundled, so every drill works with the radio off.

The reach is not limited to individuals. Indonesian vocational training centres (LPK) already prepare cohorts for these tests. The weak-spot map is the artifact an instructor actually wants, because it shows which student is behind on which grammar pattern instead of producing one aggregate score.

WHAT THIS IS NOT

The Training Record the app issues is a record of practice, not a credential. The app states this on the record itself: it is not an official language qualification. Nothing in DilSensei can replace JFT-Basic or JLPT, and it is deliberately worded so that no learner and no employer can mistake it for a pass.

We consider that restraint part of the social design, not a limitation of it. An app aimed at people who are about to spend money they do not have on a test they might fail has an obligation not to inflate their confidence. Measuring hesitation honestly, and refusing to certify what it cannot certify, is the safer failure mode.

FEASIBILITY

This is a shipped Android app, not a prototype: no account to create, no server to keep running, no ongoing cost per user beyond the store's own. It runs offline on low-end hardware, which is what the target user actually owns. The rules the app reasons with — the drill engine, the weak-spot scoring, the streak and reminder logic — are pure functions covered by 181 automated tests, so the diagnosis a learner is shown is reproducible rather than incidental.

Sustaining it does not depend on winning anything: individual subscriptions fund the app, and per-cohort licensing to training centres is the path that scales it to the institutions where these learners already are.

[ISI opsional: satu angka terverifikasi tentang jumlah pekerja Indonesia ke Jepang, dengan sumber resmi — BP2MI atau situs SSW. Jangan pakai angka yang tidak bisa kamu tunjukkan sumbernya.]
```

---

## Testing instructions (wajib diisi)

```
Free trial: [ISI: ada / tidak]
Promo code for judges: [ISI kode dari Play Console jika tidak memakai trial]

Fastest path through the app:

1. Onboarding asks for a nickname, a goal, and a daily target. Any answers work.
2. Tap "Start session" on the home screen. Answer a few items correctly and a
   few wrong on purpose — the wrong ones are what populate the weak-spot map.
3. The session summary shows the reflex score counting up and the weak patterns
   found in that session.
4. Open Insights from the home screen to see the weak-spot map, then use the
   one-tap button to generate a session from weak patterns only.
5. Both kana charts are free from the home screen and need no session.
6. The Training Record unlocks after one session in every module. Modules beyond
   the free two require Pro, so use the trial or promo code above to reach it.

Language: the app defaults to English. Settings has an Indonesian toggle that
switches both the interface and the Japanese drill prompts.
```

---

## HAMM Award blurb

```
DilSensei charges for diagnosis, not for content unlocking.

The free tier is deliberately generous where it costs nothing: both full kana charts, two modules, one session a day, and a preview of the weak-spot map. What Pro unlocks is the thing that keeps producing value after the content runs out — the complete weak-spot map, the sessions generated automatically from your weak patterns, unlimited daily sessions, and the reflex-score history.

That distinction matters commercially. Content-unlock subscriptions die when the learner finishes the content. A diagnosis subscription stays useful as long as the learner keeps making mistakes, which is the entire duration of learning a language.

Pricing and packaging: a monthly auto-renewing subscription and an annual one, plus a one-time lifetime purchase for the sizeable share of Indonesian users who prefer not to hold a recurring charge. All of them attach to a single RevenueCat entitlement, so gating is one boolean in the app and pricing experiments never touch app code.

The paywall is placed where value has just been felt, not on app open: after the first session summary, on a locked module, and when the free daily session is used up. The daily-limit sheet explains why the limit exists instead of only showing a price.

Beyond the hackathon there is a third stream that fits this market precisely. Indonesian vocational schools and worker-placement agencies (LPK) already charge students for Japanese preparation, and they buy per cohort rather than per person. The weak-spot map is the artifact those institutions actually want, because it shows which students are behind on which pattern — something no test score gives them until it is too late to fix.

Numbers to date: [ISI: trial starts, konversi, MRR dari dashboard RevenueCat].
```

---

## RevenueCat Design Award blurb

```
The design system is called Organic Minimalism: Off-White #FCFCFC, Deep Forest Green #2D6A4F, Soft Leaf Green #D8F3DC, with thin translucent borders and no drop shadows anywhere in the app.

Specific things worth looking at:

1. The particle drill. Choosing a particle drops it straight into the blank inside the Japanese sentence, so you read the finished sentence before you commit. The blank is an underlined gap, not an empty box.
2. The form-change drill. The base form sits above an arrow that points down into your chosen answer, so the transformation reads as a transformation rather than a multiple-choice list.
3. The session summary. The reflex score counts up rather than appearing, and each weak pattern animates its mastery bar from zero.
4. The weak-spot map. Bars are coloured by reason, not severity: red for patterns you get wrong, warm brown for patterns you get right but slowly. Two different problems should not look like the same problem.
5. Typography is bundled, not fetched. Space Grotesk for headings, Plus Jakarta Sans for body — the latter made by Tokotype, an Indonesian type foundry, which matters for an app built in Indonesia. Bundling also means the typography is correct on first launch with no network.
6. The app icon and the feature graphic are both rendered programmatically from source art by scripts in the repo, so they can be regenerated exactly rather than hand-exported.
7. The onboarding steps rise and fade rather than sliding, and the step indicator interpolates colour instead of switching it.
8. Light and dark themes built from one semantic palette, so the brand green shifts to a lighter tone on dark surfaces instead of staying unreadable. Contrast ratios for both themes are asserted by tests, not eyeballed.

Everything above renders offline, including the Japanese characters, which fall back to the system CJK font through an explicit fallback chain rather than by accident.

Every animation in the app honours the platform's reduced-motion setting. Turn it on and the transitions resolve instantly to their final state rather than being skipped, so nothing is lost — and the loading skeleton stops pulsing entirely, because an endlessly repeating animation is exactly what that setting exists to prevent. A test walks the source tree and fails the build if any animated widget ignores it.
```

---

## #BuildInPublic blurb

```
Links: [ISI daftar tautan post]

What sharing changed in the app:
[ISI 2-3 hal konkret yang berubah karena umpan balik]

Lessons learned:
[ISI pelajaran paling jujur, termasuk yang gagal]
```

Catatan: kriteria kategori ini menegaskan **jumlah followers tidak dinilai**. Yang
dinilai kualitas cerita, keterlibatan, dan pelajaran. Jadi tulis apa adanya —
termasuk keputusan yang salah dan diperbaiki. Bahan jujur yang sudah tersedia:

- Rumus peta kelemahan awalnya memakai prior 0,25, sehingga pola lama yang sudah
  dikuasai justru naik peringkat. Diganti dengan formula tanpa prior plus
  `evidenceFloor`.
- `module_id` pada data latihan tidak cocok dengan id modul, sehingga **semua
  modul tampak kosong**. Ditemukan oleh test integritas aset, bukan oleh mata.
- Receiver `flutter_local_notifications` tidak ter-merge ke manifest, sehingga
  pengingat harian tidak akan pernah muncul di perangkat nyata.
- Empat teks masih Bahasa Indonesia hardcoded padahal app disetel Inggris. 166
  test tidak menangkapnya karena fixture test-nya juga berbahasa Indonesia —
  test dan bug memakai bahasa yang sama.
- Paket tahunan (`$rc_annual`) tampil sebagai "Monthly plan" tanpa label periode,
  karena enum periode tidak pernah memetakan `PackageType.annual`.

---

## Checklist submission

- [ ] URL app di Google Play (versi publik pertama dirilis dalam periode submission)
- [ ] Video demo ≤2 menit, publik di YouTube/Vimeo
- [ ] Ikon 1024×1024
- [ ] Minimal satu screenshot 1179×2556 **tanpa** frame perangkat
- [ ] Free trial **atau** promo code untuk juri
- [ ] Kategori dipilih: Peace Prize (utama), HAMM, Design, #BuildInPublic
- [ ] Semua materi berbahasa Inggris
- [ ] `REVENUECAT_ANDROID_KEY` (`goog_...`) terpasang — build rilis menolak key test
- [ ] Konten Jepang diperiksa penutur asli atau instruktur LPK

---

## Celah yang diketahui (jangan diklaim sudah selesai)

Dicatat di sini supaya tidak ada klaim di materi submission yang melebihi
keadaan kode.

- **Entitlement `pro` belum terbukti terpasang** ke ketiga produk di dashboard
  RevenueCat. Gejalanya bila belum: pembelian berhasil tapi app menampilkan
  "langganan belum aktif" (`PurchaseFailure.notActive`).
- **Free trial belum terverifikasi** karena info trial hanya datang dari store
  lewat SDK. Harus dilihat dengan menjalankan app di perangkat.
