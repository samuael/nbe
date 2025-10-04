import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';
import 'package:nbe/screens/screens.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Transaction transaction;
  const ReportDetailsScreen({super.key, required this.transaction});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final TextStyle _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black.withOpacity(0.6),
    overflow: TextOverflow.visible,
  );
  Setting? setting;

  @override
  void initState() {
    super.initState();
    _getSetting(widget.transaction.settingId);
  }

  void _getSetting(String id) async {
    final db = NBEDatabase.constructor(
        [SettingLocalProvider.createOrReplaceTableString()]);
    final newSetting = await SettingLocalProvider(db).getSettingByID(id);
    setState(() {
      setting = newSetting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${DateFormat.yMMMd().format(widget.transaction.date)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Chip(
                  label: Text(
                      widget.transaction.isCompleted ? 'Completed' : 'Pending'),
                  backgroundColor: widget.transaction.isCompleted
                      ? Colors.green
                      : Colors.orange,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Gold in Grams: ',
                  style: _labelStyle,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${widget.transaction.weight} g',
                  style: _labelStyle,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Specific Gravity:',
                  style: _labelStyle,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${widget.transaction.specificGravity} cm^3',
                  style: _labelStyle,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Karat:',
                  style: _labelStyle,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'K',
                  style: _labelStyle,
                ),
              ),
            ]),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      'Purchasing Rate:',
                      style: _labelStyle,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(widget.transaction.todayRate),
                      style: _labelStyle,
                    ))
              ],
            ),
            Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        overflow: TextOverflow.visible,
                      ),
                    )),
                Expanded(
                  child: Text(
                    currencyFormatter(widget.transaction.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                )
              ],
            ),
            const Divider(),
            TitledContainer(
              "Settings",
              [
                const SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Immediate Payment Amount: ',
                      style: _labelStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '95%',
                      style: _labelStyle,
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Tax per gram',
                      style: _labelStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      setting != null
                          ? (currencyFormatter(setting!.taxPerGram))
                          : '5,000 ብር',
                      style: _labelStyle,
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Bank Fee in percent:',
                      style: _labelStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      setting != null
                          ? '${setting!.bankFeePercentage * 100} %'
                          : '0.01%',
                      style: _labelStyle,
                    ),
                  ),
                ]),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          'Bonus by NBE:',
                          style: _labelStyle,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          setting != null
                              ? '${setting!.excludePercentage * 100} %'
                              : '10%',
                          style: _labelStyle,
                        ))
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
