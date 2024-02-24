import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streak_meter/models/habit.dart';
import 'package:streak_meter/theme/colors.dart';

class HabitItem extends StatefulWidget {
  final Habit habit;
  const HabitItem({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem> {
  final user = FirebaseAuth.instance.currentUser!;

  void _update(Habit item) async {
    int count = widget.habit.count;

    try {
      await FirebaseFirestore.instance.collection('habits${user.uid}').doc(widget.habit.id).update(
        {
          'count': count,
        },
      );
    } catch (error) {
      // Do something
    }
  }

  void _incrementCounter() {
    setState(() {
      widget.habit.count++;
    });

    _update(widget.habit);
  }

  void _decrementCounter() {
    if (widget.habit.count < 1) return;
    setState(() {
      widget.habit.count--;
    });

    _update(widget.habit);
  }

  @override
  Widget build(BuildContext context) {
    LinearGradient? gradient;

    if (widget.habit.gradient == 'purple') {
      gradient = kPurpleGradient;
    }
    if (widget.habit.gradient == 'red') {
      gradient = kRedGradient;
    }
    if (widget.habit.gradient == 'cyan') {
      gradient = kCyanGradient;
    }
    if (widget.habit.gradient == 'green') {
      gradient = kGreenGradient;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Center(
              child: Text(
                widget.habit.title,
                style: GoogleFonts.poppins(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Center(
              child: Text(
                widget.habit.count.toString(),
                style: GoogleFonts.poppins(
                  color: kWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: kBlack.withOpacity(0.6),
                  ),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: _decrementCounter,
                      icon: const Icon(
                        Icons.remove,
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(0),
                      color: kWhite,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: kBlack.withOpacity(0.6),
                  ),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: _incrementCounter,
                      icon: const Icon(
                        Icons.add,
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(0),
                      color: kWhite,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
