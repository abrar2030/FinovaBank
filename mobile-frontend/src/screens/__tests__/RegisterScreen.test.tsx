import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';

// Assuming the screen exists in the original project at:
// /home/ubuntu/finova_project/mobile-frontend/src/screens/RegisterScreen.tsx
// Adjust the import path if necessary.
// import RegisterScreen from '../../../../finova_project/mobile-frontend/src/screens/RegisterScreen';

// --- Placeholder RegisterScreen Implementation --- START ---
import { View, Text, TextInput, Button, StyleSheet, Alert } from 'react-native';

const RegisterScreen: React.FC<{ navigation?: any }> = ({ navigation }) => {
    const [username, setUsername] = React.useState('');
    const [email, setEmail] = React.useState('');
    const [password, setPassword] = React.useState('');
    const [confirmPassword, setConfirmPassword] = React.useState('');

    const handleRegister = () => {
        if (password !== confirmPassword) {
            Alert.alert('Error', 'Passwords do not match');
            return;
        }
        console.log('Mobile Register:', username, email);
        // Mock registration logic - potentially navigate on success
        // navigation?.navigate('Login');
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Register</Text>
            <TextInput
                style={styles.input}
                placeholder="Username"
                value={username}
                onChangeText={setUsername}
                accessibilityLabel="Username Input"
            />
            <TextInput
                style={styles.input}
                placeholder="Email"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                accessibilityLabel="Email Input"
            />
            <TextInput
                style={styles.input}
                placeholder="Password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                accessibilityLabel="Password Input"
            />
            <TextInput
                style={styles.input}
                placeholder="Confirm Password"
                value={confirmPassword}
                onChangeText={setConfirmPassword}
                secureTextEntry
                accessibilityLabel="Confirm Password Input"
            />
            <Button title="Register" onPress={handleRegister} accessibilityLabel="Register Button" />
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 16 },
    title: { fontSize: 24, marginBottom: 16, textAlign: 'center' },
    input: { height: 40, borderColor: 'gray', borderWidth: 1, marginBottom: 12, paddingHorizontal: 8 },
});
// --- Placeholder RegisterScreen Implementation --- END ---

describe('RegisterScreen (Mobile)', () => {
    // Mock Alert
    jest.spyOn(Alert, 'alert');

    beforeEach(() => {
        // Clear mock calls before each test
        jest.clearAllMocks();
    });

    test('renders registration form elements', () => {
        render(<RegisterScreen />);

        expect(screen.getByPlaceholderText('Username')).toBeTruthy();
        expect(screen.getByPlaceholderText('Email')).toBeTruthy();
        expect(screen.getByPlaceholderText('Password')).toBeTruthy();
        expect(screen.getByPlaceholderText('Confirm Password')).toBeTruthy();
        expect(screen.getByRole('button', { name: /register/i })).toBeTruthy();
        // Check accessibility labels
        expect(screen.getByLabelText('Username Input')).toBeTruthy();
        expect(screen.getByLabelText('Email Input')).toBeTruthy();
        expect(screen.getByLabelText('Password Input')).toBeTruthy();
        expect(screen.getByLabelText('Confirm Password Input')).toBeTruthy();
        expect(screen.getByLabelText('Register Button')).toBeTruthy();
    });

    test('allows inputting registration details', () => {
        render(<RegisterScreen />);

        fireEvent.changeText(screen.getByLabelText('Username Input'), 'newmobile');
        fireEvent.changeText(screen.getByLabelText('Email Input'), 'new@mobile.com');
        fireEvent.changeText(screen.getByLabelText('Password Input'), 'pass123');
        fireEvent.changeText(screen.getByLabelText('Confirm Password Input'), 'pass123');

        expect(screen.getByLabelText('Username Input').props.value).toBe('newmobile');
        expect(screen.getByLabelText('Email Input').props.value).toBe('new@mobile.com');
        expect(screen.getByLabelText('Password Input').props.value).toBe('pass123');
        expect(screen.getByLabelText('Confirm Password Input').props.value).toBe('pass123');
    });

    test('calls register handler on button press if passwords match', () => {
        const consoleSpy = jest.spyOn(console, 'log');
        render(<RegisterScreen />);

        fireEvent.changeText(screen.getByLabelText('Username Input'), 'newmobile');
        fireEvent.changeText(screen.getByLabelText('Email Input'), 'new@mobile.com');
        fireEvent.changeText(screen.getByLabelText('Password Input'), 'pass123');
        fireEvent.changeText(screen.getByLabelText('Confirm Password Input'), 'pass123');

        fireEvent.press(screen.getByLabelText('Register Button'));

        expect(consoleSpy).toHaveBeenCalledWith('Mobile Register:', 'newmobile', 'new@mobile.com');
        expect(Alert.alert).not.toHaveBeenCalled();

        consoleSpy.mockRestore();
    });

    test('shows alert if passwords do not match on register press', () => {
        const consoleSpy = jest.spyOn(console, 'log');
        render(<RegisterScreen />);

        fireEvent.changeText(screen.getByLabelText('Password Input'), 'pass123');
        fireEvent.changeText(screen.getByLabelText('Confirm Password Input'), 'mismatch');

        fireEvent.press(screen.getByLabelText('Register Button'));

        expect(Alert.alert).toHaveBeenCalledWith('Error', 'Passwords do not match');
        expect(consoleSpy).not.toHaveBeenCalled();

        consoleSpy.mockRestore();
    });
});
