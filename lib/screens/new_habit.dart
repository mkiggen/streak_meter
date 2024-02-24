import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streak_meter/theme/colors.dart';

class NewHabit extends StatefulWidget {
  const NewHabit({
    Key? key,
  }) : super(key: key);

  @override
  State<NewHabit> createState() => _NewHabitState();
}

class _NewHabitState extends State<NewHabit> {
  final TextEditingController habitNameController = TextEditingController();
  final List<bool> _isSelected = [true, false, false, false];
  LinearGradient currentGradient = kPurpleGradient;
  bool _isSending = false;

  void _saveItem(TextEditingController controller) async {
    if (controller.text.trim().isEmpty) return;
    setState(() {
      _isSending = true;
    });
    String? gradientKey;

    if (_isSelected[0]) gradientKey = 'purple';
    if (_isSelected[1]) gradientKey = 'red';
    if (_isSelected[2]) gradientKey = 'cyan';
    if (_isSelected[3]) gradientKey = 'green';

    final user = FirebaseAuth.instance.currentUser!;

    Navigator.of(context).pop();
    try {
      await FirebaseFirestore.instance.collection('habits${user.uid}').add(
        {
          'createdAt': Timestamp.now(),
          'user': user.uid,
          'name': controller.text,
          'count': 0,
          'gradient': gradientKey,
        },
      );
    } catch (error) {
      const ScaffoldMessenger(
        child: SnackBar(
          content: Text('Something went wrong, please try again.'),
        ),
      );
    }

    setState(() {
      _isSending = false;
    });
  }

  @override
  void dispose() {
    habitNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'New Habit',
          style: GoogleFonts.poppins(
            color: kWhite,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: habitNameController,
              cursorColor: kWhite,
              maxLength: 15,
              style: GoogleFonts.poppins(
                color: kWhite,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                fillColor: kSecondary,
                hintText: 'Habit name',
                hintStyle: GoogleFonts.poppins(color: kWhite.withAlpha(50)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: kSecondary, width: 3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: kWhite, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: ToggleButtons(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                selectedBorderColor: Colors.transparent,
                selectedColor: Colors.transparent,
                disabledColor: Colors.transparent,
                fillColor: Colors.transparent,
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                      if (buttonIndex == index) {
                        currentGradient = kGradientList[index];
                        _isSelected[buttonIndex] = true;
                      } else {
                        _isSelected[buttonIndex] = false;
                      }
                    }
                  });
                },
                isSelected: _isSelected,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: kPurpleGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Purple',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSelected[0] ? kWhite : kBlack,
                        fontWeight: _isSelected[0] ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: kRedGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Red',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSelected[1] ? kWhite : kBlack,
                        fontWeight: _isSelected[1] ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(
                      gradient: kCyanGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Blue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSelected[2] ? kWhite : kBlack,
                        fontWeight: _isSelected[2] ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: kGreenGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Green',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSelected[3] ? kWhite : kBlack,
                        fontWeight: _isSelected[3] ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _saveItem(habitNameController);
                            },
                      style: const ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
                        overlayColor: MaterialStatePropertyAll(Colors.transparent),
                      ),
                      child: Text(
                        'create',
                        style: GoogleFonts.poppins(
                          color: kWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
