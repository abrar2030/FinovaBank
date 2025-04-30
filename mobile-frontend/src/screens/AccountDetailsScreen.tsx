import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Alert, ScrollView } from 'react-native';
import { commonStyles, colors, responsiveWidth } from '../styles/commonStyles'; // Import common styles and colors
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
        // Alert.alert('Error', errorMessage); // Optionally show alert or just display error text
      } finally {
        setLoading(false);
      }
    };

    fetchDetails();
  }, [accountId]);

  if (loading) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <ActivityIndicator size="large" color={colors.primary} />
        <Text style={styles.loadingText}>Loading Account Details...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <Text style={commonStyles.errorText}>Error: {error}</Text>
        {/* Optionally add a retry button */}
      </View>
    );
  }

  if (!accountDetails) {
    return (
      <View style={[commonStyles.container, styles.centerContent]}>
        <Text style={styles.infoText}>No account details found.</Text>
      </View>
    );
  }

  return (
    <ScrollView style={commonStyles.container}> {/* Use ScrollView */}
      <Text style={commonStyles.titleText}>Account Details</Text>

      <View style={[commonStyles.card, styles.detailsContainer]}> {/* Use card style */}
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
        <View style={[styles.detailRow, styles.lastDetailRow]}> {/* Remove border from last row */}
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
    flex: 1, // Ensure it takes full height
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: colors.textSecondary,
  },
  infoText: {
    fontSize: 16,
    color: colors.textSecondary,
  },
  detailsContainer: {
    // Removed background color, shadow etc. as it's handled by commonStyles.card
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 15, // Increased padding
    borderBottomWidth: 1,
    borderBottomColor: colors.border, // Use modern border color
  },
  lastDetailRow: {
    borderBottomWidth: 0, // No border for the last item
  },
  detailLabel: {
    fontSize: 16,
    color: colors.textPrimary,
    fontWeight: '500',
  },
  detailValue: {
    fontSize: 16,
    color: colors.textSecondary,
    textAlign: 'right',
  },
  balanceValue: {
    fontWeight: 'bold',
    color: colors.primary, // Use primary color for balance
    fontSize: 18, // Slightly larger balance value
  },
});

export default AccountDetailsScreen;

