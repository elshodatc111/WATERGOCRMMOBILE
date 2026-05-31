import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/currer_balans_detal_model.dart';
import 'package:water_go/models/currer/currer_balans_history_model.dart';
import 'package:water_go/models/currer/currer_balans_model.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_kassa_service.dart';
import 'package:water_go/service/snack_service.dart';

class CurrerKassaScreen extends StatefulWidget {
  const CurrerKassaScreen({super.key});

  @override
  State<CurrerKassaScreen> createState() => _CurrerKassaScreenState();
}

class _CurrerKassaScreenState extends State<CurrerKassaScreen> {
  late Future<CurrerBalansDetalModel> _balansFuture;
  final GetStorage _storage = GetStorage();
  late final CurrerKassaService _service;

  final Set<int> _loadingIds = <int>{};
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _service = CurrerKassaService(
      token: _storage.read('auth_token') ?? '',
    );
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _refreshCounter++;
      _balansFuture = _service.getBalansDetail();
    });
  }

  Future<void> _handleConfirm(int id) async {
    setState(() => _loadingIds.add(id));
    try {
      await _service.kirimSuccess(id);
      if (mounted) {
        SnackService.showSnack(context: context, message: "Muvaffaqiyatli tasdiqlandi", isSuccess: true);
      }
      _refreshData();
    } catch (e) {
      if (mounted) {
        SnackService.showSnack(context: context, message: e.toString(), isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingIds.remove(id));
      }
    }
  }

  Future<void> _handleCancel(int id) async {
    setState(() => _loadingIds.add(id));
    try {
      await _service.chiqimCancel(id);
      if (mounted) {
        SnackService.showSnack(context: context, message: "Muvaffaqiyatli bekor qilindi", isSuccess: true);
      }
      _refreshData();
    } catch (e) {
      if (mounted) {
        SnackService.showSnack(context: context, message: e.toString(), isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingIds.remove(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Kassa",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<CurrerBalansDetalModel>(
        // 3. SHU YERDA: Kalit o'zgargani sababli FutureBuilder yangi ma'lumotni majburlab yuklaydi
        key: ValueKey(_refreshCounter),
        future: _balansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Xatolik yuz berdi: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text("Qayta urinish"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Ma'lumot topilmadi"));
          }
          final data = snapshot.data!;
          return Column(
            children: [
              Expanded(flex: 3, child: _buildBalansSection(data.balans)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Text(
                  "Amaliyotlar tarixi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.navy,
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: data.history.isEmpty
                    ? const Center(child: Text("Amaliyotlar tarix mavjud emas"))
                    : _buildHistorySection(data.history),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalansSection(CurrerBalansModel balans) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorConst.navy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalansItem("Naqd summa", "${balans.cash} UZS", Icons.money),
              _buildBalansItem(
                "Plastik summa",
                "${balans.card} UZS",
                Icons.credit_card,
              ),
              _buildBalansItem(
                "Bank summa",
                "${balans.bank} UZS",
                Icons.account_balance,
              ),
            ],
          ),
          const Divider(color: Colors.white24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalansItem(
                "Tayyor mahsulot",
                "${balans.full_contaner} ta",
                Icons.local_drink,
              ),
              _buildBalansItem(
                "Bo'sh idish",
                "${balans.empty_contaner} ta",
                Icons.local_drink_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalansItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ColorConst.bluePale, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(List<CurrerBalansHistoryModel> history) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final bool isKirim = item.status == 1;
        final bool isLoading = _loadingIds.contains(item.id);
        final String status = item.type == 'out_full_contaner' ? 'input' : 'output';
        final String type = item.type == 'out_full_contaner'
            ? "Maxsulot: ${item.count}"
            : item.type == 'inp_empty_contaner'
            ? "Bo'sh idish: ${item.count}"
            : item.type == 'inp_def_contaner'
            ? "Nosoz idish: ${item.count}"
            : item.type == 'inp_full_contaner'
            ? "Tayyor maxsulot: ${item.count}"
            : item.type == 'inp_bank'
            ? "Bank: ${item.count} UZS"
            : item.type == 'inp_card'
            ? "Karta: ${item.count} UZS"
            : "Naqt: ${item.count} UZS";

        return Card(
          color: ColorConst.card,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ColorConst.border, width: 1.2),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isKirim
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                status == 'input' ? Icons.arrow_downward : Icons.arrow_upward,
                color: isKirim ? Colors.green : Colors.red,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.type == 'out_full_contaner'
                      ? 'Ombordan olindi'
                      : 'Omborga yetkazildi',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isKirim ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Omborchi: ${item.omborchi}",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        item.created_at.length >= 10
                            ? item.created_at.substring(0, 10)
                            : item.created_at,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),

                  if (item.status == 0) ...[
                    const SizedBox(height: 12),
                    item.type == 'out_full_contaner'
                        ? _buildActionButton(
                      label: "Tasdiqlash",
                      color: Colors.green,
                      isLoading: isLoading,
                      onPressed: () => _handleConfirm(item.id),
                    )
                        : _buildActionButton(
                      label: "Bekor qilish",
                      color: ColorConst.red,
                      isLoading: isLoading,
                      onPressed: () => _handleCancel(item.id),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: isLoading ? color.withOpacity(0.6) : color,
        border: Border.all(
          color: ColorConst.border,
          width: 1.2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          label,
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}