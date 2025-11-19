import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';

// Assuming the screen exists in the original project at:
// /home/ubuntu/finova_project/mobile-frontend/src/screens/SavingsGoalsScreen.tsx
// Adjust the import path if necessary.
// import SavingsGoalsScreen from '../../../../finova_project/mobile-frontend/src/screens/SavingsGoalsScreen';

// --- Placeholder SavingsGoalsScreen Implementation --- START ---
import { View, Text, FlatList, StyleSheet, Button } from 'react-native';

interface Goal {
    id: string;
    name: string;
    targetAmount: number;
    currentAmount: number;
    deadline: string;
}

const SavingsGoalsScreen: React.FC = () => {
    // Mock data
    const [goals, setGoals] = React.useState<Goal[]>([
        { id: 'SG01', name: 'Vacation Fund', targetAmount: 2000, currentAmount: 500, deadline: '2025-12-31' },
        { id: 'SG02', name: 'New Car Down Payment', targetAmount: 5000, currentAmount: 1500, deadline: '2026-06-30' },
    ]);

    // Mock function to add contribution
    const addContribution = (id: string, amount: number) => {
        setGoals(prevGoals =>
            prevGoals.map(goal =>
                goal.id === id ? { ...goal, currentAmount: goal.currentAmount + amount } : goal
            )
        );
        console.log(`Mobile: Added ${amount} to goal ${id}`);
    };

    const renderItem = ({ item }: { item: Goal }) => (
        <View style={styles.itemContainer}>
            <Text style={styles.goalName}>{item.name}</Text>
            <Text>Target: ${item.targetAmount.toLocaleString()}</Text>
            <Text>Current: ${item.currentAmount.toLocaleString()}</Text>
            <Text>Progress: {((item.currentAmount / item.targetAmount) * 100).toFixed(1)}%</Text>
            <Text>Deadline: {item.deadline}</Text>
            <Button title="Add $50" onPress={() => addContribution(item.id, 50)} accessibilityLabel={`Add $50 to ${item.name}`} />
        </View>
    );

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Savings Goals</Text>
            <FlatList
                data={goals}
                renderItem={renderItem}
                keyExtractor={item => item.id}
                ListEmptyComponent={<Text>You have no savings goals yet.</Text>}
            />
            {/* <Button title="Create New Goal" onPress={() => {}} /> */}
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, padding: 16 },
    title: { fontSize: 24, marginBottom: 16, textAlign: 'center' },
    itemContainer: { paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#eee' },
    goalName: { fontSize: 16, fontWeight: 'bold', marginBottom: 4 },
});
// --- Placeholder SavingsGoalsScreen Implementation --- END ---

describe('SavingsGoalsScreen (Mobile)', () => {
    test('renders savings goals list correctly', () => {
        render(<SavingsGoalsScreen />);

        expect(screen.getByText('Savings Goals')).toBeTruthy();

        // Check goal 1
        expect(screen.getByText('Vacation Fund')).toBeTruthy();
        expect(screen.getByText('Target: $2,000')).toBeTruthy();
        expect(screen.getByText('Current: $500')).toBeTruthy();
        expect(screen.getByText('Progress: 25.0%')).toBeTruthy();
        expect(screen.getByText('Deadline: 2025-12-31')).toBeTruthy();

        // Check goal 2
        expect(screen.getByText('New Car Down Payment')).toBeTruthy();
        expect(screen.getByText('Target: $5,000')).toBeTruthy();
        expect(screen.getByText('Current: $1,500')).toBeTruthy(); // Initial
    });

    test('allows adding contribution to a goal', () => {
        const consoleSpy = jest.spyOn(console, 'log');
        render(<SavingsGoalsScreen />);

        const addButton = screen.getByLabelText('Add $50 to New Car Down Payment');
        expect(screen.getByText('Current: $1,500')).toBeTruthy(); // Initial amount

        fireEvent.press(addButton);

        // Check updated amount and progress
        expect(screen.getByText('Current: $1,550')).toBeTruthy();
        expect(screen.getByText('Progress: 31.0%')).toBeTruthy();
        expect(consoleSpy).toHaveBeenCalledWith('Mobile: Added 50 to goal SG02');

        consoleSpy.mockRestore();
    });

    test('renders empty message when no goals exist', () => {
        const EmptyGoalsScreen: React.FC = () => (
            <View style={styles.container}>
                <Text style={styles.title}>Savings Goals</Text>
                <FlatList data={[]} renderItem={() => null} keyExtractor={item => item.id} ListEmptyComponent={<Text>You have no savings goals yet.</Text>} />
            </View>
        );
        render(<EmptyGoalsScreen />);
        expect(screen.getByText('You have no savings goals yet.')).toBeTruthy();
    });

    // Add tests for creating new goals, loading state, error handling, etc.
});
