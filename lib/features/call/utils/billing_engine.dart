import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- States ---
abstract class BillingState {}

class BillingInitial extends BillingState {}

class BillingInProgress extends BillingState {
  final int durationSeconds;
  final double currentCost;
  final double walletBalance;
  
  BillingInProgress(this.durationSeconds, this.currentCost, this.walletBalance);
}

class BillingLowBalanceWarning extends BillingInProgress {
  BillingLowBalanceWarning(super.durationSeconds, super.currentCost, super.walletBalance);
}

class BillingEndedDueToInsufficientBalance extends BillingState {
  final int finalDuration;
  final double finalCost;
  
  BillingEndedDueToInsufficientBalance(this.finalDuration, this.finalCost);
}

class BillingEndedManually extends BillingState {
  final int finalDuration;
  final double finalCost;
  
  BillingEndedManually(this.finalDuration, this.finalCost);
}

// --- Events ---
abstract class BillingEvent {}

class StartBillingEvent extends BillingEvent {
  final double perMinuteRate;
  final double initialWalletBalance;
  final String astrologerId;
  final String consultationId;
  final String? astrologerName;
  final bool isBillingEnabled;
  final String consultationType; // 'Audio Call' or 'Video Call'
  
  StartBillingEvent({
    required this.perMinuteRate,
    required this.initialWalletBalance,
    required this.astrologerId,
    required this.consultationId,
    this.astrologerName,
    this.isBillingEnabled = true,
    this.consultationType = 'Call',
  });
}

class _TickEvent extends BillingEvent {}

class StopBillingEvent extends BillingEvent {}

// --- Bloc ---
class BillingEngine extends Bloc<BillingEvent, BillingState> {
  static final BillingEngine _instance = BillingEngine._internal();
  factory BillingEngine() => _instance;
  
  Timer? _timer;
  
  double _perSecondRate = 0.0;
  double _walletBalance = 0.0;
  int _durationSeconds = 0;
  double _currentCost = 0.0;
  bool _isBillingEnabled = true;
  bool _recordsSaved = false;
  
  String? _astrologerId;
  String? _astrologerName;
  String? _consultationId;
  String _consultationType = 'Call';

  BillingEngine._internal() : super(BillingInitial()) {
    on<StartBillingEvent>(_onStartBilling);
    on<_TickEvent>(_onTick);
    on<StopBillingEvent>(_onStopBilling);
  }

