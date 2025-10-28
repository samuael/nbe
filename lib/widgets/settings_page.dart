import 'package:nbe/libs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsLoad = context.watch<SettingsBloc>();
    final settingsCall = context.read<SettingsBloc>();
    settingsCall.add(SettingsLoadEvent());

    final selectedSetting =
        (context.watch<SettingBloc>().state as SettingLoaded).setting;

    return SingleChildScrollView(
      child: Column(children: [
        if (settingsLoad.state is SettingsInit)
          Column(
            children: [
              settingItemSkeleton(),
              settingItemSkeleton(),
              settingItemSkeleton(),
              settingItemSkeleton(),
              settingItemSkeleton(),
              settingItemSkeleton(),
            ],
          ),
        if (settingsLoad.state is SettingsLoadFailed)
          settingsLoadingWasNotSuccesful(context),
        if (settingsLoad.state is SettingsLoaded)
          Column(
            children: (settingsLoad.state as SettingsLoaded)
                .settings
                .values
                .map<SettingItem>((elm) {
              return SettingItem(
                elm,
                quoted: selectedSetting.id == elm.id,
              );
            }).toList(),
          ),
      ]),
    );
  }

  Widget settingItemSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Skeleton(
                  width: MediaQuery.of(context).size.width * .2, height: 10),
              SizedBox(width: MediaQuery.of(context).size.width * .3),
              Skeleton(
                  width: MediaQuery.of(context).size.width * .4, height: 10)
            ],
          ),
          const SizedBox(height: 1),
          Skeleton(width: MediaQuery.of(context).size.width * .2, height: 10),
        ],
      ),
    );
  }

  Widget settingsLoadingWasNotSuccesful(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Icon(
            Icons.settings,
            color: Colors.black.withValues(alpha: .8),
          ),
        ),
        Text(
          "Settings loading failed!",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: .5),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<SettingsBloc>().add(SettingsLoadEvent());
          },
          icon: Icon(
            Icons.replay_outlined,
            color: Colors.black.withValues(alpha: .8),
          ),
        )
      ],
    );
  }
}
