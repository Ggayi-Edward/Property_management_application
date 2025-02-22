import 'package:propertysmart2/export/file_exports.dart';

class EstateNav extends StatelessWidget {
  const EstateNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        color: Colors.black,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 24,
          ),
          Icon(
            Icons.home,
            color: Colors.white,
            size: 35,
          ),
          Icon(
            Icons.dehaze_rounded,
            color: Colors.white,
            size: 35,
          ),
          Icon(
            Icons.settings,
            color: Colors.white,
            size: 35,
          ),
          Icon(
            Icons.notifications,
            color: Colors.white,
            size: 35,
          ),
          SizedBox(
            width: 24,
          ),
        ],
      ),
    );
  }
}
