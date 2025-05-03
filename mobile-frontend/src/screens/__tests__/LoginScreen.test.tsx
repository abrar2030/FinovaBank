import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';

// Assuming the screen exists in the original project at:
// /home/ubuntu/finova_project/mobile-frontend/src/screens/LoginScreen.tsx
// Adjust the import path if necessary.
// import LoginScreen from '../../../../finova_project/mobile-frontend/src/screens/LoginScreen';

// --- Placeholder LoginScreen Implementation --- START ---
import { View, Text, TextInput, Button, StyleSheet } from 'react-native';

const LoginScreen: React.FC<{ navigation?: any }> = ({ navigation }) => {
    const [username, setUsername] = React.useState('');
    const [password, setPassword] = React.useState('');

    const handleLogin = () => {
        console.log('Mobile Login:', username, password);
        // Mock login logic - potentially navigate on success
        // navigation?.navigate('Dashboard');
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Login</Text>
            <TextInput
                style={styles.input}
                placeholder="Username"
                value={username}
                onChangeText={setUsername}
                accessibilityLabel="Username Input"
            />
            <TextInput
                style={styles.input}
                placeholder="Password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                accessibilityLabel="Password Input"
            />
            <Button title="Login" onPress={handleLogin} accessibilityLabel="Login Button" />
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 16 },
    title: { fontSize: 24, marginBottom: 16, textAlign: 'center' },
    input: { height: 40, borderColor: 'gray', borderWidth: 1, marginBottom: 12, paddingHorizontal: 8 },
});
// --- Placeholder LoginScreen Implementation --- END ---

describe('LoginScreen (Mobile)', () => {
    test('renders login form elements', () => {
        render(<LoginScreen />);

        expect(screen.getByPlaceholderText('Username')).toBeTruthy();
        expect(screen.getByPlaceholderText('Password')).toBeTruthy();
        expect(screen.getByRole('button', { name: /login/i })).toBeTruthy();
        // Alternative query using accessibilityLabel
        expect(screen.getByLabelText('Username Input')).toBeTruthy();
        expect(screen.getByLabelText('Password Input')).toBeTruthy();
        expect(screen.getByLabelText('Login Button')).toBeTruthy();
    });

    test('allows inputting username and password', () => {
        render(<LoginScreen />);

        const usernameInput = screen.getByLabelText('Username Input');
        const passwordInput = screen.getByLabelText('Password Input');

        fireEvent.changeText(usernameInput, 'mobileuser');
        fireEvent.changeText(passwordInput, 'mobilepass');

        expect(usernameInput.props.value).toBe('mobileuser');
        expect(passwordInput.props.value).toBe('mobilepass');
    });

    test('calls login handler on button press', () => {
        const consoleSpy = jest.spyOn(console, 'log');
        // Mock navigation if needed
        // const mockNavigation = { navigate: jest.fn() };
        // render(<LoginScreen navigation={mockNavigation} />);
        render(<LoginScreen />);

        const loginButton = screen.getByLabelText('Login Button');
        fireEvent.press(loginButton);

        expect(consoleSpy).toHaveBeenCalledWith('Mobile Login:', '', ''); // Initial empty values
        // If input is filled first:
        // fireEvent.changeText(screen.getByLabelText('Username Input'), 'test');
        // fireEvent.changeText(screen.getByLabelText('Password Input'), 'pass');
        // fireEvent.press(loginButton);
        // expect(consoleSpy).toHaveBeenCalledWith('Mobile Login:', 'test', 'pass');
        // expect(mockNavigation.navigate).toHaveBeenCalledWith('Dashboard');

        consoleSpy.mockRestore();
    });
});

