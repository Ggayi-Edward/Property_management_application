import 'package:propertysmart2/export/file_exports.dart';

class EstateListingViewModel extends BaseViewModel {
  final glory = true;
  final _estates = EstateData().estates;
  List<EstateModel> get estates => _estates;
}
