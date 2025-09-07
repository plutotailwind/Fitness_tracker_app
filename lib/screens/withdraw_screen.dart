import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  
  String _selectedWithdrawalMethod = 'bank';
  String _selectedBank = '';
  bool _isProcessing = false;

  final List<String> _predefinedAmounts = ['100', '500', '1000', '2000', '5000'];
  final List<String> _banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'Bank of India',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Money'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Withdrawal Method Selection
              _buildWithdrawalMethodSection(),
              const SizedBox(height: 24),
              
              // Amount Selection
              _buildAmountSection(),
              const SizedBox(height: 24),
              
              // Bank Details (if bank transfer selected)
              if (_selectedWithdrawalMethod == 'bank') ...[
                _buildBankDetailsSection(),
                const SizedBox(height: 24),
              ],
              
              // Withdrawal Button
              _buildWithdrawButton(),
              const SizedBox(height: 32), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawalMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdrawal Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bank Transfer Option
        Card(
          child: RadioListTile<String>(
            value: 'bank',
            groupValue: _selectedWithdrawalMethod,
            onChanged: (value) {
              setState(() {
                _selectedWithdrawalMethod = value!;
              });
            },
            title: const Row(
              children: [
                Icon(Icons.account_balance, color: Colors.blue),
                SizedBox(width: 12),
                Text('Bank Transfer'),
              ],
            ),
            subtitle: const Text('Transfer to your bank account (2-3 business days)'),
          ),
        ),
        
        // Digital Wallet Option
        Card(
          child: RadioListTile<String>(
            value: 'wallet',
            groupValue: _selectedWithdrawalMethod,
            onChanged: (value) {
              setState(() {
                _selectedWithdrawalMethod = value!;
              });
            },
            title: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.green),
                SizedBox(width: 12),
                Text('Digital Wallet'),
              ],
            ),
            subtitle: const Text('Transfer to your digital wallet (Instant)'),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount to Withdraw',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Predefined amounts
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _predefinedAmounts.map((amount) {
            final isSelected = _amountController.text == amount;
            return InkWell(
              onTap: () {
                setState(() {
                  _amountController.text = amount;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  '₹$amount',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Custom amount input
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Custom Amount',
            prefixText: '₹',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Enter amount',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < 100) {
              return 'Minimum withdrawal amount is ₹100';
            }
            if (amount > 50000) {
              return 'Maximum withdrawal amount is ₹50,000';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Fee information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Withdrawal Fees',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Bank Transfer: ₹10 per transaction\n• Digital Wallet: Free',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Account Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bank Selection
        DropdownButtonFormField<String>(
          value: _selectedBank.isEmpty ? null : _selectedBank,
          decoration: InputDecoration(
            labelText: 'Select Bank',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_balance),
          ),
          items: _banks.map((bank) {
            return DropdownMenuItem(
              value: bank,
              child: Text(bank),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBank = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a bank';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Account Holder Name
        TextFormField(
          controller: _accountHolderNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Account Number
        TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Account Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_circle),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            if (value.length < 9) {
              return 'Please enter a valid account number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // IFSC Code
        TextFormField(
          controller: _ifscCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.code),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter IFSC code';
            }
            if (value.length != 11) {
              return 'IFSC code must be 11 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Security notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.green[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your bank details are encrypted and secure',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _withdrawMoney,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Withdraw Money',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _withdrawMoney() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate withdrawal processing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal request submitted for ₹${_amountController.text}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
} 