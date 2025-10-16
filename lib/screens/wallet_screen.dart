import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../services/db/app_database.dart';
import '../providers/auth_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _coins = 0;
  List<WalletTransaction> _tx = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final db = context.read<AppDatabase>();
    final user = auth.currentUser;
    if (user == null) {
      setState(() { _loading = false; });
      return;
    }
    final coins = await db.getZenCoins(user.id);
    final tx = await (db.select(db.walletTransactions)
          ..where((t) => t.userId.equals(user.id))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.timestamp)])).get();
    setState(() {
      _coins = coins;
      _tx = tx;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  _buildZenCoinsHeader(),
            const SizedBox(height: 24),
                  _buildTransactionsList(),
                  const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildZenCoinsHeader() {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
            'Zen Coins',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
            '🪙 ' + _coins.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_tx.isEmpty)
          Center(
            child: Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ..._tx.map((t) => _buildTxTile(t)),
      ],
    );
  }

  Widget _buildTxTile(WalletTransaction t) {
    final isCredit = t.amountCoins > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isCredit ? Colors.green : Colors.red).withOpacity(0.12),
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red, size: 18),
        ),
        title: Text(t.type.replaceAll('_', ' ')),
        subtitle: Text(DateFormat('MMM dd, yyyy - HH:mm').format(t.timestamp)),
        trailing: Text(
          (isCredit ? '+ ' : '- ') + '🪙 ' + t.amountCoins.abs().toString(),
          style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
} 