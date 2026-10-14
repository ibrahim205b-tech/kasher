import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/invoice.dart';
import '../../data/repositories/invoice_repository.dart';

final invoicesRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository();
});

class InvoicesState {
  final List<Invoice> invoices;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  InvoicesState({
    this.invoices = const [],
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  InvoicesState copyWith({
    List<Invoice>? invoices,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
    bool? isLoading,
  }) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InvoicesNotifier extends StateNotifier<InvoicesState> {
  final InvoiceRepository repository;

  InvoicesNotifier(this.repository) : super(InvoicesState()) {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    state = state.copyWith(isLoading: true);
    final invoices = await repository.getInvoices(
      searchQuery: state.searchQuery,
      startDate: state.startDate,
      endDate: state.endDate,
    );
    state = state.copyWith(invoices: invoices, isLoading: false);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadInvoices();
  }

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
    loadInvoices();
  }

  void clearDateRange() {
    state = state.copyWith(clearDates: true);
    loadInvoices();
  }

  Future<void> createInvoice(Invoice invoice) async {
    await repository.createInvoice(invoice);
    await loadInvoices();
  }

  Future<void> cancelInvoice(String invoiceId, String reason) async {
    await repository.cancelInvoice(invoiceId, reason);
    await loadInvoices();
  }
}

final invoicesNotifierProvider =
    StateNotifierProvider<InvoicesNotifier, InvoicesState>((ref) {
  final repository = ref.watch(invoicesRepositoryProvider);
  return InvoicesNotifier(repository);
});
