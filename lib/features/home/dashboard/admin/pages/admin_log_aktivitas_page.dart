import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_log_aktivitas_cubit.dart';
import 'package:rentalify/features/home/dashboard/admin/cubit/admin_log_aktivitas_state.dart';
import 'package:intl/intl.dart';

class LogAktivitasPage extends StatelessWidget {
  const LogAktivitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LogAktivitasCubit()..loadLogs(),
      child: const _LogAktivitasPageContent(),
    );
  }
}

class _LogAktivitasPageContent extends StatefulWidget {
  const _LogAktivitasPageContent();

  @override
  State<_LogAktivitasPageContent> createState() =>
      _LogAktivitasPageContentState();
}

class _LogAktivitasPageContentState extends State<_LogAktivitasPageContent> {
  String _selectedTableFilter = 'Semua';
  String _selectedOperasiFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Tabel',
                        value: _selectedTableFilter,
                        items: [
                          'Semua',
                          'alat',
                          'users',
                          'peminjaman',
                          'pengembalian',
                          'kategori'
                        ],
                        displayNames: {
                          'Semua': 'Semua',
                          'alat': 'Alat',
                          'users': 'Users',
                          'peminjaman': 'Peminjaman',
                          'pengembalian': 'Pengembalian',
                          'kategori': 'Kategori',
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedTableFilter = value!;
                          });
                          context.read<LogAktivitasCubit>().filterByTable(
                                value!,
                                _selectedOperasiFilter,
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Operasi',
                        value: _selectedOperasiFilter,
                        items: ['Semua', 'INSERT', 'UPDATE', 'DELETE'],
                        displayNames: {},
                        onChanged: (value) {
                          setState(() {
                            _selectedOperasiFilter = value!;
                          });
                          context.read<LogAktivitasCubit>().filterByOperasi(
                                value!,
                                _selectedTableFilter,
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timeline List
          Expanded(
            child: BlocBuilder<LogAktivitasCubit, LogAktivitasState>(
              builder: (context, state) {
                if (state is LogAktivitasLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is LogAktivitasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<LogAktivitasCubit>().refreshLogs(
                                  tableFilter: _selectedTableFilter,
                                  operasiFilter: _selectedOperasiFilter,
                                );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is LogAktivitasLoaded) {
                  if (state.logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada log aktivitas',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTableFilter != 'Semua' ||
                                    _selectedOperasiFilter != 'Semua'
                                ? 'Coba ubah filter'
                                : 'Belum ada aktivitas yang tercatat',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<LogAktivitasCubit>().refreshLogs(
                            tableFilter: _selectedTableFilter,
                            operasiFilter: _selectedOperasiFilter,
                          );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) {
                        final log = state.logs[index];
                        final isLast = index == state.logs.length - 1;
                        return _buildTimelineItem(log, isLast);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Map<String, String> displayNames,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(displayNames[item] ?? item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> log, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getOperasiColor(log['operasi']).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getOperasiColor(log['operasi']),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getOperasiIcon(log['operasi']),
                  color: _getOperasiColor(log['operasi']),
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildLogCard(log),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final user = log['users'] as Map<String, dynamic>?;
    final userName = user?['nama'] ?? 'Unknown User';
    final userEmail = user?['email'] ?? 'No Email';

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(log),
          borderRadius: BorderRadius.circular(12),
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
                      child: Row(
                        children: [
                          _buildOperasiBadge(log['operasi']),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatTableName(log['nama_tabel']),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Timestamp
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateTime(log['waktu_operasi']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Preview Data
                if (log['operasi'] == 'INSERT' || log['operasi'] == 'UPDATE') ...[
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  _buildDataPreview(log),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperasiBadge(String operasi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getOperasiColor(operasi).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        operasi,
        style: TextStyle(
          color: _getOperasiColor(operasi),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDataPreview(Map<String, dynamic> log) {
    final dataBaru = log['data_baru'] as Map<String, dynamic>?;
    if (dataBaru == null || dataBaru.isEmpty) return const SizedBox.shrink();

    final entries = dataBaru.entries.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Data:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ...entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          TextSpan(
                            text: _formatValue(entry.value),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        if (dataBaru.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${dataBaru.length - 3} data lainnya',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Color _getOperasiColor(String operasi) {
    switch (operasi) {
      case 'INSERT':
        return AppColors.success;
      case 'UPDATE':
        return AppColors.info;
      case 'DELETE':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getOperasiIcon(String operasi) {
    switch (operasi) {
      case 'INSERT':
        return Icons.add_circle;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.circle;
    }
  }

  String _formatTableName(String tableName) {
    final Map<String, String> tableNames = {
      'alat': 'ALAT',
      'users': 'USERS',
      'peminjaman': 'PEMINJAMAN',
      'pengembalian': 'PENGEMBALIAN',
      'kategori': 'KATEGORI',
      'setting_denda': 'SETTING DENDA',
    };
    return tableNames[tableName] ?? tableName.toUpperCase();
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '-';
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String && value.length > 50) {
      return '${value.substring(0, 50)}...';
    }
    return value.toString();
  }

  void _showDetailDialog(Map<String, dynamic> log) {
    final user = log['users'] as Map<String, dynamic>?;
    final userName = user?['nama'] ?? 'Unknown User';
    final userEmail = user?['email'] ?? 'No Email';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            _buildOperasiBadge(log['operasi']),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatTableName(log['nama_tabel']),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection('User', userName),
              _buildDetailSection('Email', userEmail),
              _buildDetailSection('Waktu', _formatDateTime(log['waktu_operasi'])),
              _buildDetailSection('ID Record', log['id_record']?.toString() ?? '-'),
              const Divider(color: AppColors.border),

              if (log['data_lama'] != null) ...[
                const Text(
                  'Data Lama:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                _buildJsonData(log['data_lama']),
                const SizedBox(height: 12),
              ],

              if (log['data_baru'] != null) ...[
                Text(
                  log['operasi'] == 'INSERT' ? 'Data:' : 'Data Baru:',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                _buildJsonData(log['data_baru']),
              ],
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

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonData(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}:',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}