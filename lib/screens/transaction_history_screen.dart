import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  // Mock transaction data
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      amount: 500.0,
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      category: TransactionCategory.challengeWinnings,
      description: 'Won Fitness Challenge',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Transaction(
      id: '2',
      amount: 100.0,
      type: TransactionType.debit,
      status: TransactionStatus.completed,
      category: TransactionCategory.challengeEntry,
      description: 'Challenge Entry Fee',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '3',
      amount: 1000.0,
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      category: TransactionCategory.addFunds,
      description: 'Added via UPI',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: '4',
      amount: 250.0,
      type: TransactionType.debit,
      status: TransactionStatus.completed,
      category: TransactionCategory.withdrawal,
      description: 'Withdrawn to Bank',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '5',
      amount: 50.0,
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      category: TransactionCategory.referralBonus,
      description: 'Referral Bonus',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Transaction(
      id: '6',
      amount: 200.0,
      type: TransactionType.credit,
      status: TransactionStatus.pending,
      category: TransactionCategory.addFunds,
      description: 'Added via Credit Card',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Transaction> get _filteredTransactions {
    return _transactions.where((transaction) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!transaction.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedFilter != 'all') {
        if (transaction.category.toString().split('.').last != _selectedFilter) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('addFunds', 'Add Funds'),
                      const SizedBox(width: 8),
                      _buildFilterChip('withdrawal', 'Withdrawals'),
                      const SizedBox(width: 8),
                      _buildFilterChip('challengeEntry', 'Challenge Entry'),
                      const SizedBox(width: 8),
                      _buildFilterChip('challengeWinnings', 'Winnings'),
                      const SizedBox(width: 8),
                      _buildFilterChip('referralBonus', 'Referral'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                    scrollDirection: Axis.vertical,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTransactionIcon(transaction.category),
            color: _getTransactionColor(transaction.category),
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(transaction.timestamp),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (transaction.paymentMethod != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.paymentMethod.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == TransactionType.credit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == TransactionType.credit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (transaction.referenceId != null)
              Text(
                'Ref: ${transaction.referenceId}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(transaction.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTransactionIcon(transaction.category),
                    color: _getTransactionColor(transaction.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(transaction.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${transaction.type == TransactionType.credit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == TransactionType.credit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Transaction Details
            _buildDetailRow('Status', transaction.status.toString().split('.').last.toUpperCase()),
            _buildDetailRow('Category', transaction.category.toString().split('.').last.toUpperCase()),
            if (transaction.paymentMethod != null)
              _buildDetailRow('Payment Method', transaction.paymentMethod.toString().split('.').last.toUpperCase()),
            if (transaction.referenceId != null)
              _buildDetailRow('Reference ID', transaction.referenceId!),
            _buildDetailRow('Time', DateFormat('HH:mm:ss').format(transaction.timestamp)),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Download receipt
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt downloaded')),
                      );
                    },
                    child: const Text('Download Receipt'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Report issue
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Issue reported')),
                      );
                    },
                    child: const Text('Report Issue'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.challengeWinnings:
        return Colors.green;
      case TransactionCategory.challengeEntry:
        return Colors.red;
      case TransactionCategory.addFunds:
        return Colors.blue;
      case TransactionCategory.withdrawal:
        return Colors.orange;
      case TransactionCategory.referralBonus:
        return Colors.purple;
      case TransactionCategory.activityReward:
        return Colors.teal;
      case TransactionCategory.zenCoinsPurchase:
        return Colors.amber;
      case TransactionCategory.zenCoinsEarned:
        return Colors.lime;
    }
  }

  IconData _getTransactionIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.challengeWinnings:
        return Icons.emoji_events;
      case TransactionCategory.challengeEntry:
        return Icons.fitness_center;
      case TransactionCategory.addFunds:
        return Icons.account_balance_wallet;
      case TransactionCategory.withdrawal:
        return Icons.account_balance;
      case TransactionCategory.referralBonus:
        return Icons.card_giftcard;
      case TransactionCategory.activityReward:
        return Icons.star;
      case TransactionCategory.zenCoinsPurchase:
        return Icons.shopping_cart;
      case TransactionCategory.zenCoinsEarned:
        return Icons.monetization_on;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }
} 