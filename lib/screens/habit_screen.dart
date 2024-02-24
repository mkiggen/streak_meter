import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:streak_meter/models/habit.dart';
import 'package:streak_meter/screens/new_habit.dart';
import 'package:streak_meter/theme/colors.dart';
import 'package:streak_meter/widgets/habit_item.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({Key? key}) : super(key: key);

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  loadImage() async {
    final image = await FirebaseFirestore.instance
        .collection(
          'users',
        )
        .doc(
          user.uid,
        )
        .get()
        .then(
          (value) => value.data()!['image'],
        );

    return image;
  }

  findUser() async {
    final userEmail = await FirebaseFirestore.instance
        .collection(
          'users',
        )
        .where(
          'email',
          isEqualTo: 'test@testing.come',
        )
        .get()
        .then(
          (value) => value.docs.map(
            (e) => {
              'uid': e.data()['uid'],
            },
          ),
        );

    print(userEmail);
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  void _showDialog(Habit item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: kWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          title: const Center(
            child: Text('Would you like to delete this item?'),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.close,
                  color: kAccentRedPrimary,
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirebaseFirestore.instance
                      .collection(
                        'habits${user.uid}',
                      )
                      .doc(
                        item.id,
                      )
                      .delete();
                },
                child: const Icon(
                  Icons.check,
                  color: kAccentGreenPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewHabit(),
      ),
    );

    if (newItem == null) return;
  }

  // implement response and delete request for firestore

  @override
  Widget build(BuildContext context) {
    findUser();
    Widget content = StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(
            'habits${user.uid}',
          )
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No habits found.',
              style: TextStyle(
                color: kWhite,
                fontSize: 18,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final loadedHabits = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: loadedHabits.length,
          itemBuilder: (context, index) {
            final Habit habit = Habit(
              id: loadedHabits[index].id,
              title: loadedHabits[index].data()['name'],
              count: loadedHabits[index].data()['count'],
              gradient: loadedHabits[index].data()['gradient'],
            );
            return InkWell(
              splashColor: Colors.transparent,
              onLongPress: () {
                _showDialog(habit);
              },
              child: HabitItem(
                habit: habit,
              ),
            );
          },
        );
      },
    );

    return LiquidPullToRefresh(
      animSpeedFactor: 1.5,
      showChildOpacityTransition: true,
      backgroundColor: kAccentRedPrimary,
      springAnimationDurationInMilliseconds: 500,
      color: kPrimary,
      onRefresh: _refresh,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Habits',
            style: GoogleFonts.poppins(
              color: kWhite,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            FutureBuilder(
              future: loadImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: kAccentRedPrimary,
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return InkWell(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Image.network(
                        snapshot.data!.toString(),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
                return Container(
                  color: Colors.orange,
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          shape: const CircleBorder(),
          backgroundColor: kSecondary,
          splashColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add_rounded,
            size: 40,
            color: kWhite,
          ),
        ),
      ),
    );
  }
}
