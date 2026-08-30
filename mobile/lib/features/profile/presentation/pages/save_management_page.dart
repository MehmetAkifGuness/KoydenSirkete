import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/database/player_state_store.dart';
import '../../../../core/widgets/app_page.dart';

class SaveManagementPage extends StatefulWidget {
  const SaveManagementPage({
    required this.store,
    required this.onSlotSelected,
    super.key,
  });

  final SaveSlotStore store;
  final Future<void> Function(int slot) onSlotSelected;

  @override
  State<SaveManagementPage> createState() => _SaveManagementPageState();
}

class _SaveManagementPageState extends State<SaveManagementPage> {
  late Future<List<SaveSlotInfo>> _slots = widget.store.listSlots();
  bool _busy = false;

  void _reload() => setState(() => _slots = widget.store.listSlots());

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Kayıt yönetimi',
      subtitle: 'Üç bağımsız yerel kariyer ve taşınabilir yedekler.',
      child: FutureBuilder<List<SaveSlotInfo>>(
        future: _slots,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Kayıtları yeniden oku'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              const Text(
                'Dışa aktarma veriyi panoya kopyalar. İçe aktarma hedef yuvanın '
                'önceki sağlam sürümünü yerel yedek olarak korur.',
                style: TextStyle(color: AppPalette.textSecondary),
              ),
              const SizedBox(height: 14),
              for (final slot in snapshot.data!) ...[
                _SaveSlotCard(
                  info: slot,
                  active: slot.slot == widget.store.activeSlot,
                  busy: _busy,
                  onSelect: () => _select(slot.slot),
                  onExport: slot.hasSave && slot.isHealthy
                      ? () => _export(slot.slot)
                      : null,
                  onImport: () => _import(slot.slot),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _select(int slot) async {
    if (_busy || slot == widget.store.activeSlot) return;
    await _run(() async {
      await widget.store.switchSlot(slot);
      await widget.onSlotSelected(slot);
    }, 'Kayıt yuvası $slot açıldı.');
  }

  Future<void> _export(int slot) async {
    await _run(() async {
      final data = await widget.store.exportSlot(slot);
      await Clipboard.setData(ClipboardData(text: data));
    }, 'Yuva $slot panoya kopyalandı.');
  }

  Future<void> _import(int slot) async {
    final controller = TextEditingController();
    final data = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$slot. yuvaya içe aktar'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Dışa aktarılan kayıt metni',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Doğrula ve aktar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (data == null || data.trim().isEmpty) return;
    await _run(() async {
      await widget.store.importSlot(data, slot: slot);
      await widget.onSlotSelected(slot);
    }, 'Kayıt doğrulandı ve $slot. yuvaya aktarıldı.');
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    String message = success;
    try {
      await action();
      _reload();
    } on SaveDataException catch (error) {
      message = error.message;
    } catch (_) {
      message =
          'Kayıt işlemi tamamlanamadı; mevcut veri korunuyor. Tekrar deneyin.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _SaveSlotCard extends StatelessWidget {
  const _SaveSlotCard({
    required this.info,
    required this.active,
    required this.busy,
    required this.onSelect,
    required this.onExport,
    required this.onImport,
  });

  final SaveSlotInfo info;
  final bool active;
  final bool busy;
  final VoidCallback onSelect;
  final VoidCallback? onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final status = !info.hasSave
        ? 'Boş yuva'
        : !info.isHealthy
        ? 'Bütünlük hatası · sağlam yedek açılışta denenir'
        : 'Gün ${info.day} · ₺${info.money}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(active ? Icons.check_circle : Icons.save_outlined),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${info.slot}. kayıt yuvası${active ? " · Aktif" : ""}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              status,
              style: const TextStyle(color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: busy || active ? null : onSelect,
                  child: Text(active ? 'Açık' : 'Bu yuvayı aç'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onExport,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Dışa aktar'),
                ),
                FilledButton.tonalIcon(
                  onPressed: busy ? null : onImport,
                  icon: const Icon(Icons.content_paste_rounded),
                  label: const Text('İçe aktar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