  void _onStartBilling(StartBillingEvent event, Emitter<BillingState> emit) {
    _perSecondRate = event.perMinuteRate / 60.0;
    _walletBalance = event.initialWalletBalance;
    _astrologerId = event.astrologerId;
    _astrologerName = event.astrologerName;
    _consultationId = event.consultationId;
    _isBillingEnabled = event.isBillingEnabled;
    _consultationType = event.consultationType;
    _durationSeconds = 0;
    _currentCost = 0.0;
    _recordsSaved = false;
    
    // Stop any existing timer
    _timer?.cancel();
    
    // Check if initial balance is enough for even 1 minute (only if billing is enabled)
    if (_isBillingEnabled && _walletBalance < event.perMinuteRate) {
      emit(BillingEndedDueToInsufficientBalance(_durationSeconds, _currentCost));
      return;
    }
    
    emit(BillingInProgress(_durationSeconds, _currentCost, _walletBalance));
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(_TickEvent());
    });
  }

  void _onTick(_TickEvent event, Emitter<BillingState> emit) {
    _durationSeconds++;
    _currentCost += _perSecondRate;
    _walletBalance -= _perSecondRate;
    
    if (_isBillingEnabled && _walletBalance < _perSecondRate) {
      // Disconnect!
      _timer?.cancel();
      emit(BillingEndedDueToInsufficientBalance(_durationSeconds, _currentCost));
      _saveConsultationRecords();
    } else if (_isBillingEnabled && _walletBalance < (_perSecondRate * 30)) {
      // 30 seconds warning
      emit(BillingLowBalanceWarning(_durationSeconds, _currentCost, _walletBalance));
    } else {
      emit(BillingInProgress(_durationSeconds, _currentCost, _walletBalance));
    }
  }

  void _onStopBilling(StopBillingEvent event, Emitter<BillingState> emit) {
    _timer?.cancel();
    emit(BillingEndedManually(_durationSeconds, _currentCost));
    _saveConsultationRecords();
  }
  
  void _saveConsultationRecords() {
    if (!_isBillingEnabled) return;
    if (_recordsSaved) return;
    _recordsSaved = true;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final costPaise = (_currentCost * 100).toInt();
    if (costPaise <= 0) return;
    
    Future.microtask(() async {
      try {
        final walletRes = await supabase.from('wallets').select('balance_paise').eq('user_id', userId).maybeSingle();
        int currentPaise = 0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          currentPaise = walletRes['balance_paise'] as int;
        }
        
        final newPaise = currentPaise - costPaise;
        
        await supabase.from('wallets').upsert({
          'user_id': userId,
          'balance_paise': newPaise >= 0 ? newPaise : 0,
        }, onConflict: 'user_id');
        final consultationIdToUse = _consultationId?.isNotEmpty == true ? _consultationId! : DateTime.now().millisecondsSinceEpoch.toString();
        
        final astroLabel = _astrologerName?.trim().isNotEmpty == true ? _astrologerName : _astrologerId;
        await supabase.from('wallet_transactions').insert({
          'user_id': userId,
          'amount_paise': costPaise,
          'kind': 'debit',
          'status': 'success',
          'note': 'Call with $astroLabel (ID: $consultationIdToUse)',
        });
        try {
          await supabase.from('consultations').insert({
            'id': consultationIdToUse,
            'user_id': userId,
            'astrologer_id': _astrologerId ?? '',
            'type': _consultationType,
            'status': 'Completed',
            'duration_seconds': _durationSeconds,
            'started_at': DateTime.now().subtract(Duration(seconds: _durationSeconds)).toIso8601String(),
            'ended_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // If inserting throws duplicate PK error, try updating instead
          await supabase.from('consultations').update({
            'status': 'Completed',
            'duration_seconds': _durationSeconds,
            'ended_at': DateTime.now().toIso8601String(),
          }).eq('id', consultationIdToUse);
        }
        
        final netAmount = _currentCost;
        await supabase.from('astrologer_earnings').insert({
          'astrologer_id': _astrologerId ?? '',
          'consultation_id': consultationIdToUse,
          'gross_amount': double.parse(_currentCost.toStringAsFixed(2)),
          'commission_rate': 0.00,
          'net_amount': double.parse(netAmount.toStringAsFixed(2)),
          'status': 'UNPAID',
        });

        // 4. Update astrologer's total_minutes_consulted in the database
        if (_astrologerId != null && _astrologerId!.isNotEmpty) {
          try {
            final isUuid = _astrologerId!.length == 36 && _astrologerId!.contains('-');
            final col = isUuid ? 'id' : 'firebase_uid';
            
            final astroRes = await supabase
                .from('astrologers')
                .select('total_minutes_consulted')
                .eq(col, _astrologerId!)
                .maybeSingle();
                
            if (astroRes != null) {
              final currentMins = (astroRes['total_minutes_consulted'] as num?)?.toInt() ?? 0;
              final addedMins = (_durationSeconds / 60.0).ceil();
              if (addedMins > 0) {
                await supabase
                    .from('astrologers')
                    .update({'total_minutes_consulted': currentMins + addedMins})
                    .eq(col, _astrologerId!);
              }
            }
          } catch (err) {
            print('Error updating astrologer consulted minutes: $err');
          }
        }
      } catch (e) {
        print('Error saving consultation records: $e');
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  /// Backward compatibility for existing calculateProRataDeduction usages
  static double calculateProRataDeduction({
    required int elapsedSeconds,
    required double pricePerMinute,
  }) {
    if (elapsedSeconds <= 0 || pricePerMinute <= 0) return 0.0;
    double exactDeduction = (elapsedSeconds / 60.0) * pricePerMinute;
    return double.parse(exactDeduction.toStringAsFixed(2));
  }
}
