import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, ActivityIndicator, RefreshControl } from 'react-native';
import { commonStyles, colors, responsiveWidth } from '../styles/commonStyles'; // Import common styles and colors
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
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // TODO: Get accountId from context or route params if needed
  const accountId = '1'; // Placeholder

  const fetchTransactions = async (isRefreshing = false) => {
    if (!isRefreshing) {
      setLoading(true);
    }
    setError(null);
    try {
      // TODO: Replace with actual API call
      // const response = await getAccountTransactions(accountId);
      // setTransactions(response.data);

      // Simulate API call for now
      await new Promise(resolve => setTimeout(resolve, 1200)); // Simulate network delay
      const simulatedData: Transaction[] = [
        { id: 't101', date: '2025-04-28', description: 'Grocery Store Run', amount: 75.50, type: 'DEBIT' },
        { id: 't102', date: '2025-04-27', description: 'Monthly Salary Deposit', amount: 2500.00, type: 'CREDIT' },
        { id: 't103', date: '2025-04-26', description: 'Online Shopping - Gadget', amount: 120.00, type: 'DEBIT' },
        { id: 't104', date: '2025-04-25', description: 'Electricity Bill Payment', amount: 95.00, type: 'DEBIT' },
        { id: 't105', date: '2025-04-24', description: 'Transfer from Jane Doe', amount: 50.00, type: 'CREDIT' },
        { id: 't106', date: '2025-04-23', description: 'Coffee Shop', amount: 5.75, type: 'DEBIT' },
        { id: 't107', date: '2025-04-22', description: 'Restaurant Dinner', amount: 65.20, type: 'DEBIT' },
      ];
      setTransactions(simulatedData);

    } catch (err: any) {
      console.error('Failed to fetch transactions:', err);
      const errorMessage = err.response?.data?.error?.message || err.message || 'Failed to load transactions.';
      setError(errorMessage);
      // Alert.alert('Error', errorMessage); // Optionally show alert
    } finally {
      if (!isRefreshing) {
        setLoading(false);
      }
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [accountId]);

  const onRefresh = () => {
    setRefreshing(true);
    fetchTransactions(true);
  };

  const renderTransactionItem = ({ item }: { item: Transaction }) => (
    <View style={[commonStyles.card, styles.transactionItem]}> {/* Use card style */}
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
        <ActivityIndicator size="large" color={colors.primary} />
        <Text style={styles.loadingText}>Loading Transactions...</Text>
      </View>
    );
  }

  if (error && transactions.length === 0) { // Show error only if no data is loaded
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <Text style={commonStyles.errorText}>Error: {error}</Text>
        {/* Optionally add a retry button */}
      </View>
    );
  }

  return (
    <View style={commonStyles.container}>
      <Text style={commonStyles.titleText}>Recent Transactions</Text>
      {error && <Text style={[commonStyles.errorText, styles.inlineError]}>Failed to refresh: {error}</Text>} {/* Show refresh error inline */}
      <FlatList
        data={transactions}
        renderItem={renderTransactionItem}
        keyExtractor={(item) => item.id}
        ListEmptyComponent={<Text style={styles.emptyText}>No transactions found.</Text>}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={[colors.primary]} tintColor={colors.primary} />
        }
      />
    </View>
  );
};

// Add specific styles for TransactionsScreen
const styles = StyleSheet.create({
  centerContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: colors.textSecondary,
  },
  inlineError: {
    marginBottom: 10,
  },
  emptyText: {
    textAlign: 'center',
    marginTop: 50,
    fontSize: 16,
    color: colors.textSecondary,
  },
  listContainer: {
    paddingBottom: 20, // Add padding at the bottom of the list
  },
  transactionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12, // Use marginBottom from commonStyles.card or adjust as needed
    padding: 15, // Adjust padding within the card
  },
  transactionDetails: {
    flex: 1, // Allow details to take available space
    marginRight: 10,
  },
  transactionDescription: {
    fontSize: 16,
    fontWeight: '500',
    color: colors.textPrimary,
    marginBottom: 4, // Add space between description and date
  },
  transactionDate: {
    fontSize: 13,
    color: colors.textSecondary,
  },
  transactionAmount: {
    fontSize: 17,
    fontWeight: '600', // Semibold
  },
  creditAmount: {
    color: colors.secondary, // Use secondary color (green) for credit
  },
  debitAmount: {
    color: colors.error, // Use error color (red) for debit
  },
});

export default TransactionsScreen;

