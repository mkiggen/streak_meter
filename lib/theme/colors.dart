import 'package:flutter/material.dart';

const kPrimary = Color.fromARGB(255, 19, 27, 38);
const kSecondary = Color.fromARGB(255, 8, 11, 30);
const kTertiary = Color.fromARGB(255, 27, 35, 46);

const kBackgroundGradient = LinearGradient(
  colors: [kPrimary, kTertiary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAccentPurplePrimary = Color.fromARGB(255, 132, 39, 255);
const kAccentPurpleSecondary = Color.fromARGB(255, 97, 16, 237);
const kPurpleGradient = LinearGradient(
  colors: [kAccentPurplePrimary, kAccentPurpleSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAccentRedPrimary = Color.fromARGB(255, 255, 54, 93);
const kAccentRedSecondary = Color.fromARGB(255, 220, 46, 53);
const kRedGradient = LinearGradient(
  colors: [kAccentRedPrimary, kAccentRedSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAccentCyanPrimary = Color.fromARGB(255, 0, 205, 255);
const kAccentCyanSecondary = Color.fromARGB(255, 0, 214, 194);
const kCyanGradient = LinearGradient(
  colors: [kAccentCyanPrimary, kAccentCyanSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAccentGreenPrimary = Color.fromARGB(255, 128, 255, 114);
const kAccentGreenSecondary = Color.fromARGB(255, 88, 176, 87);
const kGreenGradient = LinearGradient(
  colors: [kAccentGreenPrimary, kAccentGreenSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kBlack = Colors.black;
const kWhite = Colors.white;

final List<LinearGradient> kGradientList = [kPurpleGradient, kRedGradient, kCyanGradient, kGreenGradient];
