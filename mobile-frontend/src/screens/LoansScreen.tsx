import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, ActivityIndicator, Alert, TouchableOpacity } from 'react-native';
import { commonStyles, responsiveWidth } from '../styles/commonStyles'; // Import common styles
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/AppNavigator';
// TODO: Import the actual API function, e.g., getAccountLoans, applyForLoan
// import { getAccountLoans, applyForLoan } from '../services/api';

// Define the structure for loan data
interface Loan {
  id: string;
  type: string;
  amount: number;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'ACTIVE' | 'PAID';
  appliedDate: string;
}

// Define the navigation prop type for this screen
type LoansScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Loans'>;

const LoansScreen = () => {
  const [loans, setLoans] = useState<Loan[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigation = useNavigation<LoansScreenNavigationProp>();
  // TODO: Get accountId from context or route params if needed
  const accountId = '1'; // Placeholder

  useEffect(() => {
    const fetchLoans = async () => {
      setLoading(true);
      setError(null);
      try {
        // TODO: Replace with actual API call
        // const response = await getAccountLoans(accountId);
        // setLoans(response.data);

        // Simulate API call for now
        await new Promise(resolve => setTimeout(resolve, 1100)); // Simulate network delay
        const simulatedData: Loan[] = [
          { id: 'l201', type: 'Personal Loan', amount: 10000, status: 'ACTIVE', appliedDate: '2024-11-15' },
          { id: 'l202', type: 'Mortgage', amount: 250000, status: 'APPROVED', appliedDate: '2025-03-01' },
          { id: 'l203', type: 'Car Loan', amount: 20000, status: 'PENDING', appliedDate: '2025-04-20' },
        ];
        setLoans(simulatedData);

      } catch (err: any) {
        console.error('Failed to fetch loans:', err);
        const errorMessage = err.response?.data?.error?.message || err.message || 'Failed to load loans.';
        setError(errorMessage);
        Alert.alert('Error', errorMessage);
      } finally {
        setLoading(false);
      }
    };

    fetchLoans();
  }, [accountId]);

  const handleApplyLoan = () => {
    // TODO: Implement navigation to a loan application form screen or modal
    Alert.alert('Apply for Loan', 'Navigation to loan application form not implemented yet.');
    // Example: navigation.navigate('ApplyLoanForm');
  };

  const renderLoanItem = ({ item }: { item: Loan }) => (
    <View style={styles.loanItem}>
      <View style={styles.loanDetails}>
        <Text style={styles.loanType}>{item.type}</Text>
        <Text style={styles.loanDate}>Applied: {item.appliedDate}</Text>
        <Text style={styles.loanAmount}>Amount: ${item.amount.toFixed(2)}</Text>
      </View>
      <Text style={[styles.loanStatus, getStatusStyle(item.status)]}>
        {item.status}
      </Text>
    </View>
  );

  const getStatusStyle = (status: Loan['status']) => {
    switch (status) {
      case 'APPROVED':
      case 'ACTIVE':
        return styles.statusApproved;
      case 'PENDING':
        return styles.statusPending;
      case 'REJECTED':
        return styles.statusRejected;
      case 'PAID':
        return styles.statusPaid;
      default:
        return {};
    }
  };

  if (loading) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <ActivityIndicator size="large" color="#007bff" />
        <Text>Loading Loans...</Text>
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
      <Text style={commonStyles.titleText}>Your Loans</Text>
      <TouchableOpacity style={[commonStyles.button, styles.applyButton]} onPress={handleApplyLoan}>
        <Text style={commonStyles.buttonText}>Apply for a New Loan</Text>
      </TouchableOpacity>
      <FlatList
        data={loans}
        renderItem={renderLoanItem}
        keyExtractor={(item) => item.id}
        ListEmptyComponent={<Text style={styles.emptyText}>No loans found.</Text>}
        style={styles.listContainer} // Add style for margin
      />
    </View>
  );
};

// Add specific styles for LoansScreen
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
  applyButton: {
    marginBottom: 20, // Add space below the button
    backgroundColor: '#28a745', // Green color for apply button
  },
  listContainer: {
    marginTop: 10, // Add margin above the list
  },
  loanItem: {
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
  loanDetails: {
    flex: 1,
    marginRight: 10,
  },
  loanType: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  loanDate: {
    fontSize: 12,
    color: '#6c757d',
    marginTop: 2,
  },
  loanAmount: {
    fontSize: 14,
    color: '#555',
    marginTop: 4,
  },
  loanStatus: {
    fontSize: 12,
    fontWeight: 'bold',
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 4,
    overflow: 'hidden', // Ensure background color respects border radius
    textAlign: 'center',
  },
  statusApproved: {
    backgroundColor: '#d4edda', // Light green
    color: '#155724', // Dark green
  },
  statusPending: {
    backgroundColor: '#fff3cd', // Light yellow
    color: '#856404', // Dark yellow
  },
  statusRejected: {
    backgroundColor: '#f8d7da', // Light red
    color: '#721c24', // Dark red
  },
  statusPaid: {
    backgroundColor: '#e2e3e5', // Light gray
    color: '#383d41', // Dark gray
  },
});

export default LoansScreen;
