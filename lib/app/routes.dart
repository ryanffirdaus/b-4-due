/// Route paths in one place so screens never hard-code strings.
abstract final class Routes {
  // Bottom navigation tabs.
  static const home = '/';
  static const calendar = '/calendar';
  static const subscriptions = '/subscriptions';
  static const statistics = '/statistics';
  static const settings = '/settings';

  // Full-screen pages pushed above the tabs.
  static const addBill = '/add';
  static const onboarding = '/welcome';
  static const history = '/history';
  static const setPin = '/settings/pin';
  static const battery = '/settings/battery';

  static String newBill({String? templateKey}) => templateKey == null
      ? '/add/form'
      : Uri(
          path: '/add/form',
          queryParameters: {'template': templateKey},
        ).toString();

  static String billDetail(String id) => '/bill/$id';
  static String editBill(String id) => '/bill/$id/edit';
}
