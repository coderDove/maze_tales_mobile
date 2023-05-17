import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DialogueBoxAvatarPosition { left, right }

enum DialogueBoxType { cat, dog, catAndDog }

extension Info on DialogueBoxType {
  String imageName() {
    switch (this) {
      case DialogueBoxType.cat:
        return 'assets/images/avatar_cat.png';
      case DialogueBoxType.dog:
        return 'assets/images/avatar_dog.png';
      case DialogueBoxType.catAndDog:
        return 'assets/images/avatar_cat_and_dog.png';
    }
  }

  DialogueBoxAvatarPosition avatarPosition() {
    switch (this) {
      case DialogueBoxType.cat:
        return DialogueBoxAvatarPosition.left;
      case DialogueBoxType.dog:
        return DialogueBoxAvatarPosition.right;
      case DialogueBoxType.catAndDog:
        return DialogueBoxAvatarPosition.right;
    }
  }

  Color textColor() {
    switch (this) {
      case DialogueBoxType.cat:
        return const Color(0xFF3D3F67);
      case DialogueBoxType.dog:
        return const Color(0xFF581735);
      case DialogueBoxType.catAndDog:
        return const Color(0xFF581735);
    }
  }
}

class DialogueBox extends StatelessWidget {
  final String text;
  final DialogueBoxType type;

  const DialogueBox({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final textWidget = Flexible(
      child: Text(
        text,
        style: GoogleFonts.atma(color: type.textColor(), fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    final avatarWidget = Image.asset(type.imageName());
    List<Widget> dialogueRowWidgets = [];
    if (type.avatarPosition() == DialogueBoxAvatarPosition.left) {
      dialogueRowWidgets.addAll([avatarWidget, textWidget]);
    } else if (type.avatarPosition() == DialogueBoxAvatarPosition.right) {
      dialogueRowWidgets.addAll([textWidget, avatarWidget]);
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 30.0, 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dialogueRowWidgets,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: const [
              Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
