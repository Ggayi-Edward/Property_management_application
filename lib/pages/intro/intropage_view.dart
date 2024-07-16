import 'package:propertysmart2/export/file_exports.dart';

class IntroPageView extends StatelessWidget {
  const IntroPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<IntroPageViewModel>.reactive(
      viewModelBuilder: () => IntroPageViewModel(),
      onModelReady: (model) {
        model.init();
      },
      builder: (context, model, _) {
        return PageView(
          controller: model.pageController,
          children: [
            FirstIntro(onConfirmTap: () {
              model.navigateToView(context, const LoginScreen());
            }),
            // Uncomment and update other intros as needed
            // SecondIntro(onNextTap: () {
            //   model.pageNavigator(2);
            // }),
            // ThirdIntro(onConfirmTap: () {
            //   model.navigateToView(context, const EstateListingView());
            // }),
          ],
        );
      },
    );
  }
}
