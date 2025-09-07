import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  String _upiId = '';
  String _cardNumber = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money'),
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
              // Amount Selection
              _buildAmountSection(),
              const SizedBox(height: 24),
              
              // Payment Method Selection
              _buildPaymentMethodSection(),
              const SizedBox(height: 24),
              
              // Payment Details
              _buildPaymentDetailsSection(),
              const SizedBox(height: 32),
              
              // Add Money Button
              _buildAddMoneyButton(),
              const SizedBox(height: 32), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount to Add',
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
            if (amount < 10) {
              return 'Minimum amount is ₹10';
            }
            if (amount > 100000) {
              return 'Maximum amount is ₹1,00,000';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Payment method cards
        ...PaymentMethod.values.map((method) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              title: Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(method),
                    color: _getPaymentMethodColor(method),
                  ),
                  const SizedBox(width: 12),
                  Text(_getPaymentMethodName(method)),
                ],
              ),
              subtitle: Text(_getPaymentMethodDescription(method)),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentDetailsSection() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.upi:
        return _buildUPIDetails();
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return _buildCardDetails();
      case PaymentMethod.netBanking:
        return _buildNetBankingDetails();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUPIDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UPI Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          onChanged: (value) => _upiId = value,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'example@upi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_circle),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter UPI ID';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid UPI ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will be redirected to your UPI app to complete the payment',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedPaymentMethod == PaymentMethod.creditCard ? 'Credit' : 'Debit'} Card Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Card Number
        TextFormField(
          onChanged: (value) => _cardNumber = value,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.credit_card),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.length < 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Card Holder Name
        TextFormField(
          onChanged: (value) => _cardHolderName = value,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Card Holder Name',
            hintText: 'JOHN DOE',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Expiry Date and CVV
        Row(
          children: [
            Expanded(
              child: TextFormField(
                onChanged: (value) => _expiryDate = value,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 4) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                onChanged: (value) => _cvv = value,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.security),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 3) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetBankingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Net Banking Details',
          style: TextStyle(
            fontSize: 18,
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will be redirected to your bank\'s secure payment gateway',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoneyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _addMoney,
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
                'Add Money',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _addMoney() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added ₹${_amountController.text} to wallet'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
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

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return Icons.account_circle;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.netBanking:
        return Icons.account_balance;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return Colors.purple;
      case PaymentMethod.creditCard:
        return Colors.blue;
      case PaymentMethod.debitCard:
        return Colors.green;
      case PaymentMethod.netBanking:
        return Colors.orange;
      case PaymentMethod.wallet:
        return Colors.teal;
      case PaymentMethod.bankTransfer:
        return Colors.indigo;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Digital Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String _getPaymentMethodDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return 'Pay using UPI apps like Google Pay, PhonePe';
      case PaymentMethod.creditCard:
        return 'Pay using credit card';
      case PaymentMethod.debitCard:
        return 'Pay using debit card';
      case PaymentMethod.netBanking:
        return 'Pay using internet banking';
      case PaymentMethod.wallet:
        return 'Pay using digital wallets';
      case PaymentMethod.bankTransfer:
        return 'Transfer from bank account';
    }
  }
} 