import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentalify/core/themes/app_colors.dart';

class BorrowerTanggunganPage extends StatefulWidget {
  const BorrowerTanggunganPage({super.key});

  @override
  State<BorrowerTanggunganPage> createState() => _BorrowerTanggunganPageState();
}

class _BorrowerTanggunganPageState extends State<BorrowerTanggunganPage> {
  // Dummy data - alat yang harus dikembalikan (status: dipinjam/terlambat)
  final List<Map<String, dynamic>> _tanggunganList = [
    {
      'id_peminjaman': 1,
      'kode_peminjaman': 'PMJ-2024-001',
      'alat': {
        'nama_alat': 'OBD2 Scanner Launch X431 Pro',
        'kategori': 'Diagnostic Tools',
        'foto_alat': null,
      },
      'jumlah_pinjam': 1,
      'tanggal_pinjam': '2024-01-15',
      'tanggal_kembali_rencana': '2024-01-22',
      'status_peminjaman': 'dipinjam',
      'keperluan': 'Untuk diagnosis kendaraan pelanggan',
    },
    {
      'id_peminjaman': 2,
      'kode_peminjaman': 'PMJ-2024-005',
      'alat': {
        'nama_alat': 'Hydraulic Jack 3 Ton',
        'kategori': 'Hand Tools',
        'foto_alat': null,
      },
      'jumlah_pinjam': 2,
      'tanggal_pinjam': '2024-01-10',
      'tanggal_kembali_rencana': '2024-01-17',
      'status_peminjaman': 'terlambat',
      'keperluan': 'Untuk servis kendaraan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final jumlahTerlambat = _tanggunganList
        .where((t) => t['status_peminjaman'] == 'terlambat')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tanggungan Pengembalian'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh
        },
        child: _tanggunganList.isEmpty
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: jumlahTerlambat > 0
                            ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                            : [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                jumlahTerlambat > 0
                                    ? Icons.warning
                                    : Icons.assignment_return,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jumlahTerlambat > 0
                                        ? 'Ada Keterlambatan!'
                                        : 'Tanggungan Aktif',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_tanggunganList.length} alat harus dikembalikan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (jumlahTerlambat > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$jumlahTerlambat alat terlambat! Segera hubungi petugas untuk pengembalian',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Pengembalian
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cara Pengembalian',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Untuk mengembalikan alat, silakan datang ke tempat peminjaman dan hubungi petugas. Petugas akan memproses pengembalian Anda.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.info,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // List Title
                  Text(
                    'Daftar Alat yang Harus Dikembalikan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  // List
                  ..._tanggunganList.map((tanggungan) => _buildTanggunganCard(tanggungan)),
                  const SizedBox(height: 100), // Bottom padding for navbar
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Tanggungan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Anda tidak memiliki alat yang harus dikembalikan',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTanggunganCard(Map<String, dynamic> tanggungan) {
    final alat = tanggungan['alat'];
    final tanggalPinjam = DateTime.parse(tanggungan['tanggal_pinjam']);
    final tanggalKembaliRencana = DateTime.parse(tanggungan['tanggal_kembali_rencana']);
    final isLate = tanggungan['status_peminjaman'] == 'terlambat';
    final today = DateTime.now();
    final daysLate = isLate ? today.difference(tanggalKembaliRencana).inDays : 0;
    final daysUntilDue = tanggalKembaliRencana.difference(today).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLate ? AppColors.error.withOpacity(0.5) : AppColors.border,
          width: isLate ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(tanggungan),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tanggungan['kode_peminjaman'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLate
                            ? AppColors.error.withOpacity(0.2)
                            : AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLate ? Icons.warning : Icons.schedule,
                            size: 12,
                            color: isLate ? AppColors.error : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLate ? 'Terlambat' : 'Aktif',
                            style: TextStyle(
                              color: isLate ? AppColors.error : AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (isLate) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.error),
                        const SizedBox(width: 6),
                        Text(
                          'Terlambat $daysLate hari',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Alat Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alat['nama_alat'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${alat['kategori']} • Jumlah: ${tanggungan['jumlah_pinjam']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo(
                          Icons.calendar_today,
                          'Dipinjam',
                          DateFormat('dd MMM yyyy').format(tanggalPinjam),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: _buildDateInfo(
                          Icons.event,
                          'Jatuh Tempo',
                          DateFormat('dd MMM yyyy').format(tanggalKembaliRencana),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Countdown or Late Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLate
                        ? AppColors.error.withOpacity(0.1)
                        : daysUntilDue <= 2
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLate
                          ? AppColors.error.withOpacity(0.3)
                          : daysUntilDue <= 2
                              ? AppColors.warning.withOpacity(0.3)
                              : AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLate
                            ? Icons.error_outline
                            : daysUntilDue <= 2
                                ? Icons.warning_amber
                                : Icons.info_outline,
                        size: 16,
                        color: isLate
                            ? AppColors.error
                            : daysUntilDue <= 2
                                ? AppColors.warning
                                : AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLate
                              ? 'Segera hubungi petugas untuk pengembalian! Denda mungkin dikenakan.'
                              : daysUntilDue <= 2
                                  ? 'Hampir jatuh tempo! Segera kembalikan dalam $daysUntilDue hari.'
                                  : 'Sisa waktu peminjaman: $daysUntilDue hari',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLate
                                ? AppColors.error
                                : daysUntilDue <= 2
                                    ? AppColors.warning
                                    : AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(IconData icon, String label, String date) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showDetailDialog(Map<String, dynamic> tanggungan) {
    final alat = tanggungan['alat'];
    final isLate = tanggungan['status_peminjaman'] == 'terlambat';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(tanggungan['kode_peminjaman']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Alat', alat['nama_alat']),
              _buildDetailRow('Kategori', alat['kategori']),
              _buildDetailRow('Jumlah', '${tanggungan['jumlah_pinjam']} unit'),
              _buildDetailRow('Tanggal Pinjam', tanggungan['tanggal_pinjam']),
              _buildDetailRow('Jatuh Tempo', tanggungan['tanggal_kembali_rencana']),
              _buildDetailRow('Status', isLate ? 'Terlambat' : 'Aktif'),
              const Divider(color: AppColors.border),
              const Text(
                'Keperluan:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tanggungan['keperluan'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Untuk pengembalian, silakan datang ke tempat peminjaman dan hubungi petugas.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}