import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Alert, ScrollView } from 'react-native';
import { commonStyles, responsiveWidth } from '../styles/commonStyles'; // Import common styles
import { getAccountDetails } from '../services/api'; // Import API service
import { useRoute, RouteProp } from '@react-navigation/native';
import { RootStackParamList } from '../navigation/AppNavigator';

// Define the route prop type for this screen
type AccountDetailsScreenRouteProp = RouteProp<RootStackParamList, 'AccountDetails'>;

// Define the structure for account details data
interface AccountDetailsData {
  accountId: number;
  name: string;
  email: string;
  balance: number;
  accountType: string;
}

const AccountDetailsScreen = () => {
  const route = useRoute<AccountDetailsScreenRouteProp>();
  const { accountId } = route.params;
  const [accountDetails, setAccountDetails] = useState<AccountDetailsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDetails = async () => {
      setLoading(true);
      setError(null);
      try {
        // TODO: Replace with actual API call
        // const response = await getAccountDetails(accountId);
        // setAccountDetails(response.data);

        // Simulate API call for now
        await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate network delay
        if (accountId === '1') { // Simulate finding account 1
          setAccountDetails({
            accountId: 1,
            name: 'John Doe',
            email: 'john.doe@example.com',
            balance: 5420.50,
            accountType: 'SAVINGS',
          });
        } else {
          throw new Error('Account not found');
        }
      } catch (err: any) {
        console.error('Failed to fetch account details:', err);
        const errorMessage = err.response?.data?.error?.message || err.message || 'Failed to load account details.';
        setError(errorMessage);
        Alert.alert('Error', errorMessage);
      } finally {
        setLoading(false);
      }
    };

    fetchDetails();
  }, [accountId]);

  if (loading) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <ActivityIndicator size="large" color="#007bff" />
        <Text>Loading Account Details...</Text>
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

  if (!accountDetails) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <Text>No account details found.</Text>
      </View>
    );
  }

  return (
    <ScrollView style={commonStyles.container}> // Use ScrollView
      <Text style={commonStyles.titleText}>Account Details</Text>

      <View style={styles.detailsContainer}>
        <View style={styles.detailRow}>
          <Text style={styles.detailLabel}>Account ID:</Text>
          <Text style={styles.detailValue}>{accountDetails.accountId}</Text>
        </View>
        <View style={styles.detailRow}>
          <Text style={styles.detailLabel}>Name:</Text>
          <Text style={styles.detailValue}>{accountDetails.name}</Text>
        </View>
        <View style={styles.detailRow}>
          <Text style={styles.detailLabel}>Email:</Text>
          <Text style={styles.detailValue}>{accountDetails.email}</Text>
        </View>
        <View style={styles.detailRow}>
          <Text style={styles.detailLabel}>Account Type:</Text>
          <Text style={styles.detailValue}>{accountDetails.accountType}</Text>
        </View>
        <View style={styles.detailRow}>
          <Text style={styles.detailLabel}>Balance:</Text>
          <Text style={[styles.detailValue, styles.balanceValue]}>${accountDetails.balance.toFixed(2)}</Text>
        </View>
      </View>

      {/* Add buttons for actions like 'View Transactions', 'Transfer Funds' etc. if needed */}

    </ScrollView>
  );
};

// Add specific styles for AccountDetailsScreen
const styles = StyleSheet.create({
  centerContent: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    color: 'red',
    fontSize: 16,
  },
  detailsContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: responsiveWidth(4), // Responsive padding
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
    elevation: 2,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  detailLabel: {
    fontSize: 16,
    color: '#333',
    fontWeight: '500',
  },
  detailValue: {
    fontSize: 16,
    color: '#555',
  },
  balanceValue: {
    fontWeight: 'bold',
    color: '#28a745',
  },
});

export default AccountDetailsScreen;
