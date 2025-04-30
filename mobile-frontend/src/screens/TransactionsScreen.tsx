import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, ActivityIndicator, Alert } from 'react-native';
import { commonStyles, responsiveWidth } from '../styles/commonStyles'; // Import common styles
// TODO: Import the actual API function, e.g., getAccountTransactions
// import { getAccountTransactions } from '../services/api';

// Define the structure for transaction data
interface Transaction {
  id: string;
  date: string;
  description: string;
  amount: number;
  type: 'DEBIT' | 'CREDIT';
}

const TransactionsScreen = () => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  // TODO: Get accountId from context or route params if needed
  const accountId = '1'; // Placeholder

  useEffect(() => {
    const fetchTransactions = async () => {
      setLoading(true);
      setError(null);
      try {
        // TODO: Replace with actual API call
        // const response = await getAccountTransactions(accountId);
        // setTransactions(response.data);

        // Simulate API call for now
        await new Promise(resolve => setTimeout(resolve, 1200)); // Simulate network delay
        const simulatedData: Transaction[] = [
          { id: 't101', date: '2025-04-28', description: 'Grocery Store', amount: 75.50, type: 'DEBIT' },
          { id: 't102', date: '2025-04-27', description: 'Salary Deposit', amount: 2500.00, type: 'CREDIT' },
          { id: 't103', date: '2025-04-26', description: 'Online Purchase', amount: 120.00, type: 'DEBIT' },
          { id: 't104', date: '2025-04-25', description: 'Utility Bill', amount: 95.00, type: 'DEBIT' },
          { id: 't105', date: '2025-04-24', description: 'Friend Transfer', amount: 50.00, type: 'CREDIT' },
        ];
        setTransactions(simulatedData);

      } catch (err: any) {
        console.error('Failed to fetch transactions:', err);
        const errorMessage = err.response?.data?.error?.message || err.message || 'Failed to load transactions.';
        setError(errorMessage);
        Alert.alert('Error', errorMessage);
      } finally {
        setLoading(false);
      }
    };

    fetchTransactions();
  }, [accountId]);

  const renderTransactionItem = ({ item }: { item: Transaction }) => (
    <View style={styles.transactionItem}>
      <View style={styles.transactionDetails}>
        <Text style={styles.transactionDescription}>{item.description}</Text>
        <Text style={styles.transactionDate}>{item.date}</Text>
      </View>
      <Text style={[styles.transactionAmount, item.type === 'CREDIT' ? styles.creditAmount : styles.debitAmount]}>
        {item.type === 'CREDIT' ? '+' : '-'}${item.amount.toFixed(2)}
      </Text>
    </View>
  );

  if (loading) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <ActivityIndicator size="large" color="#007bff" />
        <Text>Loading Transactions...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <Text style={styles.errorText}>Error: {error}</Text>
      </View>
    );
  }

  return (
    <View style={commonStyles.container}>
      <Text style={commonStyles.titleText}>Recent Transactions</Text>
      <FlatList
        data={transactions}
        renderItem={renderTransactionItem}
        keyExtractor={(item) => item.id}
        ListEmptyComponent={<Text style={styles.emptyText}>No transactions found.</Text>}
      />
    </View>
  );
};

// Add specific styles for TransactionsScreen
const styles = StyleSheet.create({
  centerContent: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    color: 'red',
    fontSize: 16,
    textAlign: 'center',
  },
  emptyText: {
    textAlign: 'center',
    marginTop: 20,
    fontSize: 16,
    color: '#6c757d',
  },
  transactionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: responsiveWidth(3.5), // Responsive padding
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 1.0,
    elevation: 1,
  },
  transactionDetails: {
    flex: 1, // Allow details to take available space
    marginRight: 10,
  },
  transactionDescription: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
  },
  transactionDate: {
    fontSize: 12,
    color: '#6c757d',
    marginTop: 2,
  },
  transactionAmount: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  creditAmount: {
    color: '#28a745', // Green for credit
  },
  debitAmount: {
    color: '#dc3545', // Red for debit
  },
});

export default TransactionsScreen;
