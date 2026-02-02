import 'package:equatable/equatable.dart';

abstract class PengembalianState extends Equatable {
  const PengembalianState();

  @override
  List<Object?> get props => [];
}

class PengembalianInitial extends PengembalianState {}

class PengembalianLoading extends PengembalianState {}

class PengembalianLoaded extends PengembalianState {
  final List<Map<String, dynamic>> pengembalianList;
  final String searchQuery;
  final String statusFilter;

  const PengembalianLoaded({
    required this.pengembalianList,
    this.searchQuery = '',
    this.statusFilter = 'Semua',
  });

  List<Map<String, dynamic>> get filteredList {
    var filtered = pengembalianList;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((pengembalian) {
        final kode = pengembalian['kode_peminjaman']?.toString().toLowerCase() ?? '';
        final namaUser = pengembalian['nama_user']?.toString().toLowerCase() ?? '';
        final namaAlat = pengembalian['nama_alat']?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();

        return kode.contains(query) || 
               namaUser.contains(query) || 
               namaAlat.contains(query);
      }).toList();
    }

    // Filter by status
    if (statusFilter != 'Semua') {
      filtered = filtered.where((pengembalian) {
        final status = pengembalian['status_pembayaran']?.toString() ?? '';
        if (statusFilter == 'Belum Bayar') {
          return status == 'belum_bayar';
        } else if (statusFilter == 'Lunas') {
          return status == 'lunas';
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  PengembalianLoaded copyWith({
    List<Map<String, dynamic>>? pengembalianList,
    String? searchQuery,
    String? statusFilter,
  }) {
    return PengembalianLoaded(
      pengembalianList: pengembalianList ?? this.pengembalianList,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [pengembalianList, searchQuery, statusFilter];
}

class PengembalianError extends PengembalianState {
  final String message;

  const PengembalianError(this.message);

  @override
  List<Object?> get props => [message];
}

class PengembalianOperationSuccess extends PengembalianState {
  final String message;

  const PengembalianOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PengembalianOperationLoading extends PengembalianState {
  final String operation;

  const PengembalianOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}